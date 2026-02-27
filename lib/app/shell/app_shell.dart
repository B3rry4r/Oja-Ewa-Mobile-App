import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio/audio_controller.dart';
import '../../core/audio/audio_controls.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../core/auth/auth_providers.dart';
import '../../core/notifications/fcm_service.dart';
import '../../core/widgets/in_app_notification.dart';
import '../router/app_router.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/wishlist/presentation/wishlist.dart';
import '../../features/blog/presentation/blog.dart';
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
      ref.read(fcmServiceProvider).setOnMessageCallback(_handleForegroundMessage);
      ref.read(fcmServiceProvider).setOnNotificationTapCallback(_handleNotificationTap);
    });
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (!mounted) return;
    final title = message.notification?.title ?? 'Notification';
    final body = message.notification?.body ?? '';
    
    // Use the navigator overlay safely
    BuildContext? targetContext;
    try {
      targetContext = Navigator.of(context, rootNavigator: true).overlay?.context;
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
    final type = data['type'] as String?;
    final id = data['id'];
    final orderId = data['order_id'] ?? id;
    final productId = data['product_id'] ?? id;

    switch (type) {
      case 'order':
      case 'order_status':
        if (orderId != null) {
          Navigator.of(context).pushNamed(
            AppRoutes.orderDetails,
            arguments: int.tryParse(orderId.toString()),
          );
        } else {
          Navigator.of(context).pushNamed(AppRoutes.orders);
        }
        break;
      case 'new_order':
        // Seller receiving new order - go to shop orders
        Navigator.of(context).pushNamed(AppRoutes.yourShopDashboard);
        break;
      case 'product':
      case 'product_approval':
        if (productId != null) {
          Navigator.of(context).pushNamed(
            AppRoutes.yourShopDashboard,
          );
        }
        break;
      case 'blog':
        setState(() => _index = 3); // Blog tab index
        break;
      case 'seller_approval':
        Navigator.of(context).pushNamed(AppRoutes.sellerApprovalStatus);
        break;
      case 'business_approval':
        Navigator.of(context).pushNamed(AppRoutes.businessApprovalStatus);
        break;
      case 'cart':
        Navigator.of(context).pushNamed(AppRoutes.cart);
        break;
      case 'test':
        Navigator.of(context).pushNamed(AppRoutes.notifications);
        break;
      default:
        Navigator.of(context).pushNamed(AppRoutes.notifications);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final token = ref.watch(accessTokenProvider);
    final isLoggedIn = token != null && token.isNotEmpty;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
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
          WishlistScreen(
            onKeepShoppingPressed: () => setState(() => _index = 0),
          ),
          const BlogScreen(),
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
        /*
        if (isLoggedIn) ...[
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'ai-chat-fab',
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.aiChat),
            backgroundColor: const Color(0xFF603814),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.auto_awesome, size: 24),
            label: const Text(
              'Ask AI',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        */
        const SizedBox(height: 10),
        FloatingActionButton.extended(
          heroTag: 'start-selling-fab',
          onPressed: () => _navigateToStartSelling(context, ref),
          backgroundColor: const Color(0xFFFDAF40),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.storefront, size: 24),
          label: const Text(
            'Start Selling',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
      ],
    );
  }

  void _navigateToStartSelling(BuildContext context, WidgetRef ref) {
    final isSellerApproved = ref.read(isSellerApprovedProvider);
    
    // Check seller status and navigate accordingly
    // This mirrors the logic in account.dart to prevent navigation loops
    Navigator.of(context).pushNamed(
      isSellerApproved ? AppRoutes.yourShopDashboard : AppRoutes.sellerOnboarding,
    );
  }
}
