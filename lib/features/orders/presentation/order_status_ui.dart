import 'package:flutter/material.dart';

class OrderStatusUi {
  static String label(String? status) {
    final s = (status ?? 'pending').toLowerCase();
    return switch (s) {
      'pending' => 'Pending',
      'paid' => 'Paid',
      'processing' => 'Processing',
      'shipped' => 'Shipped',
      'out_for_delivery' => 'Out for Delivery',
      'delivered' => 'Delivered',
      'cancelled' => 'Cancelled',
      _ => s.isEmpty ? 'Pending' : (s[0].toUpperCase() + s.substring(1)),
    };
  }

  static Color color(String? status) {
    final s = (status ?? 'pending').toLowerCase();
    return switch (s) {
      'delivered' => const Color(0xFF70B673),
      'shipped' => const Color(0xFF3095CE),
      'out_for_delivery' => const Color(0xFF3095CE),
      'processing' => const Color(0xFF3095CE),
      'paid' => const Color(0xFF3095CE),
      'cancelled' => const Color(0xFFCCCCCC),
      'pending' => const Color(0xFFFDAF40),
      _ => const Color(0xFF3095CE),
    };
  }
}
