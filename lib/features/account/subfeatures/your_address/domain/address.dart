import 'package:flutter/foundation.dart';

@immutable
class Address {
  const Address({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.country,
    required this.state,
    required this.city,
    required this.postCode,
    required this.addressLine,
    this.isDefault = false,
  });

  final int id;
  final String fullName;
  final String phone;
  final String country;
  final String state;
  final String city;
  final String postCode;
  final String addressLine;
  final bool isDefault;

  static Address fromJson(Map<String, dynamic> json) {
    return Address(
      id: (json['id'] as num?)?.toInt() ?? 0,
      fullName: (json['full_name'] as String?) ?? (json['name'] as String?) ?? '',
      phone: (json['phone_number'] as String?) ?? (json['phone'] as String?) ?? '',
      country: (json['country'] as String?) ?? '',
      state: (json['state'] as String?) ?? '',
      city: (json['city'] as String?) ?? '',
      postCode: (json['zip_code'] as String?) ?? (json['post_code'] as String?) ?? (json['postal_code'] as String?) ?? '',
      addressLine: (json['address'] as String?) ?? (json['address_line'] as String?) ?? '',
      isDefault: (json['is_default'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'full_name': fullName,
      'phone_number': phone,
      'state': state,
      'city': city,
      'zip_code': postCode,
      'address': addressLine,
      'is_default': isDefault,
    };
  }

  Address copyWith({
    int? id,
    String? fullName,
    String? phone,
    String? country,
    String? state,
    String? city,
    String? postCode,
    String? addressLine,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      state: state ?? this.state,
      city: city ?? this.city,
      postCode: postCode ?? this.postCode,
      addressLine: addressLine ?? this.addressLine,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
