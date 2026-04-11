import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../presentation/selected_category_forms/classes_offered_editor.dart';
import '../presentation/selected_category_forms/service_list_editor.dart';

@immutable
class BusinessProfilePayload {
  const BusinessProfilePayload({
    required this.category,
    required this.categoryId,
    required this.subcategoryId,
    required this.businessName,
    this.legalBusinessName,
    this.tradingName,
    required this.businessDescription,
    this.website,
    this.websiteUrl,
    required this.businessEmail,
    required this.businessPhoneNumber,
    this.businessRegistrationNumber,
    this.taxIdentificationNumber,
    this.dateOfIncorporation,
    this.countryOfIncorporation,
    this.industrySector,
    this.businessType,
    this.otherBusinessType,
    this.numberOfEmployees,
    this.annualTurnoverRange,
    required this.address,
    required this.city,
    required this.state,
    this.postalCode,
    required this.country,
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
    this.businessLogo,
    this.instagram,
    this.facebook,
    this.offeringType,
    this.productList,
    this.serviceList,
    this.businessCertificates,
    this.professionalTitle,
    this.schoolType,
    this.schoolBiography,
    this.classesOffered,
    this.musicCategory,
    this.youtube,
    this.spotify,
  });

  final String category;
  final int categoryId;
  final int subcategoryId;
  final String businessName;
  final String? legalBusinessName;
  final String? tradingName;
  final String businessDescription;
  final String? website;
  final String? websiteUrl;
  final String businessEmail;
  final String businessPhoneNumber;
  final String? businessRegistrationNumber;
  final String? taxIdentificationNumber;
  final String? dateOfIncorporation;
  final String? countryOfIncorporation;
  final String? industrySector;
  final String? businessType;
  final String? otherBusinessType;
  final int? numberOfEmployees;
  final String? annualTurnoverRange;
  final String address;
  final String city;
  final String state;
  final String? postalCode;
  final String country;
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
  final String? businessLogo;
  final String? instagram;
  final String? facebook;
  final String? offeringType;
  final List<String>? productList;
  final List<ServiceListItem>? serviceList;
  final List<Map<String, dynamic>>? businessCertificates;
  final String? professionalTitle;
  final String? schoolType;
  final String? schoolBiography;
  final List<ClassOfferedItem>? classesOffered;
  final String? musicCategory;
  final String? youtube;
  final String? spotify;

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'category_id': categoryId,
      'subcategory_id': subcategoryId,
      'business_name': businessName,
      if (legalBusinessName != null && legalBusinessName!.isNotEmpty)
        'legal_business_name': legalBusinessName,
      if (tradingName != null && tradingName!.isNotEmpty)
        'trading_name': tradingName,
      'business_description': businessDescription,
      if ((website ?? websiteUrl) != null &&
          (website ?? websiteUrl)!.isNotEmpty)
        'website': website ?? websiteUrl,
      'business_email': businessEmail,
      'business_phone': businessPhoneNumber,
      if (businessRegistrationNumber != null &&
          businessRegistrationNumber!.isNotEmpty)
        'business_registration_number': businessRegistrationNumber,
      if (taxIdentificationNumber != null &&
          taxIdentificationNumber!.isNotEmpty)
        'tax_identification_number': taxIdentificationNumber,
      if (dateOfIncorporation != null && dateOfIncorporation!.isNotEmpty)
        'date_of_incorporation': dateOfIncorporation,
      if (countryOfIncorporation != null && countryOfIncorporation!.isNotEmpty)
        'country_of_incorporation': countryOfIncorporation,
      if (industrySector != null && industrySector!.isNotEmpty)
        'industry_sector': industrySector,
      if (businessType != null && businessType!.isNotEmpty)
        'business_type': businessType,
      if (otherBusinessType != null && otherBusinessType!.isNotEmpty)
        'other_business_type': otherBusinessType,
      if (numberOfEmployees != null) 'number_of_employees': numberOfEmployees,
      if (annualTurnoverRange != null && annualTurnoverRange!.isNotEmpty)
        'annual_turnover_range': annualTurnoverRange,
      'address': address,
      'city': city,
      'state': state,
      if (postalCode != null && postalCode!.isNotEmpty)
        'postal_code': postalCode,
      'country': country,
      if (authorizedSignatoryFullName != null &&
          authorizedSignatoryFullName!.isNotEmpty)
        'authorized_signatory_full_name': authorizedSignatoryFullName,
      if (authorizedSignatoryJobTitle != null &&
          authorizedSignatoryJobTitle!.isNotEmpty)
        'authorized_signatory_job_title': authorizedSignatoryJobTitle,
      if (authorizedSignatoryEmail != null &&
          authorizedSignatoryEmail!.isNotEmpty)
        'authorized_signatory_email': authorizedSignatoryEmail,
      if (authorizedSignatoryPhoneNumber != null &&
          authorizedSignatoryPhoneNumber!.isNotEmpty)
        'authorized_signatory_phone_number': authorizedSignatoryPhoneNumber,
      if (authorizedSignatoryIdNumber != null &&
          authorizedSignatoryIdNumber!.isNotEmpty)
        'authorized_signatory_id_number': authorizedSignatoryIdNumber,
      if (authorizedSignatoryDateOfBirth != null &&
          authorizedSignatoryDateOfBirth!.isNotEmpty)
        'authorized_signatory_date_of_birth': authorizedSignatoryDateOfBirth,
      if (beneficialOwners != null && beneficialOwners!.isNotEmpty)
        'beneficial_owners': beneficialOwners,
      if (preferredSettlementCurrency != null &&
          preferredSettlementCurrency!.isNotEmpty)
        'preferred_settlement_currency': preferredSettlementCurrency,
      if (declarationLegalRegistered != null)
        'declaration_legal_registered': declarationLegalRegistered,
      if (declarationInformationTrue != null)
        'declaration_information_true': declarationInformationTrue,
      if (declarationAuthorizeVerification != null)
        'declaration_authorize_verification': declarationAuthorizeVerification,
      if (authorizeSettlementAccount != null)
        'authorize_settlement_account': authorizeSettlementAccount,
      if (acceptPartnerBankTerms != null)
        'accept_partner_bank_terms': acceptPartnerBankTerms,
      if (printedNameOfAuthorizedSignatory != null &&
          printedNameOfAuthorizedSignatory!.isNotEmpty)
        'printed_name_of_authorized_signatory':
            printedNameOfAuthorizedSignatory,
      if (submissionDate != null && submissionDate!.isNotEmpty)
        'submission_date': submissionDate,
      if (authorizedSignatorySignature != null &&
          authorizedSignatorySignature!.isNotEmpty)
        'authorized_signatory_signature': authorizedSignatorySignature,
      if (instagram != null && instagram!.isNotEmpty) 'instagram': instagram,
      if (facebook != null && facebook!.isNotEmpty) 'facebook': facebook,
      if (offeringType != null && offeringType!.isNotEmpty)
        'offering_type': offeringType,
      if (productList != null && productList!.isNotEmpty)
        'product_list': jsonEncode(productList),
      if (serviceList != null && serviceList!.isNotEmpty)
        'service_list': jsonEncode(
          serviceList!.map((e) => e.toJson()).toList(),
        ),
      if (professionalTitle != null && professionalTitle!.isNotEmpty)
        'professional_title': professionalTitle,
      if (schoolType != null && schoolType!.isNotEmpty)
        'school_type': schoolType,
      if (schoolBiography != null && schoolBiography!.isNotEmpty)
        'school_biography': schoolBiography,
      if (classesOffered != null && classesOffered!.isNotEmpty)
        'classes_offered': jsonEncode(
          classesOffered!.map((e) => e.toJson()).toList(),
        ),
      if (musicCategory != null && musicCategory!.isNotEmpty)
        'music_category': musicCategory,
      if (youtube != null && youtube!.isNotEmpty) 'youtube': youtube,
      if (spotify != null && spotify!.isNotEmpty) 'spotify': spotify,
    };
  }
}
