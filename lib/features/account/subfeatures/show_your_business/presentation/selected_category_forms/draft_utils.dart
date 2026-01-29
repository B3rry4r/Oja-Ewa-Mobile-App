import 'business_registration_draft.dart';

/// Maps UI category labels to backend API category enum values.
/// Backend accepts: school, art (afro_beauty_services removed)
String mapCategoryLabelToEnum(String label) {
  return switch (label) {
    'Schools' => 'school',
    'Art' => 'art',
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
