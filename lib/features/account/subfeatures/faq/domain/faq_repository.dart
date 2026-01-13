import 'faq_item.dart';

abstract interface class FaqRepository {
  Future<List<FaqItem>> getFaqs();
  Future<List<FaqItem>> searchFaqs(String query);
}
