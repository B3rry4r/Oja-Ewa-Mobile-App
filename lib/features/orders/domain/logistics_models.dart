import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../account/subfeatures/your_address/domain/address.dart';

@immutable
class ShippingQuote {
  const ShippingQuote({
    required this.quoteReference,
    required this.provider,
    required this.serviceCode,
    required this.serviceName,
    required this.amount,
    required this.currency,
    required this.estimatedDays,
    required this.expiresAt,
  });

  final String quoteReference;
  final String provider;
  final String serviceCode;
  final String serviceName;
  final num amount;
  final String currency;
  final int? estimatedDays;
  final DateTime? expiresAt;

  static num _parseNum(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }

  static ShippingQuote fromJson(Map<String, dynamic> json) {
    return ShippingQuote(
      quoteReference: (json['quote_reference'] as String?) ?? '',
      provider: (json['provider'] as String?) ?? '',
      serviceCode: (json['service_code'] as String?) ?? '',
      serviceName: (json['service_name'] as String?) ?? '',
      amount: _parseNum(json['amount']),
      currency: (json['currency'] as String?) ?? 'NGN',
      estimatedDays: _parseNum(json['estimated_days']).toInt(),
      expiresAt: DateTime.tryParse((json['expires_at'] as String?) ?? ''),
    );
  }
}

@immutable
class SellerShippingQuotes {
  const SellerShippingQuotes({
    required this.sellerProfileId,
    required this.quotes,
  });

  final int sellerProfileId;
  final List<ShippingQuote> quotes;

  static num _parseNum(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }

  static SellerShippingQuotes fromJson(Map<String, dynamic> json) {
    final rawQuotes = json['quotes'];
    return SellerShippingQuotes(
      sellerProfileId: _parseNum(json['seller_profile_id']).toInt(),
      quotes: rawQuotes is List
          ? rawQuotes
                .whereType<Map>()
                .map(
                  (quote) =>
                      ShippingQuote.fromJson(Map<String, dynamic>.from(quote)),
                )
                .toList()
          : const [],
    );
  }
}

@immutable
class SelectedShippingQuote {
  const SelectedShippingQuote({
    required this.sellerProfileId,
    required this.quoteReference,
  });

  final int sellerProfileId;
  final String quoteReference;

  Map<String, dynamic> toJson() {
    return {
      'seller_profile_id': sellerProfileId,
      'quote_reference': quoteReference,
    };
  }
}

@immutable
class LogisticsQuoteRequest {
  const LogisticsQuoteRequest._({
    required this.items,
    required this.addressId,
    required this.shippingName,
    required this.shippingPhone,
    required this.shippingAddress,
    required this.shippingCity,
    required this.shippingState,
    required this.shippingCountry,
    required this.shippingZipCode,
    required this.cacheKey,
  });

  factory LogisticsQuoteRequest.fromAddress({
    required List<Map<String, dynamic>> items,
    required Address address,
  }) {
    final payload = {'items': items, 'address_id': address.id};
    return LogisticsQuoteRequest._(
      items: items,
      addressId: address.id,
      shippingName: address.fullName,
      shippingPhone: address.phone,
      shippingAddress: address.addressLine,
      shippingCity: address.city,
      shippingState: address.state,
      shippingCountry: address.country,
      shippingZipCode: address.postCode,
      cacheKey: jsonEncode(payload),
    );
  }

  final List<Map<String, dynamic>> items;
  final int? addressId;
  final String? shippingName;
  final String? shippingPhone;
  final String? shippingAddress;
  final String? shippingCity;
  final String? shippingState;
  final String? shippingCountry;
  final String? shippingZipCode;
  final String cacheKey;

  Map<String, dynamic> toJson() {
    return {
      'items': items,
      if (addressId != null) 'address_id': addressId,
      if (addressId == null && shippingName != null)
        'shipping_name': shippingName,
      if (addressId == null && shippingPhone != null)
        'shipping_phone': shippingPhone,
      if (addressId == null && shippingAddress != null)
        'shipping_address': shippingAddress,
      if (addressId == null && shippingCity != null)
        'shipping_city': shippingCity,
      if (addressId == null && shippingState != null)
        'shipping_state': shippingState,
      if (addressId == null && shippingCountry != null)
        'shipping_country': shippingCountry,
      if (addressId == null && shippingZipCode != null)
        'shipping_zip_code': shippingZipCode,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogisticsQuoteRequest && other.cacheKey == cacheKey;

  @override
  int get hashCode => cacheKey.hashCode;
}
