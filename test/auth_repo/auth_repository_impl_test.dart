import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ojaewa/core/auth/auth_controller.dart';
import 'package:ojaewa/features/auth/data/auth_api.dart';
import 'package:ojaewa/features/auth/data/auth_repository_impl.dart';

void main() {
  group('AuthRepositoryImpl', () {
    late _MockAuthApi api;
    late _MockAuthController authController;
    late AuthRepositoryImpl repository;

    setUp(() {
      api = _MockAuthApi();
      authController = _MockAuthController();
      repository = AuthRepositoryImpl(
        api: api,
        authController: authController,
      );
    });

    test('login persists the returned token', () async {
      when(
        () => api.login(email: 'tester@example.com', password: 'secret'),
      ).thenAnswer((_) async => 'token-1');
      when(() => authController.setAccessToken('token-1')).thenAnswer((_) async {});

      await repository.login(email: 'tester@example.com', password: 'secret');

      verify(
        () => api.login(email: 'tester@example.com', password: 'secret'),
      ).called(1);
      verify(() => authController.setAccessToken('token-1')).called(1);
    });

    test('register forwards referral code and persists the returned token', () async {
      when(
        () => api.register(
          firstname: 'Ada',
          lastname: 'Lovelace',
          email: 'ada@example.com',
          password: 'secret',
          referralCode: 'REF-42',
        ),
      ).thenAnswer((_) async => 'token-2');
      when(() => authController.setAccessToken('token-2')).thenAnswer((_) async {});

      await repository.register(
        firstname: 'Ada',
        lastname: 'Lovelace',
        email: 'ada@example.com',
        password: 'secret',
        referralCode: 'REF-42',
      );

      verify(
        () => api.register(
          firstname: 'Ada',
          lastname: 'Lovelace',
          email: 'ada@example.com',
          password: 'secret',
          referralCode: 'REF-42',
        ),
      ).called(1);
      verify(() => authController.setAccessToken('token-2')).called(1);
    });

    test('logout always clears local auth state even when server logout fails', () async {
      when(() => api.logout()).thenThrow(Exception('server down'));
      when(() => authController.signOutLocal()).thenAnswer((_) async {});

      await repository.logout();

      verify(() => api.logout()).called(1);
      verify(() => authController.signOutLocal()).called(1);
    });

    test('googleSignIn persists the returned token', () async {
      when(
        () => api.googleSignIn(idToken: 'google-token', referralCode: 'REF'),
      ).thenAnswer((_) async => 'token-3');
      when(() => authController.setAccessToken('token-3')).thenAnswer((_) async {});

      await repository.googleSignIn(
        idToken: 'google-token',
        referralCode: 'REF',
      );

      verify(
        () => api.googleSignIn(idToken: 'google-token', referralCode: 'REF'),
      ).called(1);
      verify(() => authController.setAccessToken('token-3')).called(1);
    });

    test('deleteAccount clears local auth state after backend deletion', () async {
      when(() => api.deleteAccount()).thenAnswer((_) async {});
      when(() => authController.signOutLocal()).thenAnswer((_) async {});

      await repository.deleteAccount();

      verify(() => api.deleteAccount()).called(1);
      verify(() => authController.signOutLocal()).called(1);
    });
  });
}

class _MockAuthApi extends Mock implements AuthApi {}

class _MockAuthController extends Mock implements AuthController {}
