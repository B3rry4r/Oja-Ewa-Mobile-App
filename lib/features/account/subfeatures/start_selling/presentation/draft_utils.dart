import 'seller_registration_draft.dart';
import '../domain/seller_status.dart';

SellerRegistrationDraft sellerDraftFromArgs(Object? args) {
  if (args is Map<String, dynamic>)
    return SellerRegistrationDraft.fromJson(args);
  return SellerRegistrationDraft();
}

SellerRegistrationDraft sellerDraftFromStatus(SellerStatus status) {
  return SellerRegistrationDraft(
    isResubmission: true,
    country: status.country,
    state: status.state,
    city: status.city,
    address: status.address,
    businessEmail: status.businessEmail,
    businessPhoneNumber: status.businessPhoneNumber,
    instagram: status.instagram,
    facebook: status.facebook,
    identityDocumentPath: status.identityDocument,
    businessName: status.businessName,
    businessRegistrationNumber: status.businessRegistrationNumber,
    businessCertificatePath: status.businessCertificate,
    businessLogoPath: status.businessLogo,
    bankName: status.bankName,
    accountNumber: status.accountNumber,
  );
}
