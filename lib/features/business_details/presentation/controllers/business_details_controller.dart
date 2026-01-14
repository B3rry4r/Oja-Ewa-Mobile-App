import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/business_details_repository_impl.dart';

/// Represents a service offered by a business
@immutable
class ServiceItem {
  const ServiceItem({required this.name, this.priceRange});

  final String name;
  final String? priceRange;

  static ServiceItem fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      name: json['name'] as String? ?? '',
      priceRange: json['price_range'] as String?,
    );
  }
}

/// Represents a class offered by a school
@immutable
class ClassItem {
  const ClassItem({required this.name, this.duration});

  final String name;
  final String? duration;

  static ClassItem fromJson(Map<String, dynamic> json) {
    return ClassItem(
      name: json['name'] as String? ?? '',
      duration: json['duration'] as String?,
    );
  }
}

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
  final List<ServiceItem> serviceList;
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
  final List<ClassItem> classesOffered;
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
      final result = <String>[];
      for (final item in raw) {
        if (item is String) {
          result.add(item);
        } else if (item is Map<String, dynamic>) {
          // Handle objects like {"name": "Makeup", "price": 5000}
          // Extract the name field if available
          final name = item['name'] as String?;
          if (name != null && name.isNotEmpty) {
            result.add(name);
          }
        }
      }
      return result;
    } else if (raw is String && raw.isNotEmpty) {
      // Try to parse as JSON first
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          final result = <String>[];
          for (final item in decoded) {
            if (item is String) {
              result.add(item);
            } else if (item is Map<String, dynamic>) {
              // Handle objects like {"name": "Makeup", "price": 5000}
              final name = item['name'] as String?;
              if (name != null && name.isNotEmpty) {
                result.add(name);
              }
            }
          }
          return result;
        }
      } catch (_) {
        // Not valid JSON, fall through to simple split
      }
      // Simple comma-separated parsing
      final cleaned = raw.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '');
      return cleaned.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return const [];
  }

  static List<ServiceItem> _parseServiceList(dynamic raw) {
    final items = _parseJsonList(raw);
    return items.map((item) {
      if (item is String) {
        return ServiceItem(name: item);
      } else if (item is Map<String, dynamic>) {
        return ServiceItem.fromJson(item);
      }
      return const ServiceItem(name: '');
    }).where((s) => s.name.isNotEmpty).toList();
  }

  static List<ClassItem> _parseClassList(dynamic raw) {
    final items = _parseJsonList(raw);
    return items.map((item) {
      if (item is String) {
        return ClassItem(name: item);
      } else if (item is Map<String, dynamic>) {
        return ClassItem.fromJson(item);
      }
      return const ClassItem(name: '');
    }).where((c) => c.name.isNotEmpty).toList();
  }

  static List<dynamic> _parseJsonList(dynamic raw) {
    if (raw is List) {
      return raw;
    } else if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded;
        }
      } catch (_) {
        // Not valid JSON, fall through to simple split
      }
      // Simple comma-separated parsing (for simple string values)
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
      serviceList: _parseServiceList(payload['service_list']),
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
      classesOffered: _parseClassList(payload['classes_offered']),
      imageUrl: payload['business_logo'] as String? ?? payload['image'] as String? ?? payload['profile_image'] as String?,
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
