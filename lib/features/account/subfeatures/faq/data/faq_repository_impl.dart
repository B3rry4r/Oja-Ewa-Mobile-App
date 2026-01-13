import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/dio_clients.dart';
import '../domain/faq_item.dart';
import '../domain/faq_repository.dart';
import 'faq_api.dart';

class FaqRepositoryImpl implements FaqRepository {
  FaqRepositoryImpl(this._api);

  final FaqApi _api;

  @override
  Future<List<FaqItem>> getFaqs() => _api.getFaqs();

  @override
  Future<List<FaqItem>> searchFaqs(String query) => _api.searchFaqs(query);
}

final faqApiProvider = Provider<FaqApi>((ref) {
  return FaqApi(ref.watch(laravelDioProvider));
});

final faqRepositoryProvider = Provider<FaqRepository>((ref) {
  return FaqRepositoryImpl(ref.watch(faqApiProvider));
});
