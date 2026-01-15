import 'package:flutter/foundation.dart';

@immutable
class BusinessStatus {
  const BusinessStatus({required this.id, required this.storeStatus, this.rejectionReason});

  final int id;
  final String storeStatus; // pending|approved|deactivated
  final String? rejectionReason;

  static BusinessStatus fromJson(Map<String, dynamic> json) {
    return BusinessStatus(
      id: (json['id'] as num?)?.toInt() ?? 0,
      storeStatus: (json['store_status'] as String?) ?? '',
      rejectionReason: json['rejection_reason'] as String?,
    );
  }
}
