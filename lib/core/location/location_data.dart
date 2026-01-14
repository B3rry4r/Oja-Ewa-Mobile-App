import 'package:flutter/foundation.dart';

/// Represents a country with its details
@immutable
class Country {
  const Country({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
  });

  /// Country name (e.g., "Nigeria")
  final String name;

  /// ISO 3166-1 alpha-2 code (e.g., "NG")
  final String code;

  /// Phone dial code (e.g., "+234")
  final String dialCode;

  /// Flag emoji (e.g., "🇳🇬")
  final String flag;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Country &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => '$flag $name ($dialCode)';
}

/// Represents a state/province within a country
@immutable
class StateProvince {
  const StateProvince({
    required this.name,
    required this.code,
    required this.countryCode,
  });

  /// State name (e.g., "Lagos")
  final String name;

  /// State code (e.g., "LA")
  final String code;

  /// Country code this state belongs to (e.g., "NG")
  final String countryCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StateProvince &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          countryCode == other.countryCode;

  @override
  int get hashCode => Object.hash(code, countryCode);

  @override
  String toString() => name;
}
