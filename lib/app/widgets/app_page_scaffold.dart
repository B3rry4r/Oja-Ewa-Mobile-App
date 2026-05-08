import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/app/widgets/app_bottom_nav_bar.dart';
import 'package:ojaewa/app/theme/app_theme_colors.dart';

class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    super.key,
    this.title,
    required this.child,
    this.bottomBar,
    this.showBack,
    this.showActions = true,
    this.onBack,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.includeBottomNavSpacing = false,
    this.scrollable = false,
    this.headerTitle,
  });

  final String? title;
  final Widget? headerTitle;
  final Widget child;
  final Widget? bottomBar;
  final bool? showBack;
  final bool showActions;
  final VoidCallback? onBack;
  final EdgeInsetsGeometry padding;
  final bool includeBottomNavSpacing;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final body = Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
          ],
          Expanded(
            child: scrollable
                ? SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom: includeBottomNavSpacing
                          ? AppBottomNavBar.height + 32
                          : 32,
                    ),
                    child: child,
                  )
                : child,
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.background,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                isDark ? colors.surface : colors.surfaceSecondary,
                colors.background,
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                AppHeader(
                  showBack: showBack,
                  showActions: showActions,
                  onBack: onBack,
                  title: headerTitle,
                ),
                const SizedBox(height: 4),
                Expanded(child: body),
                if (bottomBar != null) bottomBar!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}