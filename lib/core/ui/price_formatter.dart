import 'package:intl/intl.dart';
import 'package:ojaewa/core/utils/currency_utils.dart';

/// Formats a price in NGN (legacy default — ₦ symbol, no decimals).
/// Use [formatPriceFx] when you have a currency code.
String formatPrice(num? value, {String symbol = '₦'}) {
  final formatter = NumberFormat.currency(
    locale: 'en_NG',
    symbol: symbol,
    decimalDigits: 0,
  );
  return formatter.format(value ?? 0);
}

/// Formats a price with the correct symbol for the given ISO 4217 currency.
/// NGN uses no decimals (standard Nigerian practice).
/// All other currencies use 2 decimal places.
String formatPriceFx(num? value, String currency) {
  final code = currency.isEmpty ? 'NGN' : currency.toUpperCase();
  final symbol = currencySymbol(code);
  final decimals = code == 'NGN' ? 0 : 2;

  final formatter = NumberFormat.currency(
    locale: code == 'NGN' ? 'en_NG' : 'en_US',
    symbol: symbol,
    decimalDigits: decimals,
  );
  return formatter.format(value ?? 0);
}
