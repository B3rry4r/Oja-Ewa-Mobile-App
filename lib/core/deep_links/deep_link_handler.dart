import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/router/app_router.dart';
import '../../app/theme/app_theme_colors.dart';
import '../../features/app_services/cac/presentation/controllers/cac_payment_controller.dart';
import '../../features/app_services/nepc/presentation/controllers/nepc_payment_controller.dart';
import '../../features/blog/presentation/single_blog.dart';
import '../../features/home/subfeatures/schools/presentation/controllers/school_registration_controller.dart';
import '../../features/orders/presentation/controllers/orders_controller.dart';
import '../../features/product_detail/presentation/product_detail_screen.dart';
import '../../features/product_detail/presentation/seller_profile.dart';
import '../ui/snackbars.dart';

/// Handles deep links for the app, particularly payment callbacks (Paystack and MoMo).
///
/// Expected callback URL formats:
/// - Paystack: ojaewa://payment/callback?reference=xxx&status=success
/// - MoMo: ojaewa://payment/callback?status=success&reference=xxx&order_id=123&gateway=momo
class DeepLinkHandler {
  DeepLinkHandler(this._ref, {AppLinks? appLinks})
    : _appLinks = appLinks ?? AppLinks();

  final Ref _ref;
  final AppLinks _appLinks;
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

    if (uri.scheme != 'ojaewa') return;

    // Handle order payment callback: ojaewa://payment/callback?reference=xxx
    if (uri.host == 'payment') {
      final path = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
      if (path == 'callback') {
        _handlePaymentCallback(uri);
      }
    }

    // Handle school payment callback: ojaewa://school/payment/callback?reference=xxx
    if (uri.host == 'school') {
      final pathSegments = uri.pathSegments;
      if (pathSegments.length >= 2 &&
          pathSegments[0] == 'payment' &&
          pathSegments[1] == 'callback') {
        _handleSchoolPaymentCallback(uri);
      }
    }

    // Handle CAC payment callback: ojaewa://cac/payment/callback?reference=xxx
    if (uri.host == 'cac') {
      final pathSegments = uri.pathSegments;
      if (pathSegments.length >= 2 &&
          pathSegments[0] == 'payment' &&
          pathSegments[1] == 'callback') {
        _handleCacPaymentCallback(uri);
      }
    }

if (uri.host == 'nepc') {
      final pathSegments = uri.pathSegments;
      if (pathSegments.length >= 2 &&
          pathSegments[0] == 'payment' &&
          pathSegments[1] == 'callback') {
        _handleNepcPaymentCallback(uri);
      }
    }

    // Handle product deep link: ojaewa://product/123
    if (uri.host == 'product' && uri.pathSegments.isNotEmpty) {
      final productId = int.tryParse(uri.pathSegments.first);
      if (productId != null) {
        _navigateToProduct(productId);
      }
    }

    // Handle seller profile deep link: ojaewa://seller/123
    if (uri.host == 'seller' && uri.pathSegments.isNotEmpty) {
      final sellerId = int.tryParse(uri.pathSegments.first);
      if (sellerId != null) {
        _navigateToSeller(sellerId);
      }
    }

