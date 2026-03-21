import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ojaewa/core/auth/auth_providers.dart';
import 'package:ojaewa/features/orders/data/orders_repository_impl.dart';
import 'package:ojaewa/features/orders/domain/logistics_models.dart';
import 'package:ojaewa/features/orders/domain/order_models.dart';
import 'package:ojaewa/features/orders/presentation/controllers/orders_controller.dart';

void main() {
  group('ordersProvider', () {
    test(
      'returns empty list when unauthenticated without hitting repository',
      () async {
        final repository = _MockOrdersRepository();
        final container = ProviderContainer(
          overrides: [
            accessTokenProvider.overrideWith((ref) => null),
            ordersRepositoryProvider.overrideWithValue(repository),
          ],
        );
        addTearDown(container.dispose);

        final result = await container.read(ordersProvider.future);

        expect(result, isEmpty);
        verifyNever(() => repository.listOrders(page: any(named: 'page')));
      },
    );
  });

  group('OrderStatusOverridesController', () {
    test('stores per-order status overrides', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(orderStatusOverridesProvider.notifier)
          .setStatus(101, 'shipped');
      container
          .read(orderStatusOverridesProvider.notifier)
          .setStatus(102, 'delivered');

      expect(container.read(orderStatusOverridesProvider), {
        101: 'shipped',
        102: 'delivered',
      });
    });
  });

  group('OrdersRealtimeController', () {
    test('hydrates from ordersProvider and applies status updates', () async {
      final repository = _MockOrdersRepository();
      when(
        () => repository.listOrders(page: any(named: 'page')),
      ).thenAnswer((_) async => [_orderSummary(id: 7, status: 'pending')]);

      final container = ProviderContainer(
        overrides: [
          accessTokenProvider.overrideWith((ref) => 'token'),
          ordersRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(ordersProvider.future);
      final initialOrders = await container.read(ordersRealtimeProvider.future);
      expect(initialOrders.single.status, 'pending');

      container
          .read(ordersRealtimeProvider.notifier)
          .applyStatusUpdate(7, 'processing');

      final updatedOrders = container.read(ordersRealtimeProvider).requireValue;
      expect(updatedOrders.single.status, 'processing');
      expect(container.read(orderStatusOverridesProvider), {7: 'processing'});
    });
  });

  group('OrderActionsController', () {
    test(
      'createOrderAndPaymentLink creates an order, requests payment link, and refreshes orders',
      () async {
        final repository = _MockOrdersRepository();
        var listOrdersCalls = 0;

        when(() => repository.listOrders(page: any(named: 'page'))).thenAnswer((
          _,
        ) async {
          listOrdersCalls += 1;
          return [_orderSummary(id: listOrdersCalls, status: 'pending')];
        });
        when(
          () => repository.createOrder(
            items: any(named: 'items'),
            addressId: any(named: 'addressId'),
            shippingName: any(named: 'shippingName'),
            shippingPhone: any(named: 'shippingPhone'),
            shippingAddress: any(named: 'shippingAddress'),
            shippingCity: any(named: 'shippingCity'),
            shippingState: any(named: 'shippingState'),
            shippingCountry: any(named: 'shippingCountry'),
            shippingZipCode: any(named: 'shippingZipCode'),
            selectedQuotes: any(named: 'selectedQuotes'),
          ),
        ).thenAnswer((_) async => _orderSummary(id: 42, status: 'pending'));
        when(
          () => repository.createOrderPaymentLink(orderId: 42),
        ).thenAnswer((_) async => _paymentLink(reference: 'pay-ref-42'));

        final container = ProviderContainer(
          overrides: [
            accessTokenProvider.overrideWith((ref) => 'token'),
            ordersRepositoryProvider.overrideWithValue(repository),
          ],
        );
        addTearDown(container.dispose);

        await container.read(ordersProvider.future);

        final paymentLink = await container
            .read(orderActionsProvider.notifier)
            .createOrderAndPaymentLink(
              items: const [
                {'product_id': 1001, 'quantity': 2, 'selected_size': 'L'},
              ],
              shippingName: 'Ada Lovelace',
              shippingPhone: '12345',
              shippingAddress: '42 Riverpod Way',
              shippingCity: 'Lagos',
              shippingState: 'Lagos',
              shippingCountry: 'NG',
              shippingZipCode: '100001',
              selectedQuotes: const [
                SelectedShippingQuote(
                  sellerProfileId: 77,
                  quoteReference: 'quote-77',
                ),
              ],
            );

        final refreshedOrders = await container.read(ordersProvider.future);

        expect(
          container.read(orderActionsProvider),
          const AsyncData<void>(null),
        );
        expect(paymentLink.reference, 'pay-ref-42');
        expect(refreshedOrders.single.id, 2);
        verify(
          () => repository.createOrder(
            items: const [
              {'product_id': 1001, 'quantity': 2, 'selected_size': 'L'},
            ],
            addressId: null,
            shippingName: 'Ada Lovelace',
            shippingPhone: '12345',
            shippingAddress: '42 Riverpod Way',
            shippingCity: 'Lagos',
            shippingState: 'Lagos',
            shippingCountry: 'NG',
            shippingZipCode: '100001',
            selectedQuotes: const [
              SelectedShippingQuote(
                sellerProfileId: 77,
                quoteReference: 'quote-77',
              ),
            ],
          ),
        ).called(1);
        verify(() => repository.createOrderPaymentLink(orderId: 42)).called(1);
        verify(
          () => repository.listOrders(page: 1),
        ).called(greaterThanOrEqualTo(2));
      },
    );

    test('verifyPayment returns result and refreshes orders', () async {
      final repository = _MockOrdersRepository();
      var listOrdersCalls = 0;

      when(() => repository.listOrders(page: any(named: 'page'))).thenAnswer((
        _,
      ) async {
        listOrdersCalls += 1;
        return [_orderSummary(id: listOrdersCalls, status: 'pending')];
      });
      when(
        () => repository.verifyPayment(reference: 'pay-ref-1'),
      ).thenAnswer((_) async => _paymentVerifyResult(status: 'success'));

      final container = ProviderContainer(
        overrides: [
          accessTokenProvider.overrideWith((ref) => 'token'),
          ordersRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(ordersProvider.future);

      final result = await container
          .read(orderActionsProvider.notifier)
          .verifyPayment(reference: 'pay-ref-1');

      final refreshedOrders = await container.read(ordersProvider.future);

      expect(container.read(orderActionsProvider), const AsyncData<void>(null));
      expect(result.status, 'success');
      expect(refreshedOrders.single.id, 2);
      verify(() => repository.verifyPayment(reference: 'pay-ref-1')).called(1);
      verify(
        () => repository.listOrders(page: 1),
      ).called(greaterThanOrEqualTo(2));
    });

    test('verifyPayment exposes repository failures as AsyncError', () async {
      final repository = _MockOrdersRepository();
      when(
        () => repository.verifyPayment(reference: 'broken-ref'),
      ).thenThrow(StateError('verification failed'));

      final container = ProviderContainer(
        overrides: [ordersRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      expect(
        () => container
            .read(orderActionsProvider.notifier)
            .verifyPayment(reference: 'broken-ref'),
        throwsA(isA<StateError>()),
      );

      expect(container.read(orderActionsProvider), isA<AsyncError<void>>());
    });
  });
}

class _MockOrdersRepository extends Mock implements OrdersRepository {}

OrderSummary _orderSummary({required int id, required String status}) {
  return OrderSummary(
    id: id,
    orderNumber: 'ORD-$id',
    totalPrice: 150,
    deliveryFee: 20,
    status: status,
    paymentStatus: 'pending',
    paymentReference: 'pay-ref-$id',
    trackingNumber: 'TRACK-$id',
    createdAt: DateTime(2026, 3, 13),
    items: const [],
    shipments: const [],
  );
}

PaymentLink _paymentLink({required String reference}) {
  return PaymentLink(
    paymentUrl: 'https://pay.example/$reference',
    accessCode: 'access-$reference',
    reference: reference,
    amount: 150,
    currency: 'NGN',
  );
}

PaymentVerifyResult _paymentVerifyResult({required String status}) {
  return PaymentVerifyResult(
    orderId: 42,
    status: status,
    amount: 150,
    currency: 'NGN',
    paidAt: DateTime(2026, 3, 13, 12),
  );
}
