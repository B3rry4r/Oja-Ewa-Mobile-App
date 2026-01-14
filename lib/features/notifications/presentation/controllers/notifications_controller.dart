import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/core/auth/auth_providers.dart';
import '../../data/notifications_repository_impl.dart';
import '../../domain/app_notification.dart';
import '../../domain/notification_preferences.dart';

final notificationsListProvider = FutureProvider<List<AppNotification>>((ref) async {
  // Don't fetch if not authenticated
  final token = ref.watch(accessTokenProvider);
  if (token == null || token.isEmpty) return const [];
  
  return ref.read(notificationsRepositoryProvider).getNotifications();
});

final unreadCountProvider = FutureProvider<int>((ref) async {
  // Don't fetch if not authenticated
  final token = ref.watch(accessTokenProvider);
  if (token == null || token.isEmpty) return 0;
  
  return ref.read(notificationsRepositoryProvider).getUnreadCount();
});

final notificationPreferencesProvider = FutureProvider<NotificationPreferences?>((ref) async {
  // Don't fetch if not authenticated
  final token = ref.watch(accessTokenProvider);
  if (token == null || token.isEmpty) return null;
  
  return ref.read(notificationsRepositoryProvider).getPreferences();
});

/// Optimistic notification preferences - updates immediately, reverts on failure
class OptimisticPreferencesNotifier extends Notifier<NotificationPreferences?> {
  bool _initialized = false;

  @override
  NotificationPreferences? build() {
    // Listen to server data only for initial load
    ref.listen(notificationPreferencesProvider, (_, next) {
      if (!_initialized) {
        final data = next.asData?.value;
        if (data != null) {
          state = data;
          _initialized = true;
        }
      }
    });
    // Initialize with current data if available
    final initialData = ref.read(notificationPreferencesProvider).asData?.value;
    if (initialData != null) {
      _initialized = true;
    }
    return initialData;
  }

  void setPreferences(NotificationPreferences prefs) {
    state = prefs;
    _initialized = true;
  }
}

final optimisticPreferencesProvider = NotifierProvider<OptimisticPreferencesNotifier, NotificationPreferences?>(
  OptimisticPreferencesNotifier.new,
);

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

  /// Optimistic update - updates UI immediately, reverts on failure
  Future<void> updatePreferences(NotificationPreferences newPrefs) async {
    // Save previous state for rollback
    final previousPrefs = ref.read(optimisticPreferencesProvider);
    
    // Update optimistically
    ref.read(optimisticPreferencesProvider.notifier).setPreferences(newPrefs);

    try {
      await ref.read(notificationsRepositoryProvider).updatePreferences(newPrefs);
      // Success - optimistic state is the truth
    } catch (e, st) {
      // Revert on failure
      if (previousPrefs != null) {
        ref.read(optimisticPreferencesProvider.notifier).setPreferences(previousPrefs);
      }
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final notificationsActionsProvider = AsyncNotifierProvider<NotificationsActionsController, void>(
  NotificationsActionsController.new,
);
