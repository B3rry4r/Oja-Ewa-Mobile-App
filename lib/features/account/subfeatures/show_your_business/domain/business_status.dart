import 'package:flutter/foundation.dart';

@immutable
class BusinessStatus {
  const BusinessStatus({
    required this.id,
    required this.businessName,
    required this.category,
    required this.storeStatus,
    this.rejectionReason,
  });

  final int id;
  final String businessName;
  final String category;
  final String storeStatus; // pending|approved|deactivated
  final String? rejectionReason;

  static BusinessStatus fromJson(Map<String, dynamic> json) {
    return BusinessStatus(
      id: (json['id'] as num?)?.toInt() ?? 0,
      businessName: (json['business_name'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
      storeStatus: (json['store_status'] as String?) ?? '',
      rejectionReason: json['rejection_reason'] as String?,
    );
  }
}
