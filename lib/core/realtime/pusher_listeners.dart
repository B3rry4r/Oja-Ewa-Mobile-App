import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../app/router/app_router.dart';
import '../../features/cart/presentation/controllers/cart_controller.dart';
import '../../features/cart/domain/cart.dart';
import '../../features/orders/presentation/controllers/orders_controller.dart';
import '../../features/blog/presentation/controllers/blog_controller.dart';
import '../../features/your_shop/presentation/controllers/seller_orders_controller.dart';
import '../../features/account/subfeatures/start_selling/presentation/controllers/seller_status_controller.dart';
import '../../features/account/subfeatures/start_selling/domain/seller_status.dart';
import '../../features/blog/domain/blog_post.dart';
import '../../features/account/presentation/controllers/profile_controller.dart';
import '../auth/auth_providers.dart';
import '../widgets/in_app_notification.dart';
import 'pusher_service.dart';

/// Global navigator key for showing notifications
final GlobalKey<NavigatorState> pusherNavigatorKey = GlobalKey<NavigatorState>();

/// Tracks the current user id used for Pusher subscriptions
int? _pusherUserId;

/// Sets up Pusher real-time event listeners
/// 
/// ACTUALLY WORKING - Events invalidate providers to force data refresh!
class PusherListeners {
  PusherListeners._();

  static int? get currentUserId => _pusherUserId;
  static void setCurrentUserId(int? userId) {
    _pusherUserId = userId;
  }

  static bool _listenersSetUp = false;

  static void setupListeners(ProviderContainer container, PusherService pusher) {
    // Get user ID from auth state
    final token = container.read(accessTokenProvider);
    if (token == null || token.isEmpty) {
      debugPrint('⚠️ No auth token - skipping Pusher subscriptions');
      return;
    }

    // Subscribe to public channels immediately (dedup handled in subscribeToChannel)
    _subscribeToBlogUpdates(pusher, container);

    // Only attach listeners once per session to avoid duplicate subscriptions
    if (_listenersSetUp) {
      // If already set up, just subscribe immediately with current profile state
      final profile = container.read(userProfileProvider).value;
      if (profile != null) {
        setCurrentUserId(profile.id);
        subscribeToUserChannel(pusher, profile.id, container);
        _checkAndSubscribeSellerChannels(pusher, profile.id, container);
      }
      return;
    }
    _listenersSetUp = true;
    
    // Listen for user profile to get user ID, then subscribe to private channels
    container.listen(
      userProfileProvider,
      (previous, next) {
        next.whenData((profile) {
          if (profile != null) {
            debugPrint('👤 User profile loaded, subscribing to channels for user ${profile.id}');
            setCurrentUserId(profile.id);
            subscribeToUserChannel(pusher, profile.id, container);
            
            // Check if user is a seller and subscribe to seller channels
            _checkAndSubscribeSellerChannels(pusher, profile.id, container);
          }
        });
      },
      fireImmediately: true,
    );
  }

