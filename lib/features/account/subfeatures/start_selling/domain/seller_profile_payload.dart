import 'package:flutter/foundation.dart';

@immutable
class SellerProfilePayload {
  const SellerProfilePayload({
    required this.country,
    required this.state,
    required this.city,
    required this.address,
    required this.businessEmail,
    required this.businessPhoneNumber,
    this.instagram,
    this.facebook,
    this.identityDocument,
    required this.businessName,
    required this.businessRegistrationNumber,
    this.businessCertificate,
    this.businessLogo,
    required this.bankName,
    required this.accountNumber,
  });

  final String country;
  final String state;
  final String city;
  final String address;

  final String businessEmail;
  final String businessPhoneNumber;

  final String? instagram;
  final String? facebook;

  final String? identityDocument;

  final String businessName;
  final String businessRegistrationNumber;

  final String? businessCertificate;
  final String? businessLogo;

  final String bankName;
  final String accountNumber;

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'state': state,
      'city': city,
      'address': address,
      'business_email': businessEmail,
      'business_phone_number': businessPhoneNumber,
      if (instagram != null && instagram!.isNotEmpty) 'instagram': instagram,
      if (facebook != null && facebook!.isNotEmpty) 'facebook': facebook,
      if (identityDocument != null && identityDocument!.isNotEmpty) 'identity_document': identityDocument,
      'business_name': businessName,
      'business_registration_number': businessRegistrationNumber,
      if (businessCertificate != null && businessCertificate!.isNotEmpty) 'business_certificate': businessCertificate,
      if (businessLogo != null && businessLogo!.isNotEmpty) 'business_logo': businessLogo,
      'bank_name': bankName,
      'account_number': accountNumber,
    };
  }
}
