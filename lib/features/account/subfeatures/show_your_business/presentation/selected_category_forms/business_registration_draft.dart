library;

import 'classes_offered_editor.dart';
import 'service_list_editor.dart';

class BusinessRegistrationDraft {
  BusinessRegistrationDraft({required this.categoryLabel});

  final String categoryLabel;

  int? categoryId;
  int? subcategoryId;

  String? businessName;
  String? legalBusinessName;
  String? tradingName;
  String? businessDescription;
  String? website;
  String? websiteUrl;
  String? businessEmail;
  String? businessPhoneNumber;
  String? instagram;
  String? facebook;
  String? businessRegistrationNumber;
  String? taxIdentificationNumber;
  String? nin;
  String? bvn;
  String? dateOfIncorporation;
  String? countryOfIncorporation;
  String? industrySector;
  String? businessType;
  String? otherBusinessType;
  int? numberOfEmployees;
  String? annualTurnoverRange;
  String? address;
  String? city;
  String? state;
  String? postalCode;
  String? country;
  String? authorizedSignatoryFullName;
  String? authorizedSignatoryJobTitle;
  String? authorizedSignatoryEmail;
  String? authorizedSignatoryPhoneNumber;
  String? authorizedSignatoryIdNumber;
  String? authorizedSignatoryDateOfBirth;
  List<Map<String, dynamic>>? beneficialOwners;
  String? preferredSettlementCurrency;
  bool? declarationLegalRegistered;
  bool? declarationInformationTrue;
  bool? declarationAuthorizeVerification;
  bool? authorizeSettlementAccount;
  bool? acceptPartnerBankTerms;
  String? printedNameOfAuthorizedSignatory;
  String? authorizedSignatorySignaturePath;
  String? submissionDate;

  String? youtube;
  String? spotify;
  String? identityDocumentPath;
  String? offeringType;
  List<String>? productList;
  String? professionalTitle;
  List<ServiceListItem>? serviceList;
  String? schoolType;
  String? schoolBiography;
  List<ClassOfferedItem>? classesOffered;
  String? musicCategory;
  String? businessLogoPath;
  List<Map<String, dynamic>>? businessCertificates;

  Map<String, dynamic> toJson() => {
    'categoryLabel': categoryLabel,
    'categoryId': categoryId,
    'subcategoryId': subcategoryId,
    'businessName': businessName,
    'legalBusinessName': legalBusinessName,
    'tradingName': tradingName,
    'businessDescription': businessDescription,
    'website': website,
    'websiteUrl': websiteUrl,
    'businessEmail': businessEmail,
    'businessPhoneNumber': businessPhoneNumber,
    'instagram': instagram,
    'facebook': facebook,
    'businessRegistrationNumber': businessRegistrationNumber,
    'taxIdentificationNumber': taxIdentificationNumber,
    'nin': nin,
    'bvn': bvn,
    'dateOfIncorporation': dateOfIncorporation,
    'countryOfIncorporation': countryOfIncorporation,
    'industrySector': industrySector,
    'businessType': businessType,
    'otherBusinessType': otherBusinessType,
    'numberOfEmployees': numberOfEmployees,
    'annualTurnoverRange': annualTurnoverRange,
    'address': address,
    'city': city,
    'state': state,
    'postalCode': postalCode,
    'country': country,
    'authorizedSignatoryFullName': authorizedSignatoryFullName,
    'authorizedSignatoryJobTitle': authorizedSignatoryJobTitle,
    'authorizedSignatoryEmail': authorizedSignatoryEmail,
    'authorizedSignatoryPhoneNumber': authorizedSignatoryPhoneNumber,
    'authorizedSignatoryIdNumber': authorizedSignatoryIdNumber,
    'authorizedSignatoryDateOfBirth': authorizedSignatoryDateOfBirth,
    'beneficialOwners': beneficialOwners,
    'preferredSettlementCurrency': preferredSettlementCurrency,
    'declarationLegalRegistered': declarationLegalRegistered,
    'declarationInformationTrue': declarationInformationTrue,
    'declarationAuthorizeVerification': declarationAuthorizeVerification,
    'authorizeSettlementAccount': authorizeSettlementAccount,
    'acceptPartnerBankTerms': acceptPartnerBankTerms,
    'printedNameOfAuthorizedSignatory': printedNameOfAuthorizedSignatory,
    'authorizedSignatorySignaturePath': authorizedSignatorySignaturePath,
    'submissionDate': submissionDate,
    'youtube': youtube,
    'spotify': spotify,
    'identityDocumentPath': identityDocumentPath,
    'offeringType': offeringType,
    'productList': productList,
    'professionalTitle': professionalTitle,
    'serviceList': serviceList?.map((e) => e.toJson()).toList(),
    'schoolType': schoolType,
    'schoolBiography': schoolBiography,
    'classesOffered': classesOffered?.map((e) => e.toJson()).toList(),
    'musicCategory': musicCategory,
    'businessLogoPath': businessLogoPath,
    'businessCertificates': businessCertificates,
  };