  static void resetListeners() {
    _listenersSetUp = false;
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

    // Listen for order status updates - UPDATE STATE DIRECTLY
    pusher.bindEvent(channelName, 'order.status.updated', (data) {
      debugPrint('📦 Order status updated: $data');
      
      try {
        final json = data is String ? jsonDecode(data) : data;
        final orderId = json['order_id'];
        final status = json['status'] as String?;
        if (orderId is int && status != null) {
          container.read(ordersRealtimeProvider.notifier).applyStatusUpdate(orderId, status);
          container.read(sellerOrdersRealtimeProvider(null).notifier).applyStatusUpdate(orderId, status);
        }
        
        // Show in-app notification
        _showOrderUpdateNotification(orderId, status ?? 'updated');
      } catch (e) {
        debugPrint('Error parsing order update: $e');
      }
    });

    // Listen for cart updates - SYNC ACROSS DEVICES
    pusher.bindEvent(channelName, 'cart.updated', (data) {
      debugPrint('🛒 Cart updated: $data');
      
      try {
        final json = data is String ? jsonDecode(data) : data;
        if (json is! Map<String, dynamic>) {
          return;
        }
        final itemsCount = json['items_count'] as int?;
        final cart = Cart.fromWrappedResponse(json);
        container.read(optimisticCartProvider.notifier).setCartFromRealtime(cart);
        
        // Show in-app notification
        _showCartUpdateNotification(itemsCount ?? cart.itemsCount);
      } catch (e) {
        debugPrint('Error parsing cart update: $e');
      }
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
      
      try {
        final json = data is String ? jsonDecode(data) : data;
        final status = json['status'] as String?;
        final businessName = json['business_name'] as String?;
        final rejectionReason = json['rejection_reason'] as String?;
        if (status != null || rejectionReason != null || businessName != null) {
          final statusValue = (status ?? '').isNotEmpty ? status! : 'pending';
          final sellerStatus = SellerStatus(
            registrationStatus: statusValue,
            active: statusValue == 'approved',
            rejectionReason: rejectionReason,
            businessName: businessName,
            badge: null,
          );
          container.read(sellerStatusOverrideProvider.notifier).setStatus(sellerStatus);
        }
        container.invalidate(isSellerApprovedProvider);
        
        _showSellerApprovalNotification(status ?? '', businessName, rejectionReason);
      } catch (e) {
        debugPrint('Error parsing seller approval: $e');
      }
    });

    // Listen for PRODUCT approval status
    pusher.bindEvent(channelName, 'product.approval.changed', (data) {
      debugPrint('✅ Product approval changed: $data');
      
      try {
        final json = data is String ? jsonDecode(data) : data;
        final productName = json['product_name'] as String?;
        final status = json['status'] as String?;
        final rejectionReason = json['rejection_reason'] as String?;
        
        // Show in-app notification
        _showProductApprovalNotification(
          productName ?? 'Your product',
          status ?? '',
          rejectionReason,
        );
      } catch (e) {
        debugPrint('Error parsing product approval: $e');
      }
    });

    // Subscribe to all seller orders channel - NEW ORDERS
    await pusher.subscribeToChannel('private-seller.orders');
    
    pusher.bindEvent('private-seller.orders', 'order.new', (data) {
      debugPrint('🆕 NEW ORDER RECEIVED: $data');
      
      try {
        final json = data is String ? jsonDecode(data) : data;
        final orderId = json['order_id'];
        final total = json['total'];
        final buyerName = json['buyer']?['name'] as String?;
        
        if (orderId is int) {
          final order = SellerOrder(
            id: orderId,
            orderNumber: orderId.toString(),
            status: 'pending',
            createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
            customerName: buyerName,
            customerPhone: json['buyer']?['phone'] as String?,
            shippingAddress: null,
            items: const [],
            totalPrice: (total is num) ? total.toDouble() : double.tryParse(total?.toString() ?? '') ?? 0,
            trackingNumber: null,
            shippedAt: null,
            deliveredAt: null,
            cancellationReason: null,
          );
          container.read(sellerOrdersRealtimeProvider(null).notifier).applyNewOrder(order);
        }
        
        // Show in-app notification
        _showNewOrderNotification(orderId, total, buyerName ?? 'Customer');
      } catch (e) {
        debugPrint('Error parsing new order: $e');
      }
    });
  }

  /// Subscribe to public blog updates
  static Future<void> _subscribeToBlogUpdates(
    PusherService pusher,
    ProviderContainer container,
  ) async {
    await pusher.subscribeToChannel('blog-updates');
    
    pusher.bindEvent('blog-updates', 'blog.published', (data) {
      debugPrint('📝 New blog published: $data');
      try {
        final json = data is String ? jsonDecode(data) : data;
        if (json is! Map<String, dynamic>) {
          return;
        }
        final title = json['title'] as String?;
        final blog = BlogPost.fromJson(json);
        container.read(blogRealtimeProvider.notifier).addBlog(blog);
        _showBlogUpdateNotification(title ?? blog.title);
      } catch (e) {
        debugPrint('Error parsing blog: $e');
      }
    });
  }

