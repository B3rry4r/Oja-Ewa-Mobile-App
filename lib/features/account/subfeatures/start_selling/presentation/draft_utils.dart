import 'seller_registration_draft.dart';

SellerRegistrationDraft sellerDraftFromArgs(Object? args) {
  if (args is Map<String, dynamic>) return SellerRegistrationDraft.fromJson(args);
  return SellerRegistrationDraft();
}
