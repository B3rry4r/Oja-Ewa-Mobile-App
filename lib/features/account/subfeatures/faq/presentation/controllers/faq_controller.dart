import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/faq_repository_impl.dart';
import '../../domain/faq_item.dart';

final faqsProvider = FutureProvider<List<FaqItem>>((ref) async {
  return ref.watch(faqRepositoryProvider).getFaqs();
});

final faqSearchProvider = FutureProvider.family<List<FaqItem>, String>((ref, query) async {
  if (query.trim().isEmpty) return ref.watch(faqRepositoryProvider).getFaqs();
  return ref.watch(faqRepositoryProvider).searchFaqs(query.trim());
});
