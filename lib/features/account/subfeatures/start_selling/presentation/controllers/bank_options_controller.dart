import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ojaewa/core/auth/auth_providers.dart';
import 'package:ojaewa/core/network/dio_clients.dart';

import '../../data/seller_profile_api.dart';
import '../../domain/bank_option.dart';

final sellerProfileApiProvider = Provider<SellerProfileApi>((ref) {
  return SellerProfileApi(ref.watch(laravelDioProvider));
});

final bankOptionsProvider =
    FutureProvider.autoDispose.family<List<BankOption>, String>((ref, country) async {
      final token = ref.watch(accessTokenProvider);
      if (token == null || token.isEmpty) {
        return const [];
      }
      return ref.read(sellerProfileApiProvider).getBanks(country: country);
    });
