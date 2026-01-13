import 'package:flutter/foundation.dart';

@immutable
class ConnectInfo {
  const ConnectInfo({
    required this.socialLinks,
    required this.contact,
    required this.appLinks,
  });

  final Map<String, String> socialLinks;
  final Map<String, String> contact;
  final Map<String, String> appLinks;

  static ConnectInfo fromJson(Map<String, dynamic> json) {
    Map<String, String> toStringMap(dynamic v) {
      if (v is Map<String, dynamic>) {
        return v.map((k, val) => MapEntry(k, val?.toString() ?? ''));
      }
      return const {};
    }

    final data = (json['data'] is Map<String, dynamic>) ? (json['data'] as Map<String, dynamic>) : json;

    return ConnectInfo(
      socialLinks: toStringMap(data['social_links']),
      contact: toStringMap(data['contact']),
      appLinks: toStringMap(data['app_links']),
    );
  }
}
