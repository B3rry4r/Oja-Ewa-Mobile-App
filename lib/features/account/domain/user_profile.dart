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
    this.phoneCarrier,
    this.isMtnUser,
    this.mtnDiscountEligible,
  });

  final int id;
  final String firstname;
  final String lastname;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String? phoneCarrier;
  final bool? isMtnUser;
  final bool? mtnDiscountEligible;

  String get fullName => [firstname, lastname].where((p) => p.trim().isNotEmpty).join(' ');
  
  /// Whether user is eligible for MTN subscriber discount
  bool get isEligibleForMtnDiscount => mtnDiscountEligible ?? isMtnUser ?? false;

  static UserProfile fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as num?)?.toInt() ?? 0;
    final firstname = (json['firstname'] as String?) ?? '';
    final lastname = (json['lastname'] as String?) ?? '';
    final email = (json['email'] as String?) ?? '';
    final phone = (json['phone'] as String?) ?? (json['phone_number'] as String?);
    final avatarUrl = (json['avatar_url'] as String?) ?? (json['avatar'] as String?);
    final phoneCarrier = json['phone_carrier'] as String?;
    final isMtnUser = json['is_mtn_user'] as bool?;
    final mtnDiscountEligible = json['mtn_discount_eligible'] as bool?;

    return UserProfile(
      id: id,
      firstname: firstname,
      lastname: lastname,
      email: email,
      phone: phone,
      avatarUrl: avatarUrl,
      phoneCarrier: phoneCarrier,
      isMtnUser: isMtnUser,
      mtnDiscountEligible: mtnDiscountEligible,
    );
  }

  UserProfile copyWith({
    String? firstname,
    String? lastname,
    String? email,
    String? phone,
    String? avatarUrl,
    String? phoneCarrier,
    bool? isMtnUser,
    bool? mtnDiscountEligible,
  }) {
    return UserProfile(
      id: id,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneCarrier: phoneCarrier ?? this.phoneCarrier,
      isMtnUser: isMtnUser ?? this.isMtnUser,
      mtnDiscountEligible: mtnDiscountEligible ?? this.mtnDiscountEligible,
    );
  }
}
