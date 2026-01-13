import 'business_registration_draft.dart';

String mapCategoryLabelToEnum(String label) {
  return switch (label) {
    'Beauty' => 'beauty',
    'Brands' => 'brand',
    'Schools' => 'school',
    'Music' => 'music',
    _ => label.toLowerCase(),
  };
}

String? mapOfferingLabelToEnum(String? label) {
  if (label == null) return null;
  return switch (label) {
    'Selling Product' => 'selling_product',
    'Providing Service' => 'providing_service',
    _ => null,
  };
}

List<String> parseProductListText(String? text) {
  if (text == null) return const [];
  // Split by newlines and commas, trim and drop empties.
  return text
      .split(RegExp(r'[\n,]+'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

BusinessRegistrationDraft draftFromArgs(Object? args, {required String categoryLabelFallback}) {
  if (args is Map<String, dynamic>) return BusinessRegistrationDraft.fromJson(args);
  return BusinessRegistrationDraft(categoryLabel: categoryLabelFallback);
}
