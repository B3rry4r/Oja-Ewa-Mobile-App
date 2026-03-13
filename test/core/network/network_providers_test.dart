import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ojaewa/core/network/network_providers.dart';

void main() {
  group('isOnlineProvider', () {
    test('defaults to true while connectivity state is unresolved', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(isOnlineProvider), isTrue);
    });

    test('returns true when a network transport is available', () {
      final container = ProviderContainer(
        overrides: [
          connectivityProvider.overrideWithValue(
            const AsyncData([ConnectivityResult.mobile]),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(isOnlineProvider), isTrue);
    });

    test('returns false after resolved connectivity reports none', () {
      final container = ProviderContainer(
        overrides: [
          connectivityProvider.overrideWithValue(
            const AsyncData([ConnectivityResult.none]),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(isOnlineProvider), isFalse);
    });
  });
}
