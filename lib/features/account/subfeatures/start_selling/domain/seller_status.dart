import 'package:flutter/foundation.dart';

@immutable
class SellerStatus {
  const SellerStatus({
    required this.registrationStatus,
    required this.active,
    this.rejectionReason,
    this.businessName,
    this.badge,
  });

  final String registrationStatus; // pending|approved|rejected
  final bool active;
  final String? rejectionReason;
  final String? businessName;
  final String? badge;

  bool get isApprovedAndActive => registrationStatus == 'approved' && active;

  static SellerStatus fromJson(Map<String, dynamic> json) {
    return SellerStatus(
      registrationStatus: (json['registration_status'] as String?) ?? '',
      active: (json['active'] as bool?) ?? false,
      rejectionReason: json['rejection_reason'] as String?,
      businessName: json['business_name'] as String?,
      badge: json['badge'] as String?,
    );
  }
}
