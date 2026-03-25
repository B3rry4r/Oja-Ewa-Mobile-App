import 'package:flutter_test/flutter_test.dart';
import 'package:ojaewa/features/categories/domain/category_items.dart';

void main() {
  group('parseCategoryItem', () {
    test('treats hardware category items as products', () {
      final item = parseCategoryItem('hardware', {
        'id': 901,
        'name': 'Industrial Embroidery Machine',
        'image': 'https://example.com/machine.jpg',
        'price': 850000,
        'avg_rating': 4.8,
      });

      expect(item, isA<CategoryProductItem>());
      final product = item as CategoryProductItem;
      expect(product.id, 901);
      expect(product.name, 'Industrial Embroidery Machine');
      expect(product.price, '850000');
    });
  });
}
