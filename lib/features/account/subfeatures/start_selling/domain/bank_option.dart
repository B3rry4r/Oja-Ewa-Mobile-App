import 'package:flutter/foundation.dart';

@immutable
class BankOption {
  const BankOption({
    required this.code,
    required this.name,
    this.country,
  });

  final String code;
  final String name;
  final String? country;

  static BankOption fromJson(Map<String, dynamic> json) {
    return BankOption(
      code: (json['code'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      country: json['country'] as String?,
    );
  }
}