  static BusinessRegistrationDraft fromJson(Map<String, dynamic> json) {
    final draft = BusinessRegistrationDraft(
      categoryLabel: (json['categoryLabel'] as String?) ?? 'Beauty',
    );

    draft.categoryId = (json['categoryId'] as num?)?.toInt();
    draft.subcategoryId = (json['subcategoryId'] as num?)?.toInt();
    draft.businessName = json['businessName'] as String?;
    draft.legalBusinessName = json['legalBusinessName'] as String?;
    draft.tradingName = json['tradingName'] as String?;
    draft.businessDescription = json['businessDescription'] as String?;
    draft.website = (json['website'] ?? json['websiteUrl']) as String?;
    draft.websiteUrl = json['websiteUrl'] as String?;
    draft.businessEmail = json['businessEmail'] as String?;
    draft.businessPhoneNumber = json['businessPhoneNumber'] as String?;
    draft.instagram = json['instagram'] as String?;
    draft.facebook = json['facebook'] as String?;
    draft.businessRegistrationNumber =
        json['businessRegistrationNumber'] as String?;
    draft.taxIdentificationNumber = json['taxIdentificationNumber'] as String?;
    draft.nin = json['nin'] as String?;
    draft.bvn = json['bvn'] as String?;
    draft.dateOfIncorporation = json['dateOfIncorporation'] as String?;
    draft.countryOfIncorporation = json['countryOfIncorporation'] as String?;
    draft.industrySector = json['industrySector'] as String?;
    draft.businessType = json['businessType'] as String?;
    draft.otherBusinessType = json['otherBusinessType'] as String?;
    draft.numberOfEmployees = (json['numberOfEmployees'] as num?)?.toInt();
    draft.annualTurnoverRange = json['annualTurnoverRange'] as String?;
    draft.address = json['address'] as String?;
    draft.city = json['city'] as String?;
    draft.state = json['state'] as String?;
    draft.postalCode = json['postalCode'] as String?;
    draft.country = json['country'] as String?;
    draft.authorizedSignatoryFullName =
        json['authorizedSignatoryFullName'] as String?;
    draft.authorizedSignatoryJobTitle =
        json['authorizedSignatoryJobTitle'] as String?;
    draft.authorizedSignatoryEmail =
        json['authorizedSignatoryEmail'] as String?;
    draft.authorizedSignatoryPhoneNumber =
        json['authorizedSignatoryPhoneNumber'] as String?;
    draft.authorizedSignatoryIdNumber =
        json['authorizedSignatoryIdNumber'] as String?;
    draft.authorizedSignatoryDateOfBirth =
        json['authorizedSignatoryDateOfBirth'] as String?;
    draft.beneficialOwners = (json['beneficialOwners'] as List?)
        ?.whereType<Map<String, dynamic>>()
        .toList();
    draft.preferredSettlementCurrency =
        json['preferredSettlementCurrency'] as String?;
    draft.declarationLegalRegistered =
        json['declarationLegalRegistered'] as bool?;
    draft.declarationInformationTrue =
        json['declarationInformationTrue'] as bool?;
    draft.declarationAuthorizeVerification =
        json['declarationAuthorizeVerification'] as bool?;
    draft.authorizeSettlementAccount =
        json['authorizeSettlementAccount'] as bool?;
    draft.acceptPartnerBankTerms = json['acceptPartnerBankTerms'] as bool?;
    draft.printedNameOfAuthorizedSignatory =
        json['printedNameOfAuthorizedSignatory'] as String?;
    draft.authorizedSignatorySignaturePath =
        json['authorizedSignatorySignaturePath'] as String?;
    draft.submissionDate = json['submissionDate'] as String?;

    draft.youtube = json['youtube'] as String?;
    draft.spotify = json['spotify'] as String?;
    draft.identityDocumentPath = json['identityDocumentPath'] as String?;
    draft.offeringType = json['offeringType'] as String?;
    draft.productList = (json['productList'] is List)
        ? (json['productList'] as List).whereType<String>().toList()
        : null;
    draft.professionalTitle = json['professionalTitle'] as String?;
    draft.serviceList = (json['serviceList'] is List)
        ? (json['serviceList'] as List)
              .whereType<Map<String, dynamic>>()
              .map(
                (e) => ServiceListItem(
                  name: (e['name'] as String?) ?? '',
                  priceRange: (e['price_range'] as String?) ?? '',
                ),
              )
              .toList()
        : null;
    draft.schoolType = json['schoolType'] as String?;
    draft.schoolBiography = json['schoolBiography'] as String?;
    draft.classesOffered = (json['classesOffered'] is List)
        ? (json['classesOffered'] as List)
              .whereType<Map<String, dynamic>>()
              .map(
                (e) => ClassOfferedItem(
                  name: (e['name'] as String?) ?? '',
                  duration: (e['duration'] as String?) ?? '',
                ),
              )
              .toList()
        : null;
    draft.musicCategory = json['musicCategory'] as String?;
    draft.businessLogoPath = json['businessLogoPath'] as String?;
    draft.businessCertificates = (json['businessCertificates'] is List)
        ? (json['businessCertificates'] as List)
              .whereType<Map<String, dynamic>>()
              .toList()
        : null;

    return draft;
  }
}
