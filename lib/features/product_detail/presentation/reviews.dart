import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/features/reviews/presentation/controllers/reviews_controller.dart';

class ReviewsScreen extends ConsumerStatefulWidget {
  const ReviewsScreen({super.key});

  @override
  ConsumerState<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends ConsumerState<ReviewsScreen> {
  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map?)?.cast<String, dynamic>() ?? const {};
    final type = (args['type'] as String?) ?? 'product';
    final id = (args['id'] as num?)?.toInt() ?? 0;

    final async = ref.watch(reviewsProvider((type: type, id: id)));

    return Scaffold(
      backgroundColor: const Color(0xFF603814),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppHeader(iconColor: Colors.white, showActions: false),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF8F1),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: async.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => const Center(child: Text('Failed to load reviews')),
                  data: (page) {
                    final reviews = page.items.where((r) {
                      if (selectedFilter == 'All') return true;
                      final stars = int.tryParse(selectedFilter);
                      return stars == null ? true : r.rating == stars;
                    }).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Reviews (${page.total})',
                                style: const TextStyle(
                                  fontSize: 33,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF241508),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context).pushNamed(
                                  AppRoutes.reviewSubmission,
                                  arguments: {'type': type, 'id': id},
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                  child: Text(
                                    'Write Review',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF000000)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Row(
                            children: [
                              _Stars(rating: (page.entity.avgRating ?? 0).toDouble()),
                              const SizedBox(width: 8),
                              Text(
                                (page.entity.avgRating ?? 0).toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E2021),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 42,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              _FilterChip(label: 'All', selected: selectedFilter == 'All', onTap: () => setState(() => selectedFilter = 'All')),
                              const SizedBox(width: 12),
                              _FilterChip(label: '5', selected: selectedFilter == '5', onTap: () => setState(() => selectedFilter = '5')),
                              const SizedBox(width: 12),
                              _FilterChip(label: '4', selected: selectedFilter == '4', onTap: () => setState(() => selectedFilter = '4')),
                              const SizedBox(width: 12),
                              _FilterChip(label: '3', selected: selectedFilter == '3', onTap: () => setState(() => selectedFilter = '3')),
                              const SizedBox(width: 12),
                              _FilterChip(label: '2', selected: selectedFilter == '2', onTap: () => setState(() => selectedFilter = '2')),
                              const SizedBox(width: 12),
                              _FilterChip(label: '1', selected: selectedFilter == '1', onTap: () => setState(() => selectedFilter = '1')),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: reviews.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final r = reviews[index];
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFDEDEDE)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            r.user?.displayName ?? 'Anonymous',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF241508),
                                            ),
                                          ),
                                        ),
                                        _Stars(rating: r.rating.toDouble()),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      r.headline,
                                      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF241508)),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      r.body,
                                      style: const TextStyle(color: Color(0xFF3C4042), height: 1.4),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFA15E22) : Colors.transparent,
          border: selected ? null : Border.all(color: const Color(0xFFCCCCCC)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w400,
              color: selected ? const Color(0xFFFBFBFB) : const Color(0xFF301C0A),
            ),
          ),
        ),
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final full = rating.floor().clamp(0, 5);
    return Row(
      children: List.generate(5, (i) {
        final filled = i < full;
        return Icon(
          Icons.star_rate_rounded,
          size: 16,
          color: filled ? const Color(0xFFFDAF40) : const Color(0xFFDEDEDE),
        );
      }),
    );
  }
}
