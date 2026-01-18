import 'package:flutter_test/flutter_test.dart';

/// Helper function to safely parse numeric values from dynamic data
num? parseNum(dynamic v) {
  if (v is num) return v;
  if (v is String) return num.tryParse(v);
  return null;
}

void main() {
  group('Price Parsing Tests', () {
    test('should parse string prices correctly', () {
      // Test the problematic case from the error message
      expect(parseNum('130326.79'), equals(130326.79));
      expect(parseNum('1000'), equals(1000));
      expect(parseNum('0'), equals(0));
      expect(parseNum('999.99'), equals(999.99));
    });

    test('should handle numeric values correctly', () {
      expect(parseNum(130326.79), equals(130326.79));
      expect(parseNum(1000), equals(1000));
      expect(parseNum(0), equals(0));
    });

    test('should handle invalid values gracefully', () {
      expect(parseNum('invalid'), isNull);
      expect(parseNum(''), isNull);
      expect(parseNum(null), isNull);
      expect(parseNum({}), isNull);
      expect(parseNum([]), isNull);
    });
  });
}