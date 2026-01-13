import 'package:flutter/foundation.dart';

@immutable
class NotificationPreferences {
  const NotificationPreferences({
    required this.allowPushNotifications,
    required this.newProducts,
    required this.discountAndSales,
    required this.newBlogPosts,
    required this.newOrders,
  });

  final bool allowPushNotifications;
  final bool newProducts;
  final bool discountAndSales;
  final bool newBlogPosts;
  final bool newOrders;

  static NotificationPreferences fromJson(Map<String, dynamic> json) {
    // Try common backend fields.
    bool b(String key) => (json[key] as bool?) ?? false;

    return NotificationPreferences(
      allowPushNotifications: b('allow_push_notifications') || b('push_notifications'),
      newProducts: b('new_products'),
      discountAndSales: b('discount_and_sales') || b('discounts_and_sales'),
      newBlogPosts: b('new_blog_posts') || b('blog_posts'),
      newOrders: b('new_orders') || b('orders'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allow_push_notifications': allowPushNotifications,
      'new_products': newProducts,
      'discount_and_sales': discountAndSales,
      'new_blog_posts': newBlogPosts,
      'new_orders': newOrders,
    };
  }

  NotificationPreferences copyWith({
    bool? allowPushNotifications,
    bool? newProducts,
    bool? discountAndSales,
    bool? newBlogPosts,
    bool? newOrders,
  }) {
    return NotificationPreferences(
      allowPushNotifications: allowPushNotifications ?? this.allowPushNotifications,
      newProducts: newProducts ?? this.newProducts,
      discountAndSales: discountAndSales ?? this.discountAndSales,
      newBlogPosts: newBlogPosts ?? this.newBlogPosts,
      newOrders: newOrders ?? this.newOrders,
    );
  }
}
