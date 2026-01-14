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
    required this.businessEmail,
    required this.businessPhone,
    required this.city,
    required this.state,
    required this.country,
    required this.address,
    required this.instagram,
    required this.facebook,
    required this.websiteUrl,
    required this.classesOffered,
    required this.imageUrl,
    required this.youtube,
    required this.spotify,
    required this.schoolBiography,
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
  final String? businessEmail;
  final String? businessPhone;
  final String? city;
  final String? state;
  final String? country;
  final String? address;
  final String? instagram;
  final String? facebook;
  final String? websiteUrl;
  final List<String> classesOffered;
  final String? imageUrl;
  final String? youtube;
  final String? spotify;
  final String? schoolBiography;

  /// Get formatted location string
  String get location {
    final parts = [city, state, country].where((e) => e != null && e.isNotEmpty).toList();
    return parts.join(', ');
  }

  /// Get full address including street address
  String get fullAddress {
    final parts = [address, city, state, country].where((e) => e != null && e.isNotEmpty).toList();
    return parts.join(', ');
  }

  static List<String> _parseStringList(dynamic raw) {
    if (raw is List) {
      return raw.whereType<String>().toList();
    } else if (raw is String && raw.isNotEmpty) {
      // naive parse for ["A","B"] without adding dependencies
      final cleaned = raw.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '');
      return cleaned.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return const [];
  }

  static BusinessDetails fromWrappedResponse(Map<String, dynamic> json) {
    final data = json['data'];
    final payload = data is Map<String, dynamic> ? data : json;

    return BusinessDetails(
      id: (payload['id'] as num?)?.toInt() ?? 0,
      category: payload['category'] as String?,
      businessName: (payload['business_name'] as String?) ?? '',
      businessDescription: payload['business_description'] as String?,
      offeringType: payload['offering_type'] as String?,
      serviceList: _parseStringList(payload['service_list']),
      professionalTitle: payload['professional_title'] as String?,
      storeStatus: payload['store_status'] as String?,
      subscriptionStatus: payload['subscription_status'] as String?,
      businessEmail: payload['business_email'] as String?,
      businessPhone: payload['business_phone_number'] as String?,
      city: payload['city'] as String?,
      state: payload['state'] as String?,
      country: payload['country'] as String?,
      address: payload['address'] as String?,
      instagram: payload['instagram'] as String?,
      facebook: payload['facebook'] as String?,
      websiteUrl: payload['website_url'] as String?,
      classesOffered: _parseStringList(payload['classes_offered']),
      imageUrl: payload['image'] as String? ?? payload['profile_image'] as String?,
      youtube: payload['youtube'] as String?,
      spotify: payload['spotify'] as String?,
      schoolBiography: payload['school_biography'] as String?,
    );
  }
}

/// Fetches business details - uses ref.read to avoid rebuild loops
final businessDetailsProvider = FutureProvider.family<BusinessDetails, int>((ref, id) async {
  final json = await ref.read(businessDetailsRepositoryProvider).getBusiness(id);
  return BusinessDetails.fromWrappedResponse(json);
});
