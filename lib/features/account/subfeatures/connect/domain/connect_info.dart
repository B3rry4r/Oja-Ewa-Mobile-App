import 'package:flutter/foundation.dart';

@immutable
class ConnectInfo {
  const ConnectInfo({
    required this.email,
    required this.phone,
    required this.instagram,
  });

  final String email;
  final String phone;
  final String instagram;

  static ConnectInfo fromJson(Map<String, dynamic> json) {
    final data = (json['data'] is Map<String, dynamic>) ? (json['data'] as Map<String, dynamic>) : json;

    return ConnectInfo(
      email: (data['email'] as String?) ?? '',
      phone: (data['phone'] as String?) ?? '',
      instagram: (data['instagram'] as String?) ?? '',
    );
  }
}
