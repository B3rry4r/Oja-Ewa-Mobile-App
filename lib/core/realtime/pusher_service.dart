import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../config/app_environment.dart' show AppEnv;
import '../logger/remote_logger.dart';
enum PusherConnectionState {
  connecting,
  connected,
  disconnected,
  error,
}

/// Pusher Channels service for real-time events
class PusherService {
  PusherService();

  PusherChannelsFlutter? _pusher;
  final Map<String, dynamic> _subscriptions = {};
  final Set<String> _subscribedChannels = {};

  Dio? _dio;
  bool _initialized = false;
  PusherConnectionState _connectionState = PusherConnectionState.disconnected;
  PusherConnectionState get connectionState => _connectionState;

  bool get isInitialized => _initialized;

  /// Initialize Pusher
  Future<void> initialize({Dio? dio}) async {
    if (_initialized) {
      return;
    }
    if (kIsWeb) {
      debugPrint('⚠️ Pusher not initialized on web (missing JS SDK).');
      return;
    }
    try {
      _dio = dio;
      _pusher = PusherChannelsFlutter.getInstance();
      
      // Get Pusher config from environment
      final pusherKey = AppEnv.pusherKey;
      final pusherCluster = AppEnv.pusherCluster;
      final authEndpoint = AppEnv.pusherAuthEndpoint;
      
      await _pusher!.init(
        apiKey: pusherKey,
        cluster: pusherCluster,
        onConnectionStateChange: _onConnectionStateChange,
        onError: _onError,
        onSubscriptionSucceeded: _onSubscriptionSucceeded,
        onEvent: _onEvent,
        onSubscriptionError: _onSubscriptionError,
        onDecryptionFailure: _onDecryptionFailure,
        onMemberAdded: _onMemberAdded,
        onMemberRemoved: _onMemberRemoved,
        // Using onAuthorizer only, so authEndpoint should be empty
        onAuthorizer: (channelName, socketId, options) async {
          final token = AppEnv.accessToken;
          final appId = "2116718"; // From backend agent
          if (token == null || token.isEmpty) {
            debugPrint('⚠️ No auth token available for Pusher authorization');
            return {};
          }

          try {
            debugPrint('🔐 Pusher authorizing channel: $channelName with socket_id: $socketId');
            final dioClient = _dio ?? Dio();
            
            // Using Form Data as it is the most compatible with Laravel's BroadcastController
            final response = await dioClient.post(
              authEndpoint,
              data: {
                'channel_name': channelName,
                'socket_id': socketId,
              },
              options: Options(
                contentType: Headers.formUrlEncodedContentType,
                headers: {
                  'Authorization': 'Bearer $token',
                  'Accept': 'application/json',
                  'X-Socket-Id': socketId,
                  'X-App-ID': appId,
                },
              ),
            );

            debugPrint('📡 Pusher auth response: ${response.statusCode} ${response.data}');

            if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
              final data = response.data;
              if (data is Map<String, dynamic>) {
                return data;
              }
              if (data is String) {
                return jsonDecode(data) as Map<String, dynamic>;
              }
            }

            debugPrint(
              '❌ Pusher auth failed ${response.statusCode}: ${response.data}',
            );
            RemoteLogger.error('Pusher Auth Failed', context: {
              'channel': channelName,
              'socket_id': socketId,
              'statusCode': response.statusCode,
              'responseData': response.data,
            });
            return {};
          } catch (e) {
            debugPrint('❌ Pusher auth exception: $e');
            RemoteLogger.error('Pusher Auth Exception', context: {
              'channel': channelName,
              'socket_id': socketId,
              'error': e.toString(),
            });
            return {};
          }
        },
      );

      await _pusher!.connect();
      _initialized = true;
      debugPrint('✅ Pusher initialized successfully');
    } catch (e) {
      debugPrint('❌ Pusher initialization error: $e');
      _connectionState = PusherConnectionState.error;
      _initialized = false;
    }
  }

  /// Subscribe to a channel
  Future<void> subscribeToChannel(String channelName) async {
    if (_pusher == null) {
      debugPrint('❌ Pusher not initialized, cannot subscribe to $channelName');
      return;
    }
    if (_subscribedChannels.contains(channelName)) {
      debugPrint('⏭️ Already subscribed to $channelName, skipping');
      return;
    }
    try {
      await _pusher!.subscribe(channelName: channelName);
      _subscriptions[channelName] = true;
      _subscribedChannels.add(channelName);
      debugPrint('✅ Subscribed to channel: $channelName');
    } catch (e) {
      debugPrint('❌ Failed to subscribe to $channelName: $e');
    }
  }

  bool isSubscribed(String channelName) => _subscribedChannels.contains(channelName);

  /// Unsubscribe from a channel
  Future<void> unsubscribeFromChannel(String channelName) async {
    if (_pusher == null) return;
    try {
      await _pusher!.unsubscribe(channelName: channelName);
      _subscriptions.remove(channelName);
      _subscribedChannels.remove(channelName);
      debugPrint('✅ Unsubscribed from channel: $channelName');
    } catch (e) {
      debugPrint('❌ Failed to unsubscribe from $channelName: $e');
    }
  }

  /// Bind to an event on a channel
  void bindEvent(String channelName, String eventName, Function(dynamic) callback) {
    // Events are handled via onEvent callback
    // Store callback for routing
    final key = '$channelName:$eventName';
    _subscriptions[key] = callback;
  }

  /// Disconnect from Pusher
  Future<void> disconnect() async {
    try {
      await _pusher!.disconnect();
      _subscriptions.clear();
      _subscribedChannels.clear();
      _initialized = false;
      debugPrint('✅ Pusher disconnected');
    } catch (e) {
      debugPrint('❌ Pusher disconnect error: $e');
    }
  }

  // Event handlers
  void _onConnectionStateChange(String? currentState, String? previousState) {
    debugPrint('Pusher connection state changed: $previousState -> $currentState');
    
    switch (currentState) {
      case 'CONNECTED':
        _connectionState = PusherConnectionState.connected;
        break;
      case 'CONNECTING':
        _connectionState = PusherConnectionState.connecting;
        break;
      case 'DISCONNECTED':
        _connectionState = PusherConnectionState.disconnected;
        break;
      default:
        _connectionState = PusherConnectionState.error;
    }
  }

  void _onError(String message, int? code, dynamic e) {
    debugPrint('Pusher error: $message (code: $code)');
    _connectionState = PusherConnectionState.error;
  }

  void _onSubscriptionSucceeded(String channelName, dynamic data) {
    debugPrint('✅ Successfully subscribed to: $channelName');
  }

  void _onSubscriptionError(String message, dynamic e) {
    debugPrint('❌ Pusher Subscription error: $message, data: $e');
  }

  void _onDecryptionFailure(String event, String reason) {
    debugPrint('❌ Decryption failure for $event: $reason');
  }

  void _onMemberAdded(String channelName, dynamic member) {
    debugPrint('Member added to $channelName');
  }

  void _onMemberRemoved(String channelName, dynamic member) {
    debugPrint('Member removed from $channelName');
  }

  void _onEvent(PusherEvent event) {
    debugPrint('📡 Pusher event: ${event.eventName} on ${event.channelName}');
    
    // Route event to registered callbacks
    final key = '${event.channelName}:${event.eventName}';
    final callback = _subscriptions[key];
    
    if (callback is Function) {
      try {
        callback(event.data);
      } catch (e) {
        debugPrint('❌ Error handling event $key: $e');
      }
    }
  }
}
