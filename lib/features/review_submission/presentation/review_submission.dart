import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/features/reviews/presentation/controllers/reviews_controller.dart';

class ReviewSubmissionScreen extends ConsumerStatefulWidget {
  const ReviewSubmissionScreen({super.key});

  @override
  ConsumerState<ReviewSubmissionScreen> createState() =>
      _ReviewSubmissionScreenState();
}

class _ReviewSubmissionScreenState
    extends ConsumerState<ReviewSubmissionScreen> {
  int rating = 0;
  final headlineController = TextEditingController();
  final bodyController = TextEditingController();

  @override
  void dispose() {
    headlineController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        (ModalRoute.of(context)?.settings.arguments as Map?)
            ?.cast<String, dynamic>() ??
        const {};
    final type = (args['type'] as String?) ?? 'product';
    final id = (args['id'] as num?)?.toInt() ?? 0;

    final busy = ref.watch(reviewSubmitProvider).isLoading;
    final colors = context.appColors;

    return AppPageScaffold(
      title: 'Write a review',
      showActions: false,
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Text(
            'Rating',
            style: TextStyle(
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              fontSize: 22,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final idx = i + 1;
              return IconButton(
                onPressed: busy ? null : () => setState(() => rating = idx),
                icon: Icon(
                  Icons.star_rate_rounded,
                  size: 32,
                  color: idx <= rating
                      ? const Color(0xFFFDAF40)
                      : const Color(0xFFDEDEDE),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          Text(
            'Headline',
            style: TextStyle(
              fontFamily: 'Campton',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: headlineController,
            enabled: !busy,
            decoration: InputDecoration(
              hintText: 'Great product',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.border),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Description',
            style: TextStyle(
              fontFamily: 'Campton',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: bodyController,
            enabled: !busy,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Tell us more...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.border),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: busy
                  ? null
                  : () async {
                      final h = headlineController.text.trim();
                      final b = bodyController.text.trim();
                      if (id == 0 || rating < 1 || h.isEmpty || b.isEmpty) {
                        return;
                      }

                      await ref
                          .read(reviewSubmitProvider.notifier)
                          .submit(
                            args: (type: type, id: id),
                            rating: rating,
                            headline: h,
                            body: b,
                          );
                      if (!context.mounted) return;
                      Navigator.of(context).pop(true);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFDAF40),
                foregroundColor: const Color(0xFFFFFBF5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Submit',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
