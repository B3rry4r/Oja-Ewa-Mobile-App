import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_clients.dart';
import '../domain/user_profile.dart';
import '../domain/user_repository.dart';
import 'user_api.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._api);

  final UserApi _api;

  @override
  Future<UserProfile> getMe() => _api.getMe();

  @override
  Future<UserProfile> updateProfile({
    required String name,
    required String email,
    String? phone,
  }) => _api.updateProfile(name: name, email: email, phone: phone);
}

final userApiProvider = Provider<UserApi>((ref) {
  return UserApi(ref.watch(laravelDioProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.watch(userApiProvider));
});