    // Handle blog deep link: ojaewa://blog/some-slug
    if (uri.host == 'blog' && uri.pathSegments.isNotEmpty) {
      final blogSlug = uri.pathSegments.first;
      _navigateToBlog(blogSlug);
    }
  }

  void _navigateToProduct(int productId) {
    final context = _navigatorKey?.currentContext;
    if (context == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(productId: productId),
      ),
    );
  }

  void _navigateToSeller(int sellerId) {
    final context = _navigatorKey?.currentContext;
    if (context == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SellerProfileScreen(sellerId: sellerId),
      ),
    );
  }

  void _navigateToBlog(String slug) {
    final context = _navigatorKey?.currentContext;
    if (context == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlogDetailScreen(blogSlug: slug),
      ),
    );
  }
    }

    // Handle product deep link: ojaewa://product/123
    if (uri.host == 'product' && uri.pathSegments.isNotEmpty) {
      final productId = int.tryParse(uri.pathSegments.first);
      if (productId != null) {
        _navigateToProduct(productId);
      }
    }

    // Handle seller profile deep link: ojaewa://seller/123
    if (uri.host == 'seller' && uri.pathSegments.isNotEmpty) {
      final sellerId = int.tryParse(uri.pathSegments.first);
      if (sellerId != null) {
        _navigateToSeller(sellerId);
      }
    }

    // Handle blog deep link: ojaewa://blog/some-slug
    if (uri.host == 'blog' && uri.pathSegments.isNotEmpty) {
      final blogSlug = uri.pathSegments.first;
      _navigateToBlog(blogSlug);
    }

    // Handle advert deep link: ojaewa://ad/123
    if (uri.host == 'ad' && uri.pathSegments.isNotEmpty) {
      final adId = uri.pathSegments.first;
      _showInfo('Ad view: $adId - Opens in app soon');
    }
  }

  Future<void> _handlePaymentCallback(Uri uri) async {
    final reference = uri.queryParameters['reference'];
    final status = uri.queryParameters['status'];
    final gateway =
        uri.queryParameters['gateway']; // 'momo' or 'paystack' or null
    final orderIdStr = uri.queryParameters['order_id'];

    final context = _navigatorKey?.currentContext;
    if (context == null) {
      debugPrint('No context available for payment callback');
      return;
    }

    // Handle MoMo callback (comes from backend redirect)
    if (gateway == 'momo') {
      _handleMoMoCallback(context, status, orderIdStr);
      return;
    }

    // Handle Paystack callback (original flow)
    if (reference == null || reference.isEmpty) {
      _showError('Invalid payment callback: missing reference');
      return;
    }

    // Show loading indicator
    _showLoading(context, 'Verifying payment...');

    try {
      // Verify payment with backend
      final result = await _ref
          .read(orderActionsProvider.notifier)
          .verifyPayment(reference: reference);

      // Hide loading
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      if (result.status == 'success' || status == 'success') {
        _showPaymentSuccess(context, result.orderId);
      } else {
        _showPaymentFailed(
          context,
          'Payment verification failed. Status: ${result.status}',
        );
      }
    } catch (e) {
      // Hide loading
      if (!context.mounted) return;
      Navigator.of(context).pop();
      _showError('Failed to verify payment: $e');
    }
  }

  void _handleMoMoCallback(
    BuildContext context,
    String? status,
    String? orderIdStr,
  ) {
    // MoMo callback - payment already verified by backend
    if (status == 'success') {
      final orderId = orderIdStr != null ? int.tryParse(orderIdStr) : null;
      _showPaymentSuccess(context, orderId);
      // Invalidate orders to refresh
      _ref.invalidate(orderActionsProvider);
    } else if (status == 'failed') {
      _showPaymentFailed(context, 'MoMo payment failed. Please try again.');
    } else if (status == 'pending') {
      _showPaymentPending(context);
    } else {
      _showError('Unknown MoMo payment status: $status');
    }
  }

  Future<void> _handleSchoolPaymentCallback(Uri uri) async {
    final reference = uri.queryParameters['reference'];
    final status = uri.queryParameters['status'];

    if (reference == null || reference.isEmpty) {
      _showError('Invalid school payment callback: missing reference');
      return;
    }

    final context = _navigatorKey?.currentContext;
    if (context == null) {
      debugPrint('No context available for school payment callback');
      return;
    }

    // Show loading indicator
    _showLoading(context, 'Verifying school payment...');

    try {
      // Verify payment with backend using school registration API
      final api = _ref.read(schoolRegistrationApiProvider);
      final result = await api.verifyPayment(reference: reference);

      // Hide loading
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      final data = result['data'] as Map<String, dynamic>?;
      final paymentStatus = data?['payment_status'] as String? ?? status;

      if (paymentStatus == 'success' || status == 'success') {
        _showSchoolPaymentSuccess(context);
      } else {
        _showPaymentFailed(
          context,
          'School payment verification failed. Status: $paymentStatus',
        );
      }
    } catch (e) {
      // Hide loading
      if (!context.mounted) return;
      Navigator.of(context).pop();
      _showError('Failed to verify school payment: $e');
    }
  }

  Future<void> _handleCacPaymentCallback(Uri uri) async {
    final reference = uri.queryParameters['reference'];
    final status = uri.queryParameters['status'];

    if (reference == null || reference.isEmpty) {
      _showError('Invalid CAC payment callback: missing reference');
      return;
    }

    final context = _navigatorKey?.currentContext;
    if (context == null) {
      debugPrint('No context available for CAC payment callback');
      return;
    }

    _showLoading(context, 'Finalizing CAC request...');

    try {
      final request = await _ref
          .read(cacPaymentControllerProvider.notifier)
          .finalizePayment(reference: reference);

      if (!context.mounted) return;
      Navigator.of(context).pop();

      if (request != null || status == 'success') {
        _showCacPaymentSuccess(context);
      } else {
        final error = _ref.read(cacPaymentControllerProvider).error;
        _showPaymentFailed(
          context,
          error ?? 'CAC request could not be completed.',
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      _showError('Failed to complete CAC request: $e');
    }
  }

  Future<void> _handleNepcPaymentCallback(Uri uri) async {
    final reference = uri.queryParameters['reference'];
    final status = uri.queryParameters['status'];

    if (reference == null || reference.isEmpty) {
      _showError('Invalid NEPC payment callback: missing reference');
      return;
    }

    final context = _navigatorKey?.currentContext;
    if (context == null) {
      debugPrint('No context available for NEPC payment callback');
      return;
    }

    _showLoading(context, 'Finalizing NEPC request...');

    try {
      final request = await _ref
          .read(nepcPaymentControllerProvider.notifier)
          .finalizePayment(reference: reference);

      if (!context.mounted) return;
      Navigator.of(context).pop();

      if (request != null || status == 'success') {
        _showNepcPaymentSuccess(context);
      } else {
        final error = _ref.read(nepcPaymentControllerProvider).error;
        _showPaymentFailed(
          context,
          error ?? 'NEPC request could not be completed.',
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      _showError('Failed to complete NEPC request: $e');
    }
  }

  void _showLoading(BuildContext context, String message) {
    final colors = context.appColors;
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Loading',
      barrierColor: colors.shadow.withValues(alpha: 0.82),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      color: Color(0xFFFDAF40),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                      fontFamily: 'Campton',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPaymentSuccess(BuildContext context, int? orderId) {
    final colors = context.appColors;
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'PaymentSuccess',
      barrierColor: colors.shadow.withValues(alpha: 0.82),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: 342,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Color(0xFF4CAF50),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Payment Successful',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                        fontFamily: 'Campton',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your order has been placed successfully!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: colors.textSecondary,
                        fontFamily: 'Campton',
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                              _navigatorKey?.currentState
                                  ?.pushNamedAndRemoveUntil(
                                    '/',
                                    (route) => false,
                                  );
                            },
                            child: Container(
                              height: 57,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: colors.border),
                              ),
                              child: Center(
                                child: Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textPrimary,
                                    fontFamily: 'Campton',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                              _navigatorKey?.currentState
                                  ?.pushNamedAndRemoveUntil(
                                    '/orders',
                                    (route) => route.isFirst,
                                  );
                            },
                            child: Container(
                              height: 57,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDAF40),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFFDAF40,
                                    ).withValues(alpha: 0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'View Orders',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFFFFBF5),
                                    fontFamily: 'Campton',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSchoolPaymentSuccess(BuildContext context) {
    final colors = context.appColors;
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'SchoolPaymentSuccess',
      barrierColor: colors.shadow.withValues(alpha: 0.82),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: 342,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Color(0xFF4CAF50),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Registration Complete',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                        fontFamily: 'Campton',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your school registration payment was successful!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: colors.textSecondary,
                        fontFamily: 'Campton',
                      ),
                    ),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        _navigatorKey?.currentState?.pushNamedAndRemoveUntil(
                          '/',
                          (route) => false,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 57,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDAF40),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFFDAF40,
                              ).withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFFFBF5),
                              fontFamily: 'Campton',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCacPaymentSuccess(BuildContext context) {
    final colors = context.appColors;
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'CacPaymentSuccess',
      barrierColor: colors.shadow.withValues(alpha: 0.82),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: 342,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Color(0xFF4CAF50),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'CAC Request Submitted',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                        fontFamily: 'Campton',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your CAC payment was confirmed and your request has been submitted for review.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: colors.textSecondary,
                        fontFamily: 'Campton',
                      ),
                    ),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        _navigatorKey?.currentState?.pushNamedAndRemoveUntil(
                          '/',
                          (route) => false,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 57,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDAF40),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFFDAF40,
                              ).withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFFFBF5),
                              fontFamily: 'Campton',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showNepcPaymentSuccess(BuildContext context) {
    final colors = context.appColors;
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'NepcPaymentSuccess',
      barrierColor: colors.shadow.withValues(alpha: 0.82),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: 342,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Color(0xFF4CAF50),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'NEPC Request Submitted',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                        fontFamily: 'Campton',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your NEPC payment was confirmed and your request has been submitted for review.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: colors.textSecondary,
                        fontFamily: 'Campton',
                      ),
                    ),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        _navigatorKey?.currentState?.pushNamedAndRemoveUntil(
                          '/',
                          (route) => false,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 57,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDAF40),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFFDAF40,
                              ).withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFFFBF5),
                              fontFamily: 'Campton',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPaymentFailed(BuildContext context, String message) {
    final colors = context.appColors;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'PaymentFailed',
      barrierColor: colors.shadow.withValues(alpha: 0.82),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: 342,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error,
                        color: Color(0xFFE53935),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Payment Failed',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                        fontFamily: 'Campton',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: colors.textSecondary,
                        fontFamily: 'Campton',
                      ),
                    ),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: double.infinity,
                        height: 57,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDAF40),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFFDAF40,
                              ).withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'OK',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFFFBF5),
                              fontFamily: 'Campton',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPaymentPending(BuildContext context) {
    final colors = context.appColors;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'PaymentPending',
      barrierColor: colors.shadow.withValues(alpha: 0.82),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: 342,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.pending,
                        color: Color(0xFFFF9800),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Payment Pending',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                        fontFamily: 'Campton',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your payment is still being processed. Please check your orders later.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: colors.textSecondary,
                        fontFamily: 'Campton',
                      ),
                    ),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: double.infinity,
                        height: 57,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDAF40),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFFDAF40,
                              ).withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'OK',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFFFBF5),
                              fontFamily: 'Campton',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
