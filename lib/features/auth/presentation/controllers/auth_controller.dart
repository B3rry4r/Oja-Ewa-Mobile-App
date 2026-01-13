import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/core/errors/app_exception.dart';
import '../../data/auth_repository_impl.dart';

/// Presentation-layer controller for auth flows.
///
/// This owns UI async state (loading/error) while delegating token storage
/// to the core `AuthController` (session).
class AuthFlowController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Keep this synchronous so screens listening to this provider
    // don't see a misleading initial loading->data transition.
    return null;
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).login(email: email, password: password);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> register({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).register(
            firstname: firstname,
            lastname: lastname,
            email: email,
            password: password,
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> forgotPassword({required String email}) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).forgotPassword(email: email);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).resetPassword(
            email: email,
            token: token,
            password: password,
            passwordConfirmation: passwordConfirmation,
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> googleSignIn({required String idToken}) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).googleSignIn(idToken: idToken);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    // Logout should never fail from the user's perspective.
    try {
      await ref.read(authRepositoryProvider).logout();
      state = const AsyncData(null);
    } catch (e, st) {
      // We swallow because local sign-out still completes.
      state = AsyncError(e, st);
      state = const AsyncData(null);
    }
  }

  /// Convenience getter for error message.
  String? get errorMessage {
    final err = state.error;
    if (err is AppException) return err.message;

    // Dio mapper returns AppException, but keep this safe.
    if (err is Exception) return err.toString();
    return err?.toString();
  }
}

final authFlowControllerProvider = AsyncNotifierProvider<AuthFlowController, void>(AuthFlowController.new);
