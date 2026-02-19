import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bootstrap/app_bootstrap.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import '../core/deep_links/deep_link_handler.dart';
import '../core/network/network_providers.dart';
import '../core/widgets/offline_screen.dart';
import '../core/auth/auth_providers.dart';
import '../core/subscriptions/subscription_controller.dart';
import '../core/notifications/fcm_service.dart';
import '../core/realtime/pusher_listeners.dart';
import '../core/realtime/pusher_providers.dart';
import '../core/network/dio_clients.dart';
import '../core/realtime/pusher_service.dart';

/// Global navigator key for deep link navigation
final navigatorKey = GlobalKey<NavigatorState>();

/// Root widget for the application.
class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    // Initialize deep link handler after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(deepLinkHandlerProvider).init(navigatorKey);
    });
  }

  Future<void> _ensurePusherConnected(WidgetRef ref, PusherService pusherService) async {
    if (!pusherService.isInitialized) {
      final dio = ref.read(laravelDioProvider);
      await pusherService.initialize(dio: dio);
    }
    PusherListeners.setupListeners(ref.container, pusherService);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      builder: (context, child) {
        return Consumer(
          builder: (context, ref, _) {
            final isOnline = ref.watch(isOnlineProvider);
            final token = ref.watch(accessTokenProvider);
            final content = AppBootstrap(child: child ?? const SizedBox.shrink());

            if (token != null && token.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final pusherService = ref.read(pusherServiceProvider);
                _ensurePusherConnected(ref, pusherService);
              });
            }

            ref.listen<String?>(accessTokenProvider, (prev, next) async {
              final pusherService = ref.read(pusherServiceProvider);
              if (next != null && next.isNotEmpty) {
                ref.read(subscriptionControllerProvider.notifier).refreshStatus();
                await _ensurePusherConnected(ref, pusherService);
                // FCM init now happens only when user explicitly enables push in settings.
              } else if (prev != null && prev.isNotEmpty) {
                // Cleanup when user logs out.
                final userId = PusherListeners.currentUserId;
                PusherListeners.unsubscribeAll(pusherService, userId);
                PusherListeners.setCurrentUserId(null);
                PusherListeners.resetListeners();
                ref.read(fcmServiceProvider).deleteToken();
              }
            });

            if (isOnline) {
              return content;
            }

            return Stack(
              children: [
                content,
                Positioned.fill(
                  child: OfflineScreen(
                    onRetry: () => ref.invalidate(connectivityProvider),
                  ),
                ),
              ],
            );
          },
        );
      },
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRoutes.splash,
    );
  }
}
