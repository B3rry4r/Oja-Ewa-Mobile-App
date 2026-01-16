import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bootstrap/app_bootstrap.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import '../core/deep_links/deep_link_handler.dart';
import '../core/network/network_providers.dart';
import '../core/widgets/offline_screen.dart';

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
            final content = AppBootstrap(child: child ?? const SizedBox.shrink());

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
