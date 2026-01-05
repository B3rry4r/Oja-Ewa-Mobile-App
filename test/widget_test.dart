import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ojaewa/app/app.dart';

void main() {
  testWidgets('App builds', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: App(),
      ),
    );
    await tester.pumpAndSettle();

    // Basic smoke test: app builds without exceptions.
    expect(find.byType(MaterialApp), findsOneWidget);

    final exception = tester.takeException();
    expect(exception, isNull);
  });
}
