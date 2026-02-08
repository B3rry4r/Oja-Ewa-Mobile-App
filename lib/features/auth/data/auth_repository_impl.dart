import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/network/dio_clients.dart';
import '../domain/auth_repository.dart';
import 'auth_api.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this.api, required this.authController});

  final AuthApi api;
  final AuthController authController;

  @override
  Future<void> login({required String email, required String password}) async {
    final token = await api.login(email: email, password: password);
    await authController.setAccessToken(token);
  }

  @override
  Future<void> register({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    String? referralCode,
  }) async {
    final token = await api.register(
      firstname: firstname,
      lastname: lastname,
      email: email,
      password: password,
      referralCode: referralCode,
    );
    await authController.setAccessToken(token);
  }

  @override
  Future<void> logout() async {
    // Always clear locally.
    // Server logout is best-effort and must never prevent user sign-out.
    try {
      await api.logout();
    } catch (_) {
      // Ignore server errors (including 404) — token will be invalid locally.
    } finally {
      await authController.signOutLocal();
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await api.forgotPassword(email: email);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    await api.resetPassword(
      email: email,
      token: token,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }

  @override
  Future<void> googleSignIn({
    required String idToken,
    String? referralCode,
  }) async {
    final token = await api.googleSignIn(
      idToken: idToken,
      referralCode: referralCode,
    );
    await authController.setAccessToken(token);
  }

  @override
  Future<void> setReferralCode({required String referralCode}) async {
    await api.setReferralCode(referralCode: referralCode);
  }
}

/// Providers live in the data layer per structure guide.
///
/// Keeping them here makes feature wiring predictable.
///
/// - api uses Laravel dio
/// - repository depends on auth controller to persist token
final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(laravelDioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    api: ref.watch(authApiProvider),
    authController: ref.watch(authControllerProvider.notifier),
  );
});
