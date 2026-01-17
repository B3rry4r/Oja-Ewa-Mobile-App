import 'business_registration_draft.dart';

/// Maps UI category labels to backend API category enum values.
/// Backend accepts: school, art, afro_beauty_services
String mapCategoryLabelToEnum(String label) {
  return switch (label) {
    'Beauty' => 'afro_beauty_services',
    'Schools' => 'school',
    'Art' => 'art',
    // Legacy mappings (no longer valid for business profiles)
    'Brands' => 'art', // Brands was moved to art category
    'Music' => 'art',  // Music was moved to art category
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
