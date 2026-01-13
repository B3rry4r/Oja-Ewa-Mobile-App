import 'package:flutter/foundation.dart';

@immutable
class UserProfile {
  const UserProfile({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    this.phone,
    this.avatarUrl,
  });

  final int id;
  final String firstname;
  final String lastname;
  final String email;
  final String? phone;
  final String? avatarUrl;

  String get fullName => [firstname, lastname].where((p) => p.trim().isNotEmpty).join(' ');

  static UserProfile fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as num?)?.toInt() ?? 0;
    final firstname = (json['firstname'] as String?) ?? '';
    final lastname = (json['lastname'] as String?) ?? '';
    final email = (json['email'] as String?) ?? '';
    final phone = (json['phone'] as String?) ?? (json['phone_number'] as String?);
    final avatarUrl = (json['avatar_url'] as String?) ?? (json['avatar'] as String?);

    return UserProfile(
      id: id,
      firstname: firstname,
      lastname: lastname,
      email: email,
      phone: phone,
      avatarUrl: avatarUrl,
    );
  }

  UserProfile copyWith({
    String? firstname,
    String? lastname,
    String? email,
    String? phone,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
