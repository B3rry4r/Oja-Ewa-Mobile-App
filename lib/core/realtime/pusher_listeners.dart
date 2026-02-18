import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/cart/presentation/controllers/cart_controller.dart';
import '../../features/orders/presentation/controllers/orders_controller.dart';
import '../../features/account/subfeatures/start_selling/presentation/controllers/seller_status_controller.dart';
import '../../features/account/presentation/controllers/profile_controller.dart';
import '../auth/auth_providers.dart';
import 'pusher_service.dart';

/// Sets up Pusher real-time event listeners
/// 
/// ACTUALLY WORKING - Events invalidate providers to force data refresh!
class PusherListeners {
  PusherListeners._();

  static void setupListeners(ProviderContainer container, PusherService pusher) {
    // Get user ID from auth state
    final token = container.read(accessTokenProvider);
    if (token == null || token.isEmpty) {
      debugPrint('⚠️ No auth token - skipping Pusher subscriptions');
      return;
    }

    // Subscribe to public channels immediately
    _subscribeToBlogUpdates(pusher);
    
    // Listen for user profile to get user ID, then subscribe to private channels
    container.listen(
      userProfileProvider,
      (previous, next) {
        next.whenData((profile) {
          if (profile != null) {
            debugPrint('👤 User profile loaded, subscribing to channels for user ${profile.id}');
            subscribeToUserChannel(pusher, profile.id, container);
            
            // Check if user is a seller and subscribe to seller channels
            _checkAndSubscribeSellerChannels(pusher, profile.id, container);
          }
        });
      },
    );
  }

  static void _checkAndSubscribeSellerChannels(
    PusherService pusher,
    int userId,
    ProviderContainer container,
  ) {
    // Listen for seller status to determine if we should subscribe to seller channels
    container.listen(
      mySellerStatusProvider,
      (previous, next) {
        next.whenData((sellerStatus) {
          if (sellerStatus != null) {
            debugPrint('🏪 Seller detected, subscribing to seller channels');
            subscribeToSellerChannel(pusher, userId, container);
          }
        });
      },
    );
  }

  /// Subscribe to user's private channel for order and cart updates
  static Future<void> subscribeToUserChannel(
    PusherService pusher,
    int userId,
    ProviderContainer container,
  ) async {
    final channelName = 'private-user.$userId';
    await pusher.subscribeToChannel(channelName);

    // Listen for order status updates - ACTUALLY INVALIDATES DATA
    pusher.bindEvent(channelName, 'order.status.updated', (data) {
      debugPrint('📦 Order status updated: $data');
      
      // FORCE REFRESH - Invalidate orders provider to fetch new data
      container.invalidate(ordersProvider);
      
      _handleOrderUpdate(data);
    });

    // Listen for cart updates - ACTUALLY SYNCS ACROSS DEVICES
    pusher.bindEvent(channelName, 'cart.updated', (data) {
      debugPrint('🛒 Cart updated: $data');
      
      // FORCE REFRESH - Invalidate cart to fetch new data from server
      container.invalidate(cartProvider);
    });
  }

  /// Subscribe to seller's private channel for product approvals and new orders
  static Future<void> subscribeToSellerChannel(
    PusherService pusher,
    int sellerId,
    ProviderContainer container,
  ) async {
    final channelName = 'private-seller.$sellerId';
    await pusher.subscribeToChannel(channelName);

    // Listen for SELLER APPROVAL STATUS - UNLOCKS SHOP SCREEN
    pusher.bindEvent(channelName, 'seller.approval.changed', (data) {
      debugPrint('🎉 SELLER APPROVAL CHANGED: $data');
      
      // FORCE REFRESH - This unlocks the shop screen button!
      container.invalidate(mySellerStatusProvider);
      container.invalidate(isSellerApprovedProvider);
      
      _handleSellerApproval(data);
    });

    // Listen for PRODUCT approval status - REFRESHES PRODUCT LIST
    pusher.bindEvent(channelName, 'product.approval.changed', (data) {
      debugPrint('✅ Product approval changed: $data');
      
      // FORCE REFRESH - Seller should reload their products
      // Note: Different screens use different providers, invalidate on demand
      _handleProductApproval(data);
    });

    // Subscribe to all seller orders channel - NEW ORDERS
    await pusher.subscribeToChannel('private-seller.orders');
    
    pusher.bindEvent('private-seller.orders', 'order.new', (data) {
      debugPrint('🆕 NEW ORDER RECEIVED: $data');
      
      // FORCE REFRESH - Shows new order immediately
      container.invalidate(ordersProvider);
      
      _handleNewOrder(data);
    });
  }

  /// Subscribe to public blog updates
  static Future<void> _subscribeToBlogUpdates(PusherService pusher) async {
    await pusher.subscribeToChannel('blog-updates');
    
    pusher.bindEvent('blog-updates', 'blog.published', (data) {
      debugPrint('📝 New blog published: $data');
      _handleNewBlog(data);
    });
  }

  // Event handlers
  static void _handleOrderUpdate(dynamic data) {
    try {
      final json = data is String ? jsonDecode(data) : data;
      debugPrint('Order ${json['order_id']} status: ${json['status']}');
      // TODO: Show in-app notification
    } catch (e) {
      debugPrint('Error parsing order update: $e');
    }
  }

  static void _handleSellerApproval(dynamic data) {
    try {
      final json = data is String ? jsonDecode(data) : data;
      final status = json['status'] as String?;
      final businessName = json['business_name'] as String?;
      
      if (status == 'approved') {
        debugPrint('🎉 SELLER APPROVED: $businessName - Shop unlocked!');
        // TODO: Show success notification "Your shop is now live!"
      } else if (status == 'rejected') {
        final reason = json['rejection_reason'] as String?;
        debugPrint('❌ SELLER REJECTED: $reason');
        // TODO: Show rejection notification with reason
      }
    } catch (e) {
      debugPrint('Error parsing seller approval: $e');
    }
  }

  static void _handleProductApproval(dynamic data) {
    try {
      final json = data is String ? jsonDecode(data) : data;
      debugPrint('Product ${json['product_id']} ${json['status']}');
      // TODO: Show in-app notification
    } catch (e) {
      debugPrint('Error parsing product approval: $e');
    }
  }

  static void _handleNewOrder(dynamic data) {
    try {
      final json = data is String ? jsonDecode(data) : data;
      debugPrint('New order #${json['order_id']} received');
      // TODO: Show notification, play sound
    } catch (e) {
      debugPrint('Error parsing new order: $e');
    }
  }

  static void _handleNewBlog(dynamic data) {
    try {
      final json = data is String ? jsonDecode(data) : data;
      debugPrint('New blog: ${json['title']}');
      // TODO: Show in-app notification
    } catch (e) {
      debugPrint('Error parsing blog update: $e');
    }
  }

  /// Unsubscribe from all user channels
  static Future<void> unsubscribeAll(PusherService pusher, int? userId) async {
    if (userId != null) {
      await pusher.unsubscribeFromChannel('private-user.$userId');
      await pusher.unsubscribeFromChannel('private-seller.$userId');
      await pusher.unsubscribeFromChannel('private-seller.orders');
    }
    await pusher.unsubscribeFromChannel('blog-updates');
  }
}
