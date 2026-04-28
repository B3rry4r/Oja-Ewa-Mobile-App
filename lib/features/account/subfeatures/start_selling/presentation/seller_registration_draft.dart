class SellerRegistrationDraft {
  SellerRegistrationDraft({
    this.isResubmission = false,
    this.legalBusinessName,
    this.tradingName,
    this.businessRegistrationNumber,
    this.taxIdentificationNumber,
    this.nin,
    this.bvn,
    this.dateOfIncorporation,
    this.countryOfIncorporation,
    this.websiteUrl,
    this.country,
    this.state,
    this.city,
    this.address,
    this.postalCode,
    this.industrySector,
    this.businessType,
    this.otherBusinessType,
    this.numberOfEmployees,
    this.annualTurnoverRange,
    this.businessEmail,
    this.businessName,
    this.businessPhoneNumber,
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
    this.authorizedSignatorySignaturePath,
    this.submissionDate,
    this.identityDocumentPath,
    this.businessCertificatePath,
    this.businessLogoPath,
    this.bankName,
    this.bankCode,
    this.accountNumber,
  });

  bool isResubmission;
  String? legalBusinessName;
  String? tradingName;
  String? businessRegistrationNumber;
  String? taxIdentificationNumber;
  String? nin;
  String? bvn;
  String? dateOfIncorporation;
  String? countryOfIncorporation;
  String? websiteUrl;
  String? country;
  String? state;
  String? city;
  String? address;
  String? postalCode;
  String? industrySector;
  String? businessType;
  String? otherBusinessType;
  int? numberOfEmployees;
  String? annualTurnoverRange;
  String? businessEmail;
  String? businessName;
  String? businessPhoneNumber;
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
  String? identityDocumentPath;
  String? businessCertificatePath;
  String? businessLogoPath;
  String? bankName;
  String? bankCode;
  String? accountNumber;

  Map<String, dynamic> toJson() => {
    'isResubmission': isResubmission,
    'legalBusinessName': legalBusinessName,
    'tradingName': tradingName,
    'businessRegistrationNumber': businessRegistrationNumber,
    'taxIdentificationNumber': taxIdentificationNumber,
    'nin': nin,
    'bvn': bvn,
    'dateOfIncorporation': dateOfIncorporation,
    'countryOfIncorporation': countryOfIncorporation,
    'websiteUrl': websiteUrl,
    'country': country,
    'state': state,
    'city': city,
    'address': address,
    'postalCode': postalCode,
    'industrySector': industrySector,
    'businessType': businessType,
    'otherBusinessType': otherBusinessType,
    'numberOfEmployees': numberOfEmployees,
    'annualTurnoverRange': annualTurnoverRange,
    'businessEmail': businessEmail,
    'businessName': businessName,
    'businessPhoneNumber': businessPhoneNumber,
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
    'identityDocumentPath': identityDocumentPath,
    'businessCertificatePath': businessCertificatePath,
    'businessLogoPath': businessLogoPath,
    'bankName': bankName,
    'bankCode': bankCode,
    'accountNumber': accountNumber,
  };

  static SellerRegistrationDraft fromJson(Map<String, dynamic> json) {
    return SellerRegistrationDraft(
      isResubmission: json['isResubmission'] as bool? ?? false,
      legalBusinessName: json['legalBusinessName'] as String?,
      tradingName: json['tradingName'] as String?,
      businessRegistrationNumber: json['businessRegistrationNumber'] as String?,
      taxIdentificationNumber: json['taxIdentificationNumber'] as String?,
      nin: json['nin'] as String?,
      bvn: json['bvn'] as String?,
      dateOfIncorporation: json['dateOfIncorporation'] as String?,
      countryOfIncorporation: json['countryOfIncorporation'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
      country: json['country'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
      postalCode: json['postalCode'] as String?,
      industrySector: json['industrySector'] as String?,
      businessType: json['businessType'] as String?,
      otherBusinessType: json['otherBusinessType'] as String?,
      numberOfEmployees: (json['numberOfEmployees'] as num?)?.toInt(),
      annualTurnoverRange: json['annualTurnoverRange'] as String?,
      businessEmail: json['businessEmail'] as String?,
      businessName: json['businessName'] as String?,
      businessPhoneNumber: json['businessPhoneNumber'] as String?,
      authorizedSignatoryFullName:
          json['authorizedSignatoryFullName'] as String?,
      authorizedSignatoryJobTitle:
          json['authorizedSignatoryJobTitle'] as String?,
      authorizedSignatoryEmail: json['authorizedSignatoryEmail'] as String?,
      authorizedSignatoryPhoneNumber:
          json['authorizedSignatoryPhoneNumber'] as String?,
      authorizedSignatoryIdNumber:
          json['authorizedSignatoryIdNumber'] as String?,
      authorizedSignatoryDateOfBirth:
          json['authorizedSignatoryDateOfBirth'] as String?,
      beneficialOwners: (json['beneficialOwners'] as List?)
          ?.whereType<Map<String, dynamic>>()
          .toList(),
      preferredSettlementCurrency:
          json['preferredSettlementCurrency'] as String?,
      declarationLegalRegistered: json['declarationLegalRegistered'] as bool?,
      declarationInformationTrue: json['declarationInformationTrue'] as bool?,
      declarationAuthorizeVerification:
          json['declarationAuthorizeVerification'] as bool?,
      authorizeSettlementAccount: json['authorizeSettlementAccount'] as bool?,
      acceptPartnerBankTerms: json['acceptPartnerBankTerms'] as bool?,
      printedNameOfAuthorizedSignatory:
          json['printedNameOfAuthorizedSignatory'] as String?,
      authorizedSignatorySignaturePath:
          json['authorizedSignatorySignaturePath'] as String?,
      submissionDate: json['submissionDate'] as String?,
      identityDocumentPath: json['identityDocumentPath'] as String?,
      businessCertificatePath: json['businessCertificatePath'] as String?,
      businessLogoPath: json['businessLogoPath'] as String?,
      bankName: json['bankName'] as String?,
      bankCode: json['bankCode'] as String?,
      accountNumber: json['accountNumber'] as String?,
    );
  }
}
