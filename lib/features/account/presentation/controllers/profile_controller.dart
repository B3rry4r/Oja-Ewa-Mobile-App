import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/user_repository_impl.dart';
import '../../domain/user_profile.dart';

final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  return ref.watch(userRepositoryProvider).getMe();
});

class ProfileActionsController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> refresh() async {
    ref.invalidate(userProfileProvider);
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    String? phone,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(userRepositoryProvider).updateProfile(name: name, email: email, phone: phone);
      ref.invalidate(userProfileProvider);
    });
  }
}

final profileActionsProvider = AsyncNotifierProvider<ProfileActionsController, void>(
  ProfileActionsController.new,
);
