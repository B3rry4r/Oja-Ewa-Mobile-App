import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ojaewa/core/auth/auth_providers.dart';
import 'package:ojaewa/features/cart/data/cart_repository.dart';
import 'package:ojaewa/features/cart/data/cart_repository_impl.dart';
import 'package:ojaewa/features/cart/domain/cart.dart';
import 'package:ojaewa/features/cart/presentation/controllers/cart_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('cartProvider', () {
    test(
      'returns null when unauthenticated without hitting repository',
      () async {
        final repository = _MockCartRepository();
        final container = ProviderContainer(
          overrides: [
            accessTokenProvider.overrideWith((ref) => null),
            cartRepositoryProvider.overrideWithValue(repository),
          ],
        );
        addTearDown(container.dispose);

        final result = await container.read(cartProvider.future);

        expect(result, isNull);
        verifyNever(() => repository.getCart());
      },
    );
  });

  group('OptimisticCartNotifier', () {
    test('hydrates from cartProvider data', () async {
      final repository = _MockCartRepository();
      when(() => repository.getCart()).thenAnswer((_) async => _sampleCart());

      final container = ProviderContainer(
        overrides: [
          accessTokenProvider.overrideWith((ref) => 'token'),
          cartRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(cartProvider.future);
      final cart = container.read(optimisticCartProvider);

      expect(cart, isNotNull);
      expect(cart!.cartId, 1);
      expect(cart.items, hasLength(2));
      expect(cart.items.first.id, 10);
      expect(cart.total, 80);
      verify(() => repository.getCart()).called(1);
    });

    test('updateItemQuantity recalculates item subtotal and total', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(optimisticCartProvider.notifier);
      notifier.setCart(_sampleCart());

      notifier.updateItemQuantity(10, 4);

      final cart = container.read(optimisticCartProvider)!;
      expect(cart.items.first.quantity, 4);
      expect(cart.items.first.subtotal, 100);
      expect(cart.total, 130);
      expect(cart.itemsCount, 2);
    });

    test('updateItemSize changes only the targeted item size', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(optimisticCartProvider.notifier);
      notifier.setCart(_sampleCart());

      notifier.updateItemSize(10, 'XL');

      final cart = container.read(optimisticCartProvider)!;
      expect(cart.items.first.selectedSize, 'XL');
      expect(cart.items.last.selectedSize, 'M');
    });

    test('removeItem updates items count and total', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(optimisticCartProvider.notifier);
      notifier.setCart(_sampleCart());

      notifier.removeItem(10);

      final cart = container.read(optimisticCartProvider)!;
      expect(cart.items, hasLength(1));
      expect(cart.items.single.id, 11);
      expect(cart.total, 30);
      expect(cart.itemsCount, 1);
    });
  });

  group('OptimisticCartActionsController', () {
    testWidgets('debounces quantity updates and syncs only the last value', (
      tester,
    ) async {
      final repository = _MockCartRepository();
      when(
        () => repository.updateItemQuantity(
          cartItemId: 10,
          quantity: any(named: 'quantity'),
        ),
      ).thenAnswer((_) async => _updatedCart(quantity: 5));

      final container = ProviderContainer(
        overrides: [cartRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      container.read(optimisticCartProvider.notifier).setCart(_sampleCart());

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: SizedBox())),
        ),
      );

      final context = tester.element(find.byType(SizedBox));
      final controller = container.read(optimisticCartActionsProvider.notifier);

      await controller.updateQuantity(
        context: context,
        cartItemId: 10,
        newQuantity: 3,
      );
      await controller.updateQuantity(
        context: context,
        cartItemId: 10,
        newQuantity: 5,
      );

      expect(container.read(optimisticCartProvider)!.items.first.quantity, 5);

      await tester.pump(const Duration(milliseconds: 399));
      verifyNever(
        () => repository.updateItemQuantity(
          cartItemId: 10,
          quantity: any(named: 'quantity'),
        ),
      );

      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();

      verify(
        () => repository.updateItemQuantity(cartItemId: 10, quantity: 5),
      ).called(1);
      verifyNever(
        () => repository.updateItemQuantity(cartItemId: 10, quantity: 3),
      );
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets(
      'reverts quantity changes and shows an error snackbar on failure',
      (tester) async {
        final repository = _MockCartRepository();
        when(
          () => repository.updateItemQuantity(
            cartItemId: 10,
            quantity: any(named: 'quantity'),
          ),
        ).thenThrow(Exception('boom'));

        final container = ProviderContainer(
          overrides: [cartRepositoryProvider.overrideWithValue(repository)],
        );
        addTearDown(container.dispose);

        final initialCart = _sampleCart();
        container.read(optimisticCartProvider.notifier).setCart(initialCart);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(home: Scaffold(body: SizedBox())),
          ),
        );

        final context = tester.element(find.byType(SizedBox));

        await container
            .read(optimisticCartActionsProvider.notifier)
            .updateQuantity(context: context, cartItemId: 10, newQuantity: 6);

        expect(container.read(optimisticCartProvider)!.items.first.quantity, 6);

        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump();

        expect(container.read(optimisticCartProvider), initialCart);
        expect(find.text('Failed to update quantity'), findsOneWidget);
      },
    );

    testWidgets('reverts size changes and shows an error snackbar on failure', (
      tester,
    ) async {
      final repository = _MockCartRepository();
      when(
        () => repository.updateItemSize(cartItemId: 10, selectedSize: 'XL'),
      ).thenThrow(Exception('boom'));

      final container = ProviderContainer(
        overrides: [cartRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final initialCart = _sampleCart();
      container.read(optimisticCartProvider.notifier).setCart(initialCart);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: SizedBox())),
        ),
      );

      final context = tester.element(find.byType(SizedBox));

      await container
          .read(optimisticCartActionsProvider.notifier)
          .updateSize(context: context, cartItemId: 10, newSize: 'XL');
      await tester.pump();

      expect(container.read(optimisticCartProvider), initialCart);
      expect(find.text('Failed to update size'), findsOneWidget);
    });

    testWidgets('reverts item removal and shows an error snackbar on failure', (
      tester,
    ) async {
      final repository = _MockCartRepository();
      when(
        () => repository.removeItem(cartItemId: 10),
      ).thenThrow(Exception('boom'));

      final container = ProviderContainer(
        overrides: [cartRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final initialCart = _sampleCart();
      container.read(optimisticCartProvider.notifier).setCart(initialCart);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: SizedBox())),
        ),
      );

      final context = tester.element(find.byType(SizedBox));

      await container
          .read(optimisticCartActionsProvider.notifier)
          .removeItem(context: context, cartItemId: 10);
      await tester.pump();

      expect(container.read(optimisticCartProvider), initialCart);
      expect(find.text('Failed to remove item'), findsOneWidget);
    });
  });

  group('CartActionsController', () {
    test('addItem requests sync and refreshes cart provider', () async {
      final repository = _MockCartRepository();
      var getCartCalls = 0;

      when(() => repository.getCart()).thenAnswer((_) async {
        getCartCalls += 1;
        return getCartCalls == 1 ? _sampleCart() : _updatedCart(quantity: 3);
      });
      when(
        () => repository.addItem(
          productId: 999,
          quantity: 2,
          selectedSize: 'L',
          processingTimeType: 'express',
        ),
      ).thenAnswer((_) async => _updatedCart(quantity: 3));

      final container = ProviderContainer(
        overrides: [
          accessTokenProvider.overrideWith((ref) => 'token'),
          cartRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(cartProvider.future);
      container.read(optimisticCartProvider);

      await container
          .read(cartActionsProvider.notifier)
          .addItem(
            productId: 999,
            quantity: 2,
            selectedSize: 'L',
            processingTimeType: 'express',
          );

      final refreshedCart = await container.read(cartProvider.future);

      expect(container.read(cartActionsProvider), const AsyncData<void>(null));
      expect(refreshedCart, isNotNull);
      final nonNullCart = refreshedCart!;
      expect(nonNullCart.items.first.quantity, 3);
      expect(nonNullCart.total, 105);
      verify(
        () => repository.addItem(
          productId: 999,
          quantity: 2,
          selectedSize: 'L',
          processingTimeType: 'express',
        ),
      ).called(1);
      verify(() => repository.getCart()).called(greaterThanOrEqualTo(2));
    });

    test('clearCart surfaces repository failures as AsyncError', () async {
      final repository = _MockCartRepository();
      when(() => repository.clearCart()).thenThrow(StateError('clear failed'));

      final container = ProviderContainer(
        overrides: [cartRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      expect(
        () => container.read(cartActionsProvider.notifier).clearCart(),
        throwsA(isA<StateError>()),
      );

      final state = container.read(cartActionsProvider);
      expect(state, isA<AsyncError<void>>());
      verify(() => repository.clearCart()).called(1);
    });
  });
}

class _MockCartRepository extends Mock implements CartRepository {}

Cart _sampleCart() {
  return Cart(
    cartId: 1,
    items: [
      CartItem(
        id: 10,
        productId: 100,
        quantity: 2,
        unitPrice: 25,
        subtotal: 50,
        selectedSize: 'S',
        processingTimeType: 'normal',
        product: const CartProductSnapshot(
          id: 100,
          name: 'Dress',
          image: null,
          price: 25,
          size: 'S,M,L',
          processingDays: 7,
          sellerProfileId: 200,
          sellerBusinessName: 'Seller A',
        ),
      ),
      CartItem(
        id: 11,
        productId: 101,
        quantity: 1,
        unitPrice: 30,
        subtotal: 30,
        selectedSize: 'M',
        processingTimeType: 'normal',
        product: const CartProductSnapshot(
          id: 101,
          name: 'Bag',
          image: null,
          price: 30,
          size: 'M,L',
          processingDays: 5,
          sellerProfileId: 201,
          sellerBusinessName: 'Seller B',
        ),
      ),
    ],
    total: 80,
    itemsCount: 2,
  );
}

Cart _updatedCart({required int quantity}) {
  return Cart(
    cartId: 1,
    items: [
      CartItem(
        id: 10,
        productId: 100,
        quantity: quantity,
        unitPrice: 25,
        subtotal: quantity * 25,
        selectedSize: 'S',
        processingTimeType: 'normal',
        product: const CartProductSnapshot(
          id: 100,
          name: 'Dress',
          image: null,
          price: 25,
          size: 'S,M,L',
          processingDays: 7,
          sellerProfileId: 200,
          sellerBusinessName: 'Seller A',
        ),
      ),
      const CartItem(
        id: 11,
        productId: 101,
        quantity: 1,
        unitPrice: 30,
        subtotal: 30,
        selectedSize: 'M',
        processingTimeType: 'normal',
        product: CartProductSnapshot(
          id: 101,
          name: 'Bag',
          image: null,
          price: 30,
          size: 'M,L',
          processingDays: 5,
          sellerProfileId: 201,
          sellerBusinessName: 'Seller B',
        ),
      ),
    ],
    total: quantity * 25 + 30,
    itemsCount: 2,
  );
}
