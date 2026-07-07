import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ojaewa/app/theme/app_theme_colors.dart';
import '../../core/audio/audio_controller.dart';
import '../../core/audio/audio_controls.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../core/auth/auth_providers.dart';
import '../../core/auth/auth_required_modal.dart';
import '../../core/notifications/fcm_service.dart';
import '../../core/widgets/in_app_notification.dart';
import '../router/app_router.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/business_details/presentation/screens/business_details_screen.dart';
import '../../features/product_detail/presentation/product_detail_screen.dart';
import '../../features/product_detail/presentation/seller_profile.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/services/presentation/services_screen.dart';
import '../../features/wishlist/presentation/wishlist.dart';
import '../../features/account/presentation/account.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../../features/categories/presentation/controllers/category_controller.dart';
import '../../features/account/subfeatures/start_selling/presentation/controllers/seller_status_controller.dart';

/// App-level shell that owns the bottom navigation.
///
/// Only tab screens (e.g. Home/Search) live under this shell.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Only play background music when the user is authenticated
      final token = ref.read(accessTokenProvider);
      if (token != null && token.isNotEmpty) {
        ref.read(audioControllerProvider.notifier).initialize();
      }
      // Prefetch categories for smoother UX
      ref.read(allCategoriesProvider);

      // Wire up foreground FCM message display as in-app banner
      ref
          .read(fcmServiceProvider)
          .setOnMessageCallback(_handleForegroundMessage);
      ref
          .read(fcmServiceProvider)
          .setOnNotificationTapCallback(_handleNotificationTap);
    });
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (!mounted) return;
    final title = message.notification?.title ?? 'Notification';
    final body = message.notification?.body ?? '';

    // Use the navigator overlay safely
    BuildContext? targetContext;
    try {
      targetContext = Navigator.of(
        context,
        rootNavigator: true,
      ).overlay?.context;
    } catch (_) {
      // Navigator not ready
    }

    if (targetContext != null && mounted) {
      InAppNotification.show(
        targetContext,
        title: title,
        message: body,
        onTap: () => _handleNotificationTap(message.data),
      );
    } else if (mounted) {
      // Fallback to shell context
      InAppNotification.show(
        context,
        title: title,
        message: body,
        onTap: () => _handleNotificationTap(message.data),
      );
    }
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    if (!mounted) return;

    // Test notifications are the only payloads that carry a `type` key.
    if (data['type'] == 'test') {
      Navigator.of(context).pushNamed(AppRoutes.notifications);
      return;
    }

    // Real order/business/seller/product payloads route off `deep_link`.
    final deepLink = data['deep_link'] as String?;
    if (deepLink != null &&
        deepLink.isNotEmpty &&
        _navigateByDeepLink(deepLink, data)) {
      return;
    }

    // Fall back to the *_id keys when there's no usable deep link.
    if (_navigateByIds(data)) return;

    // Nothing matched — show the notifications list.
    Navigator.of(context).pushNamed(AppRoutes.notifications);
  }

  /// Route off the notification `deep_link` path. Returns true if it handled
  /// navigation, false if the caller should fall back to the *_id keys.
  bool _navigateByDeepLink(String deepLink, Map<String, dynamic> data) {
    final Uri uri;
    try {
      uri = Uri.parse(deepLink);
    } catch (_) {
      return false;
    }
    final segments = uri.pathSegments;
    if (segments.isEmpty) return false;

    final second = segments.length >= 2 ? segments[1] : null;

    switch (segments.first) {
      case 'business':
        final id = _intFrom(second) ?? _intFrom(data['business_id']);
        if (id != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BusinessDetailsScreen(businessId: id),
            ),
          );
          return true;
        }
        return false;
      case 'products':
      case 'product':
        final id =
            _intFrom(second) ?? _intFrom(data['product_id'] ?? data['id']);
        if (id != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(productId: id),
            ),
          );
          return true;
        }
        return false;
      case 'orders':
        final id = _intFrom(second) ?? _intFrom(data['order_id']);
        if (id != null) {
          Navigator.of(context)
              .pushNamed(AppRoutes.orderDetails, arguments: id);
        } else {
          Navigator.of(context).pushNamed(AppRoutes.orders);
        }
        return true;
      case 'seller':
        // /seller/profile → this user's approval status
        if (second == 'profile') {
          Navigator.of(context).pushNamed(AppRoutes.sellerApprovalStatus);
          return true;
        }
        // /seller/{id} → public seller profile
        final id = _intFrom(second) ?? _intFrom(data['seller_id']);
        if (id != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SellerProfileScreen(sellerId: id),
            ),
          );
          return true;
        }
        return false;
      case 'subscription':
        // manage / payment / renew → subscription & payment management
        Navigator.of(context).pushNamed(AppRoutes.managePayment);
        return true;
      case 'profile':
        // /profile/edit → edit profile
        Navigator.of(context).pushNamed(AppRoutes.editProfile);
        return true;
      default:
        return false;
    }
  }

  /// Fallback routing using the `*_id` keys when no deep link matched.
  bool _navigateByIds(Map<String, dynamic> data) {
    final orderId = _intFrom(data['order_id']);
    if (orderId != null) {
      Navigator.of(context)
          .pushNamed(AppRoutes.orderDetails, arguments: orderId);
      return true;
    }
    final businessId = _intFrom(data['business_id']);
    if (businessId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BusinessDetailsScreen(businessId: businessId),
        ),
      );
      return true;
    }
    final sellerId = _intFrom(data['seller_id']);
    if (sellerId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SellerProfileScreen(sellerId: sellerId),
        ),
      );
      return true;
    }
    return false;
  }

  int? _intFrom(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  @override
  Widget build(BuildContext context) {
    final token = ref.watch(accessTokenProvider);
    final isLoggedIn = token != null && token.isNotEmpty;

    return Scaffold(
      extendBody: true,
      backgroundColor: context.appColors.background,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        // padding: const EdgeInsets.only(bottom: AppBottomNavBar.height + 16),
        child: _buildFloatingButtons(context, isLoggedIn),
      ),
      body: IndexedStack(
        index: _index,
        children: [
          const HomeScreen(),
          const SearchScreen(),
          const ServicesScreen(),
          WishlistScreen(
            onKeepShoppingPressed: () => setState(() => _index = 0),
          ),
          const AccountScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }

  Widget _buildFloatingButtons(BuildContext context, bool isLoggedIn) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const AudioControlsButton(),
        const SizedBox(height: 10),
        const SizedBox(height: 10),
        FloatingActionButton.extended(
          heroTag: 'start-selling-fab',
          onPressed: () => _navigateToStartSelling(context, ref),
          backgroundColor: context.appColors.accent,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.storefront, size: 24),
          label: const Text(
            'Start Selling',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _navigateToStartSelling(BuildContext context, WidgetRef ref) async {
    // Guest-first gate: intercept before navigating into seller onboarding,
    // which fires authenticated requests / is AuthGuard-protected.
    if (!await ensureSignedIn(context, ref, action: 'start selling')) {
      return;
    }
    if (!context.mounted) return;

    final isSellerApproved = ref.read(isSellerApprovedProvider);

    // Check seller status and navigate accordingly
    // This mirrors the logic in account.dart to prevent navigation loops
    Navigator.of(context).pushNamed(
      isSellerApproved
          ? AppRoutes.yourShopDashboard
          : AppRoutes.sellerOnboarding,
    );
  }
}
