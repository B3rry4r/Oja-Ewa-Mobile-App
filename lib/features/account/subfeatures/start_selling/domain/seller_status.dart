import 'package:flutter/foundation.dart';

@immutable
class SellerStatus {
  const SellerStatus({
    this.id,
    required this.registrationStatus,
    required this.active,
    this.rejectionReason,
    this.businessName,
    this.badge,
    this.country,
    this.state,
    this.city,
    this.address,
    this.businessEmail,
    this.businessPhoneNumber,
    this.instagram,
    this.facebook,
    this.identityDocument,
    this.businessRegistrationNumber,
    this.businessCertificate,
    this.businessLogo,
    this.bankName,
    this.accountNumber,
  });

  final int? id;
  final String registrationStatus; // pending|approved|rejected
  final bool active;
  final String? rejectionReason;
  final String? businessName;
  final String? badge;
  final String? country;
  final String? state;
  final String? city;
  final String? address;
  final String? businessEmail;
  final String? businessPhoneNumber;
  final String? instagram;
  final String? facebook;
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
      badge: json['badge'] as String?,
      country: json['country'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
      businessEmail: json['business_email'] as String?,
      businessPhoneNumber: json['business_phone_number'] as String?,
      instagram: json['instagram'] as String?,
      facebook: json['facebook'] as String?,
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
