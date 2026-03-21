import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ojaewa/core/errors/app_exception.dart';
import 'package:ojaewa/features/cart/data/cart_api.dart';

void main() {
  group('CartApi', () {
    late _MockDio dio;
    late CartApi api;

    setUp(() {
      dio = _MockDio();
      api = CartApi(dio);
    });

    test('getCart parses wrapped cart payload', () async {
      when(() => dio.get('/api/cart')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/cart'),
          data: {
            'data': {
              'cart_id': 1,
              'total': 80,
              'items_count': 2,
              'items': [
                {
                  'id': 10,
                  'product_id': 100,
                  'quantity': 2,
                  'unit_price': 25,
                  'subtotal': 50,
                  'selected_size': 'S',
                  'processing_time_type': 'normal',
                  'product': {'id': 100, 'name': 'Dress', 'price': 25},
                },
              ],
            },
          },
        ),
      );

      final cart = await api.getCart();

      expect(cart.cartId, 1);
      expect(cart.total, 80);
      expect(cart.itemsCount, 2);
      expect(cart.items.single.product.name, 'Dress');
    });

    test('addItem returns cart from inline payload when response already contains items', () async {
      when(
        () => dio.post(
          '/api/cart/items',
          data: {
            'product_id': 100,
            'quantity': 1,
            'selected_size': 'M',
            'processing_time_type': 'express',
          },
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/cart/items'),
          data: {
            'items': [
              {
                'id': 10,
                'product_id': 100,
                'quantity': 1,
                'unit_price': 25,
                'subtotal': 25,
                'selected_size': 'M',
                'processing_time_type': 'express',
                'product': {'id': 100, 'name': 'Dress', 'price': 25},
              },
            ],
            'cart_id': 2,
            'total': 25,
            'items_count': 1,
          },
        ),
      );

      final cart = await api.addItem(
        productId: 100,
        quantity: 1,
        selectedSize: 'M',
        processingTimeType: 'express',
      );

      expect(cart.cartId, 2);
      expect(cart.items.single.selectedSize, 'M');
      verifyNever(() => dio.get('/api/cart'));
    });

    test('addItem falls back to getCart when create response has no cart payload', () async {
      when(
        () => dio.post(
          '/api/cart/items',
          data: {
            'product_id': 100,
            'quantity': 1,
            'selected_size': 'S',
            'processing_time_type': 'normal',
          },
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/cart/items'),
          data: {'message': 'Added'},
        ),
      );
      when(() => dio.get('/api/cart')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/cart'),
          data: {
            'data': {
              'cart_id': 3,
              'total': 25,
              'items_count': 1,
              'items': [
                {
                  'id': 11,
                  'product_id': 100,
                  'quantity': 1,
                  'unit_price': 25,
                  'subtotal': 25,
                  'selected_size': 'S',
                  'processing_time_type': 'normal',
                  'product': {'id': 100, 'name': 'Dress', 'price': 25},
                },
              ],
            },
          },
        ),
      );

      final cart = await api.addItem(
        productId: 100,
        quantity: 1,
        selectedSize: 'S',
      );

      expect(cart.cartId, 3);
      verify(() => dio.get('/api/cart')).called(1);
    });

    test('updateItemQuantity patches then refreshes cart', () async {
      when(
        () => dio.patch('/api/cart/items/10', data: {'quantity': 4}),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/cart/items/10'),
          data: const {},
        ),
      );
      when(() => dio.get('/api/cart')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/cart'),
          data: {
            'data': {
              'cart_id': 1,
              'total': 100,
              'items_count': 1,
              'items': [
                {
                  'id': 10,
                  'product_id': 100,
                  'quantity': 4,
                  'unit_price': 25,
                  'subtotal': 100,
                  'selected_size': 'S',
                  'processing_time_type': 'normal',
                  'product': {'id': 100, 'name': 'Dress', 'price': 25},
                },
              ],
            },
          },
        ),
      );

      final cart = await api.updateItemQuantity(cartItemId: 10, quantity: 4);

      expect(cart.items.single.quantity, 4);
      verify(() => dio.patch('/api/cart/items/10', data: {'quantity': 4})).called(1);
      verify(() => dio.get('/api/cart')).called(1);
    });

    test('maps delete errors to AppException', () async {
      when(() => dio.delete('/api/cart')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/cart'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/cart'),
            statusCode: 500,
            data: {'message': 'Internal error'},
          ),
        ),
      );

      expect(
        () => api.clearCart(),
        throwsA(
          isA<ServerException>().having(
            (error) => error.message,
            'message',
            'Server error. Please try again.',
          ),
        ),
      );
    });
  });
}

class _MockDio extends Mock implements Dio {}
