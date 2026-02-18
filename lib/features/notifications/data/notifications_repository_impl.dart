import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_clients.dart';
import '../domain/app_notification.dart';
import '../domain/notification_preferences.dart';
import '../domain/notifications_repository.dart';
import 'notifications_api.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._api);

  final NotificationsApi _api;

  @override
  Future<void> deleteNotification(int id) => _api.deleteNotification(id);

  @override
  Future<List<AppNotification>> getNotifications() => _api.getNotifications();

  @override
  Future<int> getUnreadCount() => _api.getUnreadCount();

  @override
  Future<void> markAllAsRead() => _api.markAllAsRead();

  @override
  Future<void> markAsRead(int id) => _api.markAsRead(id);

  @override
  Future<NotificationPreferences> getPreferences() => _api.getPreferences();

  @override
  Future<NotificationPreferences> updatePreferences(NotificationPreferences prefs) => _api.updatePreferences(prefs);

  @override
  Future<void> sendTestNotification() => _api.sendTestNotification();
}

final notificationsApiProvider = Provider<NotificationsApi>((ref) {
  return NotificationsApi(ref.watch(laravelDioProvider));
});

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepositoryImpl(ref.watch(notificationsApiProvider));
});
