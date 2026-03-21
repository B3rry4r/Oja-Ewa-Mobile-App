import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ojaewa/core/errors/app_exception.dart';
import 'package:ojaewa/features/orders/data/payments_api.dart';

void main() {
  group('PaymentsApi', () {
    late _MockDio dio;
    late PaymentsApi api;

    setUp(() {
      dio = _MockDio();
      api = PaymentsApi(dio);
    });

    test(
      'createOrderPaymentLink posts callback payload and parses wrapped data',
      () async {
        when(
          () => dio.post(
            '/api/payment/link',
            data: {'order_id': 44, 'callback_url': PaymentsApi.callbackUrl},
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/api/payment/link'),
            data: {
              'data': {
                'payment_url': 'https://pay.example/44',
                'access_code': 'access-44',
                'reference': 'ref-44',
                'amount': '12000',
                'currency': 'GHS',
              },
            },
          ),
        );

        final result = await api.createOrderPaymentLink(orderId: 44);

        expect(result.paymentUrl, 'https://pay.example/44');
        expect(result.accessCode, 'access-44');
        expect(result.reference, 'ref-44');
        expect(result.amount, 12000);
        expect(result.currency, 'GHS');
        verify(
          () => dio.post(
            '/api/payment/link',
            data: {'order_id': 44, 'callback_url': PaymentsApi.callbackUrl},
          ),
        ).called(1);
      },
    );

    test('verify posts reference and parses wrapped data', () async {
      when(
        () =>
            dio.post('/api/payment/verify', data: {'reference': 'pay-ref-77'}),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/payment/verify'),
          data: {
            'data': {
              'order_id': 77,
              'payment_status': 'success',
              'amount': 4500,
              'currency': 'NGN',
              'paid_at': '2026-03-13T12:00:00Z',
            },
          },
        ),
      );

      final result = await api.verify(reference: 'pay-ref-77');

      expect(result.orderId, 77);
      expect(result.status, 'success');
      expect(result.amount, 4500);
      expect(result.currency, 'NGN');
      expect(result.paidAt, DateTime.parse('2026-03-13T12:00:00Z'));
      verify(
        () =>
            dio.post('/api/payment/verify', data: {'reference': 'pay-ref-77'}),
      ).called(1);
    });

    test('maps server failures into AppException', () async {
      when(
        () => dio.post('/api/payment/verify', data: {'reference': 'bad-ref'}),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/payment/verify'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/payment/verify'),
            statusCode: 500,
            data: {'message': 'Internal Server Error'},
          ),
        ),
      );

      expect(
        () => api.verify(reference: 'bad-ref'),
        throwsA(
          isA<ServerException>()
              .having(
                (error) => error.message,
                'message',
                'Server error. Please try again.',
              )
              .having((error) => error.code, 'code', '500'),
        ),
      );
    });
  });
}

class _MockDio extends Mock implements Dio {}
