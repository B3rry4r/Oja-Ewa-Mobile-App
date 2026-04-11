import 'seller_registration_draft.dart';
import '../domain/seller_status.dart';

SellerRegistrationDraft sellerDraftFromArgs(Object? args) {
  if (args is Map<String, dynamic>) {
    return SellerRegistrationDraft.fromJson(args);
  }
  return SellerRegistrationDraft();
}

SellerRegistrationDraft sellerDraftFromStatus(SellerStatus status) {
  return SellerRegistrationDraft(
    isResubmission: true,
    legalBusinessName: status.legalBusinessName,
    tradingName: status.tradingName,
    taxIdentificationNumber: status.taxIdentificationNumber,
    dateOfIncorporation: status.dateOfIncorporation,
    countryOfIncorporation: status.countryOfIncorporation,
    websiteUrl: status.websiteUrl,
    country: status.country,
    state: status.state,
    city: status.city,
    address: status.address,
    postalCode: status.postalCode,
    industrySector: status.industrySector,
    businessType: status.businessType,
    otherBusinessType: status.otherBusinessType,
    numberOfEmployees: status.numberOfEmployees,
    annualTurnoverRange: status.annualTurnoverRange,
    businessEmail: status.businessEmail,
    businessPhoneNumber: status.businessPhoneNumber,
    authorizedSignatoryFullName: status.authorizedSignatoryFullName,
    authorizedSignatoryJobTitle: status.authorizedSignatoryJobTitle,
    authorizedSignatoryEmail: status.authorizedSignatoryEmail,
    authorizedSignatoryPhoneNumber: status.authorizedSignatoryPhoneNumber,
    authorizedSignatoryIdNumber: status.authorizedSignatoryIdNumber,
    authorizedSignatoryDateOfBirth: status.authorizedSignatoryDateOfBirth,
    beneficialOwners: status.beneficialOwners,
    preferredSettlementCurrency: status.preferredSettlementCurrency,
    declarationLegalRegistered: status.declarationLegalRegistered,
    declarationInformationTrue: status.declarationInformationTrue,
    declarationAuthorizeVerification: status.declarationAuthorizeVerification,
    authorizeSettlementAccount: status.authorizeSettlementAccount,
    acceptPartnerBankTerms: status.acceptPartnerBankTerms,
    printedNameOfAuthorizedSignatory: status.printedNameOfAuthorizedSignatory,
    authorizedSignatorySignaturePath: status.authorizedSignatorySignature,
    submissionDate: status.submissionDate,
    identityDocumentPath: status.identityDocument,
    businessName: status.businessName,
    businessRegistrationNumber: status.businessRegistrationNumber,
    businessCertificatePath: status.businessCertificate,
    businessLogoPath: status.businessLogo,
    bankName: status.bankName,
    accountNumber: status.accountNumber,
  );
}
