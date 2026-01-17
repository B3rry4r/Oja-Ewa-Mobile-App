import 'package:flutter/material.dart';
import 'package:ojaewa/core/ui/price_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/widgets/product_card.dart';
import 'package:ojaewa/features/product/domain/product.dart';
import 'package:ojaewa/features/sellers/presentation/controllers/public_seller_controller.dart';
import 'package:ojaewa/features/sellers/presentation/controllers/public_seller_products_controller.dart';
import 'package:ojaewa/features/product_detail/presentation/product_detail_screen.dart';

class SellerProfileScreen extends ConsumerWidget {
  const SellerProfileScreen({super.key, required this.sellerId});

  final int sellerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sellerAsync = ref.watch(publicSellerProfileProvider(sellerId));
    final productsAsync = ref.watch(publicSellerProductsPagedProvider((sellerId: sellerId)));

    return Scaffold(
      backgroundColor: const Color(0xFF603814),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppHeader(iconColor: Colors.white),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF8F1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: sellerAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(child: Text('Failed to load seller')),
                  data: (seller) {
                    final locationParts = [seller.city, seller.state, seller.country]
                        .where((e) => (e ?? '').trim().isNotEmpty)
                        .map((e) => e!.trim())
                        .toList();
                    final location = locationParts.isEmpty ? '' : locationParts.join(', ');

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: seller.businessLogo == null || seller.businessLogo!.trim().isEmpty
                                      ? Container(color: const Color(0xFFD9D9D9))
                                      : Image.network(
                                          seller.businessLogo!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(color: const Color(0xFFD9D9D9)),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      seller.businessName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'Campton',
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF241508),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (location.isNotEmpty)
                                      Text(
                                        location,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Campton',
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF777F84),
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFFFDB80),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          (seller.avgRating ?? 0).toString(),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'Campton',
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF241508),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '(${seller.totalReviews ?? 0})',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontFamily: 'Campton',
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF777F84),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Existing UI sections (contact/social) filled where available
                          if ((seller.businessEmail ?? '').trim().isNotEmpty) ...[
                            const Text('Email', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Text(seller.businessEmail!),
                            const SizedBox(height: 16),
                          ],

                          if ((seller.businessPhoneNumber ?? '').trim().isNotEmpty) ...[
                            const Text('Phone', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Text(seller.businessPhoneNumber!),
                            const SizedBox(height: 16),
                          ],

                          if ((seller.instagram ?? '').trim().isNotEmpty || (seller.facebook ?? '').trim().isNotEmpty) ...[
                            const Text('Socials', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            if ((seller.instagram ?? '').trim().isNotEmpty) Text('Instagram: ${seller.instagram}'),
                            if ((seller.facebook ?? '').trim().isNotEmpty) Text('Facebook: ${seller.facebook}'),
                            const SizedBox(height: 16),
                          ],

                          const SizedBox(height: 8),
                          const Text(
                            'More from this seller',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Campton',
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF241508),
                            ),
                          ),
                          const SizedBox(height: 12),

                          productsAsync.when(
                            loading: () => const SizedBox(
                              height: 80,
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            ),
                            error: (_, __) => const Text('Failed to load products'),
                            data: (state) {
                              final items = state.items
                                  .map(
                                    (p) => Product(
                                      id: p.id.toString(),
                                      title: p.name,
                                      priceLabel: formatPrice(p.price),
                                      rating: (p.avgRating ?? 0).toDouble(),
                                      reviewCount: 0,
                                      imageUrl: p.image,
                                      imageColor: 0xFFD9D9D9,
                                    ),
                                  )
                                  .toList();

                              if (items.isEmpty) {
                                return const Text('No products yet');
                              }

                              return Column(
                                children: [
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 6,
                                      mainAxisExtent: 248,
                                    ),
                                    itemCount: items.length,
                                    itemBuilder: (context, index) {
                                      final prod = items[index];
                                      return ProductCard(
                                        product: prod,
                                        onTap: () {
                                          final id = int.tryParse(prod.id);
                                          if (id == null) return;
                                          Navigator.of(context).push(
                                            MaterialPageRoute(builder: (_) => ProductDetailsScreen(productId: id)),
                                          );
                                        },
                                        onFavoriteTap: () {},
                                      );
                                    },
                                  ),
                                  if (state.hasMore) ...[
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      height: 46,
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: state.isLoadingMore
                                            ? null
                                            : () => ref
                                                .read(publicSellerProductsPagedProvider((sellerId: sellerId)).notifier)
                                                .loadMore(),
                                        child: state.isLoadingMore
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                              )
                                            : const Text('Load more'),
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
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