  // In-app notification show functions
  static void _showOrderUpdateNotification(int orderId, String status) {
    final context = pusherNavigatorKey.currentContext;
    if (context == null) return;

    String message = 'Order #$orderId is now $status';
    IconData icon = Icons.local_shipping;
    
    if (status == 'completed') {
      message = 'Order #$orderId has been delivered!';
      icon = Icons.check_circle;
    } else if (status == 'processing') {
      message = 'Order #$orderId is being processed';
      icon = Icons.hourglass_empty;
    }

    InAppNotification.show(
      context,
      title: 'Order Update',
      message: message,
      icon: icon,
      backgroundColor: const Color(0xFF603814),
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.orders);
      },
    );
  }

  static void _showCartUpdateNotification(int itemsCount) {
    final context = pusherNavigatorKey.currentContext;
    if (context == null) return;

    InAppNotification.show(
      context,
      title: 'Cart Synced',
      message: 'Your cart has been updated ($itemsCount items)',
      icon: Icons.shopping_cart,
      backgroundColor: const Color(0xFFFDAF40),
      onTap: () {
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }

  static void _showSellerApprovalNotification(
    String status,
    String? businessName,
    String? rejectionReason,
  ) {
    final context = pusherNavigatorKey.currentContext;
    if (context == null) return;

    if (status == 'approved') {
      InAppNotification.show(
        context,
        title: '🎉 Seller Account Approved!',
        message: '$businessName is now live on Ojaewa!',
        icon: Icons.celebration,
        backgroundColor: const Color(0xFF28A745),
        onTap: () {
          Navigator.of(context).pushNamed(AppRoutes.yourShopDashboard);
        },
      );
    } else {
      InAppNotification.show(
        context,
        title: 'Seller Application Update',
        message: rejectionReason ?? 'Your application needs review',
        icon: Icons.info,
        backgroundColor: const Color(0xFFDC3545),
        onTap: () {
          Navigator.of(context).pushNamed(AppRoutes.sellerApprovalStatus);
        },
      );
    }
  }

  static void _showProductApprovalNotification(
    String productName,
    String status,
    String? rejectionReason,
  ) {
    final context = pusherNavigatorKey.currentContext;
    if (context == null) return;

    if (status == 'approved') {
      InAppNotification.show(
        context,
        title: '✅ Product Approved',
        message: '$productName is now live!',
        icon: Icons.check_circle,
        backgroundColor: const Color(0xFF28A745),
        onTap: () {
          Navigator.of(context).pushNamed(AppRoutes.yourShopDashboard);
        },
      );
    } else {
      InAppNotification.show(
        context,
        title: '❌ Product Rejected',
        message: rejectionReason ?? '$productName needs changes',
        icon: Icons.cancel,
        backgroundColor: const Color(0xFFDC3545),
        onTap: () {
          Navigator.of(context).pushNamed(AppRoutes.yourShopDashboard);
        },
      );
    }
  }

  static void _showNewOrderNotification(int orderId, dynamic total, String buyerName) {
    final context = pusherNavigatorKey.currentContext;
    if (context == null) return;

    InAppNotification.show(
      context,
      title: '🛍️ New Order Received!',
      message: 'Order #$orderId from $buyerName',
      icon: Icons.notifications_active,
      backgroundColor: const Color(0xFFFDAF40),
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.yourShopDashboard);
      },
    );
  }

  static void _showBlogUpdateNotification(String title) {
    final context = pusherNavigatorKey.currentContext;
    if (context == null) return;

    InAppNotification.show(
      context,
      title: '📰 New Blog Post',
      message: title,
      icon: Icons.article,
      backgroundColor: const Color(0xFF603814),
      onTap: () {
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
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
