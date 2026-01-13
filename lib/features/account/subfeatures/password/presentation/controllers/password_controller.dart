import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/password_repository_impl.dart';

class PasswordController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String passwordConfirmation,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(passwordRepositoryProvider).changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
            passwordConfirmation: passwordConfirmation,
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final passwordControllerProvider = AsyncNotifierProvider<PasswordController, void>(PasswordController.new);
