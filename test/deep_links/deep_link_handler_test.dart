import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ojaewa/core/deep_links/deep_link_handler.dart';
import 'package:ojaewa/features/orders/domain/order_models.dart';
import 'package:ojaewa/features/orders/presentation/controllers/orders_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeepLinkHandler', () {
    late StreamController<Uri> uriController;
    late _MockAppLinks appLinks;
    late ProviderContainer container;
    late GlobalKey<NavigatorState> navigatorKey;

    setUp(() {
      uriController = StreamController<Uri>.broadcast();
      appLinks = _MockAppLinks();
      navigatorKey = GlobalKey<NavigatorState>();

      when(() => appLinks.uriLinkStream).thenAnswer((_) => uriController.stream);
      when(() => appLinks.getInitialLink()).thenAnswer((_) async => null);

      _FakeOrderActionsController.reset();

      final handlerProvider = Provider<DeepLinkHandler>(
        (ref) => DeepLinkHandler(ref, appLinks: appLinks),
      );

      container = ProviderContainer(
        overrides: [
          orderActionsProvider.overrideWith(_FakeOrderActionsController.new),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(uriController.close);

      container.read(handlerProvider).init(navigatorKey);
    });

    testWidgets('shows an error snackbar when payment callback is missing reference', (
      tester,
    ) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            navigatorKey: navigatorKey,
            home: const Scaffold(body: SizedBox()),
          ),
        ),
      );

      uriController.add(Uri.parse('ojaewa://payment/callback?status=success'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(
        find.text('Invalid payment callback: missing reference'),
        findsOneWidget,
      );
      expect(_FakeOrderActionsController.lastReference, isNull);
    });

    testWidgets('starts paystack verification for a valid payment callback', (
      tester,
    ) async {
      _FakeOrderActionsController.verifyResult = PaymentVerifyResult(
        orderId: 42,
        status: 'success',
        amount: 12000,
        currency: 'NGN',
        paidAt: DateTime(2026, 3, 13, 12),
      );
      _FakeOrderActionsController.verifyDelay = const Duration(
        seconds: 1,
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            navigatorKey: navigatorKey,
            home: const Scaffold(body: SizedBox()),
          ),
        ),
      );

      uriController.add(
        Uri.parse(
          'ojaewa://payment/callback?reference=pay-ref-42&status=success',
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(_FakeOrderActionsController.lastReference, 'pay-ref-42');
      expect(find.text('Verifying payment...'), findsOneWidget);
    });
  });
}

class _MockAppLinks extends Mock implements AppLinks {}

class _FakeOrderActionsController extends OrderActionsController {
  static PaymentVerifyResult? verifyResult;
  static Object? verifyError;
  static String? lastReference;
  static Duration verifyDelay = Duration.zero;

  static void reset() {
    verifyResult = null;
    verifyError = null;
    lastReference = null;
    verifyDelay = Duration.zero;
  }

  @override
  FutureOr<void> build() {}

  @override
  Future<PaymentVerifyResult> verifyPayment({required String reference}) async {
    lastReference = reference;
    if (verifyDelay > Duration.zero) {
      await Future<void>.delayed(verifyDelay);
    }
    if (verifyError != null) {
      throw verifyError!;
    }
    return verifyResult!;
  }
}
