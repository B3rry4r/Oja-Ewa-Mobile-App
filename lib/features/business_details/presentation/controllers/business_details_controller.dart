import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/business_details_repository_impl.dart';

@immutable
class BusinessDetails {
  const BusinessDetails({
    required this.id,
    required this.category,
    required this.businessName,
    required this.businessDescription,
    required this.offeringType,
    required this.serviceList,
    required this.professionalTitle,
    required this.storeStatus,
    required this.subscriptionStatus,
  });

  final int id;
  final String? category;
  final String businessName;
  final String? businessDescription;
  final String? offeringType;
  final List<String> serviceList;
  final String? professionalTitle;
  final String? storeStatus;
  final String? subscriptionStatus;

  static BusinessDetails fromWrappedResponse(Map<String, dynamic> json) {
    final data = json['data'];
    final payload = data is Map<String, dynamic> ? data : json;

    final rawServices = payload['service_list'];
    // Backend sometimes stores as JSON string.
    List<String> services = const [];
    if (rawServices is List) {
      services = rawServices.whereType<String>().toList();
    } else if (rawServices is String) {
      // naive parse for ["A","B"] without adding dependencies
      final cleaned = rawServices.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '');
      services = cleaned.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }

    return BusinessDetails(
      id: (payload['id'] as num?)?.toInt() ?? 0,
      category: payload['category'] as String?,
      businessName: (payload['business_name'] as String?) ?? '',
      businessDescription: payload['business_description'] as String?,
      offeringType: payload['offering_type'] as String?,
      serviceList: services,
      professionalTitle: payload['professional_title'] as String?,
      storeStatus: payload['store_status'] as String?,
      subscriptionStatus: payload['subscription_status'] as String?,
    );
  }
}

final businessDetailsProvider = FutureProvider.family<BusinessDetails, int>((ref, id) async {
  final json = await ref.watch(businessDetailsRepositoryProvider).getBusiness(id);
  return BusinessDetails.fromWrappedResponse(json);
});
