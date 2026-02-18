import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pusher_service.dart';

/// Provider for Pusher service instance
final pusherServiceProvider = Provider<PusherService>((ref) {
  return PusherService();
});
