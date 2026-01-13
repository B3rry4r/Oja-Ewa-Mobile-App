import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ojaewa/app/app.dart';
import 'package:ojaewa/core/network/network_providers.dart';

void main() {
  testWidgets('App builds', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Avoid waiting on secure storage / bootstrap during widget tests.
          authBootstrapProvider.overrideWith((ref) async {}),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    // Basic smoke test: app builds without exceptions.
    expect(find.byType(MaterialApp), findsOneWidget);

    final exception = tester.takeException();
    expect(exception, isNull);
  });
}
