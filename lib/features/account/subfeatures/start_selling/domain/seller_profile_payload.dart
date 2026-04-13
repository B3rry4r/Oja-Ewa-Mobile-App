import 'package:flutter/foundation.dart';

@immutable
class SellerProfilePayload {
  const SellerProfilePayload({
    required this.businessName,
    required this.legalBusinessName,
    this.tradingName,
    required this.businessEmail,
    required this.businessPhoneNumber,
    this.websiteUrl,
    required this.businessRegistrationNumber,
    required this.taxIdentificationNumber,
    this.nin,
    this.bvn,
    required this.dateOfIncorporation,
    required this.countryOfIncorporation,
    required this.industrySector,
    required this.businessType,
    this.otherBusinessType,
    required this.numberOfEmployees,
    required this.annualTurnoverRange,
    required this.country,
    required this.state,
    required this.city,
    required this.address,
    required this.postalCode,
    required this.bankName,
    required this.accountNumber,
    required this.authorizedSignatoryFullName,
    required this.authorizedSignatoryJobTitle,
    required this.authorizedSignatoryEmail,
    required this.authorizedSignatoryPhoneNumber,
    required this.authorizedSignatoryIdNumber,
    required this.authorizedSignatoryDateOfBirth,
    required this.beneficialOwners,
    required this.preferredSettlementCurrency,
    required this.declarationLegalRegistered,
    required this.declarationInformationTrue,
    required this.declarationAuthorizeVerification,
    required this.authorizeSettlementAccount,
    required this.acceptPartnerBankTerms,
    required this.printedNameOfAuthorizedSignatory,
    this.authorizedSignatorySignature,
    required this.submissionDate,
    this.identityDocument,
    this.businessCertificate,
    this.businessLogo,
  });

  final String businessName;
  final String legalBusinessName;
  final String? tradingName;
  final String businessEmail;
  final String businessPhoneNumber;
  final String? websiteUrl;
  final String businessRegistrationNumber;
  final String taxIdentificationNumber;
  final String? nin;
  final String? bvn;
  final String dateOfIncorporation;
  final String countryOfIncorporation;
  final String industrySector;
  final String businessType;
  final String? otherBusinessType;
  final int numberOfEmployees;
  final String annualTurnoverRange;
  final String country;
  final String state;
  final String city;
  final String address;
  final String postalCode;
  final String bankName;
  final String accountNumber;
  final String authorizedSignatoryFullName;
  final String authorizedSignatoryJobTitle;
  final String authorizedSignatoryEmail;
  final String authorizedSignatoryPhoneNumber;
  final String authorizedSignatoryIdNumber;
  final String authorizedSignatoryDateOfBirth;
  final List<Map<String, dynamic>> beneficialOwners;
  final String preferredSettlementCurrency;
  final bool declarationLegalRegistered;
  final bool declarationInformationTrue;
  final bool declarationAuthorizeVerification;
  final bool authorizeSettlementAccount;
  final bool acceptPartnerBankTerms;
  final String printedNameOfAuthorizedSignatory;
  final String? authorizedSignatorySignature;
  final String submissionDate;
  final String? identityDocument;
  final String? businessCertificate;
  final String? businessLogo;

  Map<String, dynamic> toJson({bool includeFileFields = true}) {
    return {
      if (businessName.trim().isNotEmpty) 'business_name': businessName,
      'legal_business_name': legalBusinessName,
      if (tradingName != null && tradingName!.isNotEmpty)
        'trading_name': tradingName,
      'business_email': businessEmail,
      'business_phone_number': businessPhoneNumber,
      if (websiteUrl != null && websiteUrl!.isNotEmpty)
        'website_url': websiteUrl,
      if (businessRegistrationNumber.trim().isNotEmpty)
        'business_registration_number': businessRegistrationNumber,
      'tax_identification_number': taxIdentificationNumber,
      'nin': nin?.trim().isEmpty ?? true ? null : nin,
      'bvn': bvn?.trim().isEmpty ?? true ? null : bvn,
      'date_of_incorporation': dateOfIncorporation,
      'country_of_incorporation': countryOfIncorporation,
      'industry_sector': industrySector,
      'business_type': businessType,
      if (otherBusinessType != null && otherBusinessType!.isNotEmpty)
        'other_business_type': otherBusinessType,
      'number_of_employees': numberOfEmployees,
      'annual_turnover_range': annualTurnoverRange,
      'address': address,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'bank_name': bankName,
      'account_number': accountNumber,
      'authorized_signatory_full_name': authorizedSignatoryFullName,
      'authorized_signatory_job_title': authorizedSignatoryJobTitle,
      'authorized_signatory_email': authorizedSignatoryEmail,
      'authorized_signatory_phone_number': authorizedSignatoryPhoneNumber,
      'authorized_signatory_id_number': authorizedSignatoryIdNumber,
      'authorized_signatory_date_of_birth': authorizedSignatoryDateOfBirth,
      'beneficial_owners': beneficialOwners,
      'preferred_settlement_currency': preferredSettlementCurrency,
      'declaration_legal_registered': declarationLegalRegistered,
      'declaration_information_true': declarationInformationTrue,
      'declaration_authorize_verification': declarationAuthorizeVerification,
      'authorize_settlement_account': authorizeSettlementAccount,
      'accept_partner_bank_terms': acceptPartnerBankTerms,
      'printed_name_of_authorized_signatory': printedNameOfAuthorizedSignatory,
      'submission_date': submissionDate,
      if (includeFileFields &&
          authorizedSignatorySignature != null &&
          authorizedSignatorySignature!.isNotEmpty)
        'authorized_signatory_signature': authorizedSignatorySignature,
      if (includeFileFields &&
          identityDocument != null &&
          identityDocument!.isNotEmpty)
        'identity_document': identityDocument,
      if (includeFileFields &&
          businessCertificate != null &&
          businessCertificate!.isNotEmpty)
        'business_certificate': businessCertificate,
      if (includeFileFields && businessLogo != null && businessLogo!.isNotEmpty)
        'business_logo': businessLogo,
    };
  }
}
