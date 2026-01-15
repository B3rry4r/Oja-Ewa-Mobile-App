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

BusinessRegistrationDraft draftFromArgs(Object? args, {required String categoryLabelFallback}) {
  if (args is Map<String, dynamic>) return BusinessRegistrationDraft.fromJson(args);
  return BusinessRegistrationDraft(categoryLabel: categoryLabelFallback);
}
