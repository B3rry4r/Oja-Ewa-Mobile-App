import 'package:flutter/foundation.dart';

@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    this.createdAt,
    this.event,
    this.payload,
  });

  final int id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? createdAt;

  /// Notification event type e.g. business_approved
  final String? event;

  /// Payload returned by backend (contains deep_link, ids, status)
  final Map<String, dynamic>? payload;

  String? get deepLink => payload?['deep_link'] as String?;

  static AppNotification fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as num?)?.toInt() ?? 0;
    final title = (json['title'] as String?) ??
        (json['subject'] as String?) ??
        (json['type'] as String?) ??
        '';
    final body = (json['message'] as String?) ?? (json['body'] as String?) ?? '';
    
    // API uses read_at timestamp - null means unread, non-null means read
    final readAt = json['read_at'];
    final isRead = readAt != null && readAt.toString().isNotEmpty;

    DateTime? createdAt;
    final createdAtRaw = json['created_at'];
    if (createdAtRaw is String) createdAt = DateTime.tryParse(createdAtRaw);

    return AppNotification(
      id: id,
      title: title,
      body: body,
      isRead: isRead,
      createdAt: createdAt,
      event: json['event'] as String?,
      payload: json['payload'] is Map<String, dynamic> ? json['payload'] as Map<String, dynamic> : null,
    );
  }
}
