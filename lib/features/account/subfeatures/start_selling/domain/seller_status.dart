import 'package:flutter/foundation.dart';

@immutable
class SellerStatus {
  const SellerStatus({
    this.id,
    required this.registrationStatus,
    required this.active,
    this.rejectionReason,
    this.businessName,
    this.legalBusinessName,
    this.tradingName,
    this.badge,
    this.taxIdentificationNumber,
    this.dateOfIncorporation,
    this.countryOfIncorporation,
    this.industrySector,
    this.businessType,
    this.otherBusinessType,
    this.numberOfEmployees,
    this.annualTurnoverRange,
    this.country,
    this.state,
    this.city,
    this.address,
    this.postalCode,
    this.businessEmail,
    this.businessPhoneNumber,
    this.websiteUrl,
    this.authorizedSignatoryFullName,
    this.authorizedSignatoryJobTitle,
    this.authorizedSignatoryEmail,
    this.authorizedSignatoryPhoneNumber,
    this.authorizedSignatoryIdNumber,
    this.authorizedSignatoryDateOfBirth,
    this.beneficialOwners,
    this.preferredSettlementCurrency,
    this.declarationLegalRegistered,
    this.declarationInformationTrue,
    this.declarationAuthorizeVerification,
    this.authorizeSettlementAccount,
    this.acceptPartnerBankTerms,
    this.printedNameOfAuthorizedSignatory,
    this.authorizedSignatorySignature,
    this.submissionDate,
    this.identityDocument,
    this.businessRegistrationNumber,
    this.businessCertificate,
    this.businessLogo,
    this.bankName,
    this.accountNumber,
  });

  final int? id;
  final String registrationStatus;
  final bool active;
  final String? rejectionReason;
  final String? businessName;
  final String? legalBusinessName;
  final String? tradingName;
  final String? badge;
  final String? taxIdentificationNumber;
  final String? dateOfIncorporation;
  final String? countryOfIncorporation;
  final String? industrySector;
  final String? businessType;
  final String? otherBusinessType;
  final int? numberOfEmployees;
  final String? annualTurnoverRange;
  final String? country;
  final String? state;
  final String? city;
  final String? address;
  final String? postalCode;
  final String? businessEmail;
  final String? businessPhoneNumber;
  final String? websiteUrl;
  final String? authorizedSignatoryFullName;
  final String? authorizedSignatoryJobTitle;
  final String? authorizedSignatoryEmail;
  final String? authorizedSignatoryPhoneNumber;
  final String? authorizedSignatoryIdNumber;
  final String? authorizedSignatoryDateOfBirth;
  final List<Map<String, dynamic>>? beneficialOwners;
  final String? preferredSettlementCurrency;
  final bool? declarationLegalRegistered;
  final bool? declarationInformationTrue;
  final bool? declarationAuthorizeVerification;
  final bool? authorizeSettlementAccount;
  final bool? acceptPartnerBankTerms;
  final String? printedNameOfAuthorizedSignatory;
  final String? authorizedSignatorySignature;
  final String? submissionDate;
  final String? identityDocument;
  final String? businessRegistrationNumber;
  final String? businessCertificate;
  final String? businessLogo;
  final String? bankName;
  final String? accountNumber;

  bool get isApprovedAndActive => registrationStatus == 'approved' && active;
  bool get isRejected =>
      registrationStatus == 'rejected' &&
      (rejectionReason ?? '').trim().isNotEmpty;

  static SellerStatus fromJson(Map<String, dynamic> json) {
    return SellerStatus(
      id: (json['id'] as num?)?.toInt(),
      registrationStatus: (json['registration_status'] as String?) ?? '',
      active: (json['active'] as bool?) ?? false,
      rejectionReason: json['rejection_reason'] as String?,
      businessName: json['business_name'] as String?,
      legalBusinessName: json['legal_business_name'] as String?,
      tradingName: json['trading_name'] as String?,
      badge: json['badge'] as String?,
      taxIdentificationNumber: json['tax_identification_number'] as String?,
      dateOfIncorporation: json['date_of_incorporation'] as String?,
      countryOfIncorporation: json['country_of_incorporation'] as String?,
      industrySector: json['industry_sector'] as String?,
      businessType: json['business_type'] as String?,
      otherBusinessType: json['other_business_type'] as String?,
      numberOfEmployees: (json['number_of_employees'] as num?)?.toInt(),
      annualTurnoverRange: json['annual_turnover_range'] as String?,
      country: json['country'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
      postalCode: json['postal_code'] as String?,
      businessEmail: json['business_email'] as String?,
      businessPhoneNumber:
          (json['business_phone'] ?? json['business_phone_number']) as String?,
      websiteUrl: json['website_url'] as String?,
      authorizedSignatoryFullName:
          json['authorized_signatory_full_name'] as String?,
      authorizedSignatoryJobTitle:
          json['authorized_signatory_job_title'] as String?,
      authorizedSignatoryEmail: json['authorized_signatory_email'] as String?,
      authorizedSignatoryPhoneNumber:
          json['authorized_signatory_phone_number'] as String?,
      authorizedSignatoryIdNumber:
          json['authorized_signatory_id_number'] as String?,
      authorizedSignatoryDateOfBirth:
          json['authorized_signatory_date_of_birth'] as String?,
      beneficialOwners: (json['beneficial_owners'] as List?)
          ?.whereType<Map<String, dynamic>>()
          .toList(),
      preferredSettlementCurrency:
          json['preferred_settlement_currency'] as String?,
      declarationLegalRegistered: json['declaration_legal_registered'] as bool?,
      declarationInformationTrue: json['declaration_information_true'] as bool?,
      declarationAuthorizeVerification:
          json['declaration_authorize_verification'] as bool?,
      authorizeSettlementAccount: json['authorize_settlement_account'] as bool?,
      acceptPartnerBankTerms: json['accept_partner_bank_terms'] as bool?,
      printedNameOfAuthorizedSignatory:
          json['printed_name_of_authorized_signatory'] as String?,
      authorizedSignatorySignature:
          json['authorized_signatory_signature'] as String?,
      submissionDate: json['submission_date'] as String?,
      identityDocument: json['identity_document'] as String?,
      businessRegistrationNumber:
          json['business_registration_number'] as String?,
      businessCertificate: json['business_certificate'] as String?,
      businessLogo: json['business_logo'] as String?,
      bankName: json['bank_name'] as String?,
      accountNumber: json['account_number'] as String?,
    );
  }
}
