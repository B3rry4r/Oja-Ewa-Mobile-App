class SellerRegistrationDraft {
  SellerRegistrationDraft({
    this.country,
    this.state,
    this.city,
    this.address,
    this.businessEmail,
    this.businessPhoneNumber,
    this.instagram,
    this.facebook,
    this.identityDocumentPath,
    this.businessName,
    this.businessRegistrationNumber,
    this.businessCertificatePath,
    this.businessLogoPath,
    this.bankName,
    this.accountNumber,
  });

  String? country;
  String? state;
  String? city;
  String? address;

  String? businessEmail;
  String? businessPhoneNumber;

  String? instagram;
  String? facebook;

  String? identityDocumentPath;

  String? businessName;
  String? businessRegistrationNumber;
  String? businessCertificatePath;
  String? businessLogoPath;

  String? bankName;
  String? accountNumber;

  Map<String, dynamic> toJson() => {
        'country': country,
        'state': state,
        'city': city,
        'address': address,
        'businessEmail': businessEmail,
        'businessPhoneNumber': businessPhoneNumber,
        'instagram': instagram,
        'facebook': facebook,
        'identityDocumentPath': identityDocumentPath,
        'businessName': businessName,
        'businessRegistrationNumber': businessRegistrationNumber,
        'businessCertificatePath': businessCertificatePath,
        'businessLogoPath': businessLogoPath,
        'bankName': bankName,
        'accountNumber': accountNumber,
      };

  static SellerRegistrationDraft fromJson(Map<String, dynamic> json) {
    return SellerRegistrationDraft(
      country: json['country'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
      businessEmail: json['businessEmail'] as String?,
      businessPhoneNumber: json['businessPhoneNumber'] as String?,
      instagram: json['instagram'] as String?,
      facebook: json['facebook'] as String?,
      identityDocumentPath: json['identityDocumentPath'] as String?,
      businessName: json['businessName'] as String?,
      businessRegistrationNumber: json['businessRegistrationNumber'] as String?,
      businessCertificatePath: json['businessCertificatePath'] as String?,
      businessLogoPath: json['businessLogoPath'] as String?,
      bankName: json['bankName'] as String?,
      accountNumber: json['accountNumber'] as String?,
    );
  }
}
