import 'package:dio/dio.dart';

import '../../../core/network/dio_error_mapper.dart';
import '../domain/app_notification.dart';
import '../domain/notification_preferences.dart';

class NotificationsApi {
  NotificationsApi(this._dio);

  final Dio _dio;

  Future<List<AppNotification>> getNotifications() async {
    try {
      final res = await _dio.get('/api/notifications');
      return _extractList(res.data);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final res = await _dio.get('/api/notifications/unread-count');
      final data = res.data;
      if (data is Map<String, dynamic>) {
        // Handle: {"status":"success","data":{"unread_count":7}}
        final innerData = data['data'];
        if (innerData is Map<String, dynamic>) {
          final count = innerData['unread_count'] ?? innerData['count'];
          if (count is num) return count.toInt();
        }
        // Fallback to direct count field
        final count = data['unread_count'] ?? data['count'];
        if (count is num) return count.toInt();
      }
      return 0;
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _dio.patch('/api/notifications/$id/read');
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _dio.patch('/api/notifications/mark-all-read');
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      await _dio.delete('/api/notifications/$id');
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<NotificationPreferences> getPreferences() async {
    try {
      // Docs include both `/api/notifications/preferences` and `/api/user/notification-preferences`.
      final res = await _dio.get('/api/notifications/preferences');
      return _extractPrefs(res.data);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<NotificationPreferences> updatePreferences(NotificationPreferences prefs) async {
    try {
      final res = await _dio.put('/api/notifications/preferences', data: prefs.toJson());
      return _extractPrefs(res.data);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  /// Register FCM device token with backend
  Future<void> registerDeviceToken({
    required String token,
    String? deviceType,
  }) async {
    try {
      await _dio.post('/api/notifications/device-token', data: {
        'token': token,
        'device_type': deviceType ?? 'mobile', // mobile, ios, android
      });
    } catch (e) {
      throw mapDioError(e);
    }
  }

  /// Delete FCM device token from backend
  Future<void> deleteDeviceToken({required String token}) async {
    try {
      await _dio.delete('/api/notifications/device-token', data: {
        'token': token,
      });
    } catch (e) {
      throw mapDioError(e);
    }
  }
}

List<AppNotification> _extractList(dynamic data) {
  if (data is Map<String, dynamic>) {
    var list = data['data'];
    // Handle paginated response: {"status":"success","data":{"current_page":1,"data":[...]}}
    if (list is Map<String, dynamic>) {
      list = list['data'];
    }
    if (list is List) {
      return list.whereType<Map<String, dynamic>>().map(AppNotification.fromJson).toList();
    }
  }
  if (data is List) {
    return data.whereType<Map<String, dynamic>>().map(AppNotification.fromJson).toList();
  }
  return const [];
}

NotificationPreferences _extractPrefs(dynamic data) {
  if (data is Map<String, dynamic>) {
    final inner = data['data'];
    if (inner is Map<String, dynamic>) return NotificationPreferences.fromJson(inner);
    return NotificationPreferences.fromJson(data);
  }
  throw const FormatException('Unexpected preferences response');
}
