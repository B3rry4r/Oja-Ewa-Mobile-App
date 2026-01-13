import 'user_profile.dart';

abstract interface class UserRepository {
  Future<UserProfile> getMe();

  Future<UserProfile> updateProfile({
    required String name,
    required String email,
    String? phone,
  });
}
