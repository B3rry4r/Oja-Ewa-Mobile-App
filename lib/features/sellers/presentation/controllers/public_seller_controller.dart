import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/public_seller_repository_impl.dart';
import '../../domain/public_seller_profile.dart';
import '../../../product/presentation/controllers/product_details_controller.dart';

final publicSellerProfileProvider = FutureProvider.family<PublicSellerProfile, int>((ref, sellerId) async {
  return ref.watch(publicSellerRepositoryProvider).getSeller(sellerId);
});

final publicSellerProductsProvider = FutureProvider.family<List<ProductDetails>, int>((ref, sellerId) async {
  return ref.watch(publicSellerRepositoryProvider).getSellerProducts(sellerId: sellerId, page: 1, perPage: 10);
});
