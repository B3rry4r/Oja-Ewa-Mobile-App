import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/orders/presentation/controllers/orders_controller.dart';
import '../ui/snackbars.dart';

/// Handles deep links for the app, particularly Paystack payment callbacks.
/// 
/// Expected callback URL format: ojaewa://payment/callback?reference=xxx&status=success
class DeepLinkHandler {
  DeepLinkHandler(this._ref);

  final Ref _ref;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;
  
  GlobalKey<NavigatorState>? _navigatorKey;

  /// Initialize the deep link handler with a navigator key for navigation
  void init(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    _subscription = _appLinks.uriLinkStream.listen(_handleDeepLink);
    
    // Also check for initial link (app opened via deep link)
    _checkInitialLink();
  }

  Future<void> _checkInitialLink() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('Error getting initial deep link: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Deep link received: $uri');

    // Handle payment callback: ojaewa://payment/callback?reference=xxx
    if (uri.scheme == 'ojaewa' && uri.host == 'payment') {
      final path = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
      
      if (path == 'callback') {
        _handlePaymentCallback(uri);
      }
    }
  }

  Future<void> _handlePaymentCallback(Uri uri) async {
    final reference = uri.queryParameters['reference'];
    final status = uri.queryParameters['status'];

    if (reference == null || reference.isEmpty) {
      _showError('Invalid payment callback: missing reference');
      return;
    }

    final context = _navigatorKey?.currentContext;
    if (context == null) {
      debugPrint('No context available for payment callback');
      return;
    }

    // Show loading indicator
    _showLoading(context, 'Verifying payment...');

    try {
      // Verify payment with backend
      final result = await _ref.read(orderActionsProvider.notifier).verifyPayment(reference: reference);
      
      // Hide loading
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
      }

      if (result.status == 'success' || status == 'success') {
        _showPaymentSuccess(context, result.orderId);
      } else {
        _showPaymentFailed(context, 'Payment verification failed. Status: ${result.status}');
      }
    } catch (e) {
      // Hide loading
      if (context.mounted) {
        Navigator.of(context).pop();
        _showError('Failed to verify payment: $e');
      }
    }
  }

  void _showLoading(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  void _showPaymentSuccess(BuildContext context, int? orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Payment Successful'),
          ],
        ),
        content: const Text('Your order has been placed successfully!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // Navigate to order details or orders list
              _navigatorKey?.currentState?.pushNamedAndRemoveUntil(
                '/orders',
                (route) => route.isFirst,
              );
            },
            child: const Text('View Orders'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // Go back to home
              _navigatorKey?.currentState?.pushNamedAndRemoveUntil(
                '/',
                (route) => false,
              );
            },
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  void _showPaymentFailed(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Payment Failed'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    final context = _navigatorKey?.currentContext;
    if (context != null && context.mounted) {
      AppSnackbars.showError(context, message);
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}

final deepLinkHandlerProvider = Provider<DeepLinkHandler>((ref) {
  final handler = DeepLinkHandler(ref);
  ref.onDispose(handler.dispose);
  return handler;
});
