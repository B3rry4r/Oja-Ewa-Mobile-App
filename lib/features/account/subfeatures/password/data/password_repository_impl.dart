import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/dio_clients.dart';
import '../domain/password_repository.dart';
import 'password_api.dart';

class PasswordRepositoryImpl implements PasswordRepository {
  PasswordRepositoryImpl(this._api);

  final PasswordApi _api;

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String passwordConfirmation,
  }) {
    return _api.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      passwordConfirmation: passwordConfirmation,
    );
  }
}

final passwordApiProvider = Provider<PasswordApi>((ref) {
  return PasswordApi(ref.watch(laravelDioProvider));
});

final passwordRepositoryProvider = Provider<PasswordRepository>((ref) {
  return PasswordRepositoryImpl(ref.watch(passwordApiProvider));
});
