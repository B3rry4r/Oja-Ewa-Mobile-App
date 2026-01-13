import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/notifications_repository_impl.dart';
import '../../domain/app_notification.dart';
import '../../domain/notification_preferences.dart';

final notificationsListProvider = FutureProvider<List<AppNotification>>((ref) async {
  return ref.watch(notificationsRepositoryProvider).getNotifications();
});

final unreadCountProvider = FutureProvider<int>((ref) async {
  return ref.watch(notificationsRepositoryProvider).getUnreadCount();
});

final notificationPreferencesProvider = FutureProvider<NotificationPreferences>((ref) async {
  return ref.watch(notificationsRepositoryProvider).getPreferences();
});

class NotificationsActionsController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> markAsRead(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(notificationsRepositoryProvider).markAsRead(id);
      ref.invalidate(notificationsListProvider);
      ref.invalidate(unreadCountProvider);
    });
  }

  Future<void> markAllAsRead() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(notificationsRepositoryProvider).markAllAsRead();
      ref.invalidate(notificationsListProvider);
      ref.invalidate(unreadCountProvider);
    });
  }

  Future<void> delete(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(notificationsRepositoryProvider).deleteNotification(id);
      ref.invalidate(notificationsListProvider);
      ref.invalidate(unreadCountProvider);
    });
  }

  Future<void> updatePreferences(NotificationPreferences prefs) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(notificationsRepositoryProvider).updatePreferences(prefs);
      ref.invalidate(notificationPreferencesProvider);
    });
  }
}

final notificationsActionsProvider = AsyncNotifierProvider<NotificationsActionsController, void>(
  NotificationsActionsController.new,
);
