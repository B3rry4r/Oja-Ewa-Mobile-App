import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/core/errors/app_exception.dart';

import '../../data/auth_repository_impl.dart';
import '../../../account/presentation/controllers/profile_controller.dart';
import '../../../../core/auth/auth_controller.dart';
import '../../../account/subfeatures/your_address/presentation/controllers/address_controller.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../notifications/presentation/controllers/notifications_controller.dart';
import '../../../wishlist/presentation/controllers/wishlist_controller.dart';
import '../../../orders/presentation/controllers/orders_controller.dart';
import '../../../search/presentation/controllers/search_suggestions_controller.dart';
import '../../../blog/presentation/controllers/blog_favorites_controller.dart';

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
    } catch (e, st) {
      // We swallow because local sign-out still completes.
      state = AsyncError(e, st);
    } finally {
      // Clear any cached feature data so next session is clean.
      _invalidateSessionScopedProviders();
      state = const AsyncData(null);
    }
  }

  void _invalidateSessionScopedProviders() {
    // Profile / account
    ref.invalidate(userProfileProvider);
    ref.invalidate(addressesProvider);

    // Cart
    ref.invalidate(cartProvider);

    // Notifications
    ref.invalidate(notificationsListProvider);
    ref.invalidate(unreadCountProvider);
    ref.invalidate(notificationPreferencesProvider);

    // Wishlist
    ref.invalidate(wishlistProvider);

    // Orders
    ref.invalidate(ordersProvider);

    // Blog favorites are user-specific
    ref.invalidate(blogFavoritesProvider);

    // Search suggestions can be personalized
    ref.invalidate(searchSuggestionsProvider);

    // Reset auth state (forces any listeners/interceptors to see unauthenticated)
    ref.invalidate(authControllerProvider);

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
