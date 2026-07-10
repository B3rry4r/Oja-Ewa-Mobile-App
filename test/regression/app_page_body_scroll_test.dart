import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';

/// Guards the class of bug that made the seller/business "Signature" review
/// step unusable: the page body did not scroll, so content taller than the
/// viewport (notably the submit button) was unreachable and silently overflowed.
///
/// AppPageBody's DEFAULT (scrollable: null) must therefore always be able to
/// scroll, while still centring Spacer-based layouts when there is room, and
/// pages whose body is a ListView/GridView must still opt out with
/// scrollable: false.
void main() {
  const viewport = Size(400, 600);

  Future<void> pump(WidgetTester tester, Widget body) async {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          // Mirrors how AppPageScaffold hands its body a bounded height.
          body: SizedBox(
            height: viewport.height,
            width: viewport.width,
            child: body,
          ),
        ),
      ),
    );
  }

  /// A column far taller than the viewport, ending in a "submit" button.
  Widget tallColumn({bool withSpacers = false}) => Column(
        children: [
          const SizedBox(height: 200, child: Text('banner')),
          if (withSpacers) const Spacer(flex: 2),
          const SizedBox(height: 500, child: Text('quality standards')),
          if (withSpacers) const Spacer(flex: 3),
          const SizedBox(height: 200, child: Text('submit', key: Key('submit'))),
        ],
      );

  group('AppPageBody default (scrollable: null)', () {
    testWidgets('scrolls tall content instead of overflowing', (tester) async {
      await pump(tester, AppPageBody(scrollable: null, child: tallColumn()));

      expect(tester.takeException(), isNull,
          reason: 'tall content must not overflow, it must scroll');
      expect(find.byType(Scrollable), findsOneWidget);

      // The submit button starts off-screen and must be reachable by scrolling.
      await tester.scrollUntilVisible(find.byKey(const Key('submit')), 300);
      expect(find.byKey(const Key('submit')), findsOneWidget);
    });

    testWidgets('tolerates Spacer in tall content (unbounded flex)', (tester) async {
      // A bare SingleChildScrollView throws on Spacer. The default mode must not.
      await pump(
        tester,
        AppPageBody(scrollable: null, child: tallColumn(withSpacers: true)),
      );

      expect(tester.takeException(), isNull,
          reason: 'Spacer must resolve via IntrinsicHeight, not throw');
      await tester.scrollUntilVisible(find.byKey(const Key('submit')), 300);
      expect(find.byKey(const Key('submit')), findsOneWidget);
    });

    testWidgets('short content still fills the viewport so Spacers centre it',
        (tester) async {
      await pump(
        tester,
        const AppPageBody(
          scrollable: null,
          child: Column(
            children: [
              Text('top'),
              Spacer(),
              SizedBox(height: 50, child: Text('bottom', key: Key('bottom'))),
            ],
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      // The Spacer pushed 'bottom' down to the bottom of the viewport, which
      // only happens if the body was stretched to at least the viewport height.
      final bottom = tester.getBottomLeft(find.byKey(const Key('bottom'))).dy;
      expect(bottom, greaterThan(viewport.height / 2));
    });
  });

  group('AppPageBody explicit modes', () {
    testWidgets('scrollable: false hands a ListView a bounded height',
        (tester) async {
      await pump(
        tester,
        AppPageBody(
          scrollable: false,
          child: ListView(
            children: List.generate(
              50,
              (i) => SizedBox(height: 40, child: Text('row $i')),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull,
          reason: 'a ListView body needs a bounded height, not an intrinsic pass');
      expect(find.text('row 0'), findsOneWidget);
    });

    testWidgets('scrollable: true still scrolls tall content', (tester) async {
      await pump(tester, AppPageBody(scrollable: true, child: tallColumn()));

      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(find.byKey(const Key('submit')), 300);
      expect(find.byKey(const Key('submit')), findsOneWidget);
    });
  });
}
