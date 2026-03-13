import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ojaewa/core/auth/auth_controller.dart';
import 'package:ojaewa/core/auth/auth_providers.dart';
import 'package:ojaewa/core/auth/auth_state.dart';
import 'package:ojaewa/core/config/app_environment.dart';
import 'package:ojaewa/core/storage/secure_token_storage.dart';
import 'package:ojaewa/core/storage/storage_providers.dart';

class _MockSecureTokenStorage extends Mock implements SecureTokenStorage {}

void main() {
  group('AuthController', () {
    late _MockSecureTokenStorage storage;
    late ProviderContainer container;

    setUp(() {
      storage = _MockSecureTokenStorage();
      AppEnv.accessToken = 'stale-token';
      container = ProviderContainer(
        overrides: [secureTokenStorageProvider.overrideWithValue(storage)],
      );
    });

    tearDown(() {
      AppEnv.accessToken = null;
      container.dispose();
    });

    test('starts in unknown state', () {
      expect(container.read(authControllerProvider), isA<AuthUnknown>());
      expect(container.read(accessTokenProvider), isNull);
    });

    test(
      'loadFromStorage restores authenticated state when token exists',
      () async {
        when(
          () => storage.readAccessToken(),
        ).thenAnswer((_) async => 'token-123');

        await container.read(authControllerProvider.notifier).loadFromStorage();

        expect(
          container.read(authControllerProvider),
          isA<AuthAuthenticated>().having(
            (state) => state.accessToken,
            'accessToken',
            'token-123',
          ),
        );
        expect(container.read(accessTokenProvider), 'token-123');
        expect(AppEnv.accessToken, 'token-123');
        verify(() => storage.readAccessToken()).called(1);
      },
    );

    test(
      'loadFromStorage clears global token and unauthenticates when storage is empty',
      () async {
        when(() => storage.readAccessToken()).thenAnswer((_) async => null);

        await container.read(authControllerProvider.notifier).loadFromStorage();

        expect(
          container.read(authControllerProvider),
          isA<AuthUnauthenticated>(),
        );
        expect(container.read(accessTokenProvider), isNull);
        expect(AppEnv.accessToken, isNull);
      },
    );

    test(
      'loadFromStorage falls back to unauthenticated when storage throws',
      () async {
        when(() => storage.readAccessToken()).thenThrow(Exception('boom'));

        await container.read(authControllerProvider.notifier).loadFromStorage();

        expect(
          container.read(authControllerProvider),
          isA<AuthUnauthenticated>(),
        );
        expect(AppEnv.accessToken, isNull);
      },
    );

    test('setAccessToken persists token and authenticates state', () async {
      when(
        () => storage.writeAccessToken('fresh-token'),
      ).thenAnswer((_) async {});

      await container
          .read(authControllerProvider.notifier)
          .setAccessToken('fresh-token');

      expect(
        container.read(authControllerProvider),
        isA<AuthAuthenticated>().having(
          (state) => state.accessToken,
          'accessToken',
          'fresh-token',
        ),
      );
      expect(container.read(accessTokenProvider), 'fresh-token');
      expect(AppEnv.accessToken, 'fresh-token');
      verify(() => storage.writeAccessToken('fresh-token')).called(1);
    });

    test(
      'signOutLocal deletes token, clears global state, and unauthenticates',
      () async {
        when(() => storage.deleteAccessToken()).thenAnswer((_) async {});

        await container.read(authControllerProvider.notifier).signOutLocal();

        expect(
          container.read(authControllerProvider),
          isA<AuthUnauthenticated>(),
        );
        expect(container.read(accessTokenProvider), isNull);
        expect(AppEnv.accessToken, isNull);
        verify(() => storage.deleteAccessToken()).called(1);
      },
    );
  });
}
