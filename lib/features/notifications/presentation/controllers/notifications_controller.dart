import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/core/auth/auth_providers.dart';
import '../../data/notifications_repository_impl.dart';
import '../../domain/app_notification.dart';
import '../../domain/notification_preferences.dart';

/// Optimistic notifications list - updates immediately, syncs with server
class OptimisticNotificationsNotifier extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() async {
    // Don't fetch if not authenticated
    final token = ref.watch(accessTokenProvider);
    if (token == null || token.isEmpty) return const [];
    
    return ref.read(notificationsRepositoryProvider).getNotifications();
  }

  /// Mark a notification as read optimistically
  void markAsReadOptimistically(int id) {
    final currentList = state.asData?.value;
    if (currentList == null) return;

    // Update the list optimistically
    state = AsyncData(
      currentList.map((n) {
        if (n.id == id) {
          return AppNotification(
            id: n.id,
            title: n.title,
            body: n.body,
            isRead: true,
            createdAt: n.createdAt,
            event: n.event,
            payload: n.payload,
          );
        }
        return n;
      }).toList(),
    );
  }

  /// Mark all notifications as read optimistically
  void markAllAsReadOptimistically() {
    final currentList = state.asData?.value;
    if (currentList == null) return;

    state = AsyncData(
      currentList.map((n) => AppNotification(
        id: n.id,
        title: n.title,
        body: n.body,
        isRead: true,
        createdAt: n.createdAt,
        event: n.event,
        payload: n.payload,
      )).toList(),
    );
  }

  /// Refresh the list from server
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
      ref.read(notificationsRepositoryProvider).getNotifications()
    );
  }
}

final notificationsListProvider = AsyncNotifierProvider<OptimisticNotificationsNotifier, List<AppNotification>>(
  OptimisticNotificationsNotifier.new,
);

/// Optimistic unread count - updates immediately
class OptimisticUnreadCountNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() async {
    // Don't fetch if not authenticated
    final token = ref.watch(accessTokenProvider);
    if (token == null || token.isEmpty) return 0;
    
    return ref.read(notificationsRepositoryProvider).getUnreadCount();
  }

  /// Decrement count optimistically
  void decrementOptimistically() {
    final current = state.asData?.value ?? 0;
    if (current > 0) {
      state = AsyncData(current - 1);
    }
  }

  /// Set count to zero optimistically
  void setZeroOptimistically() {
    state = const AsyncData(0);
  }

  /// Refresh from server
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
      ref.read(notificationsRepositoryProvider).getUnreadCount()
    );
  }
}

final unreadCountProvider = AsyncNotifierProvider<OptimisticUnreadCountNotifier, int>(
  OptimisticUnreadCountNotifier.new,
);

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
    // Optimistic update first
    ref.read(notificationsListProvider.notifier).markAsReadOptimistically(id);
    ref.read(unreadCountProvider.notifier).decrementOptimistically();

    // Then sync with server
    state = await AsyncValue.guard(() async {
      await ref.read(notificationsRepositoryProvider).markAsRead(id);
    });
  }

  Future<void> markAllAsRead() async {
    // Optimistic update first
    ref.read(notificationsListProvider.notifier).markAllAsReadOptimistically();
    ref.read(unreadCountProvider.notifier).setZeroOptimistically();

    // Then sync with server
    state = await AsyncValue.guard(() async {
      await ref.read(notificationsRepositoryProvider).markAllAsRead();
    });
  }

  Future<void> delete(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(notificationsRepositoryProvider).deleteNotification(id);
      // Refresh after delete
      await ref.read(notificationsListProvider.notifier).refresh();
      await ref.read(unreadCountProvider.notifier).refresh();
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
