import 'package:intl/intl.dart';

/// Formats a number into a NGN price string with comma separators.
/// Example: 1000000 -> ₦1,000,000
String formatPrice(num? value, {String symbol = '₦'}) {
  final formatter = NumberFormat.currency(
    locale: 'en_NG',
    symbol: symbol,
    decimalDigits: 0,
  );
  return formatter.format(value ?? 0);
}
