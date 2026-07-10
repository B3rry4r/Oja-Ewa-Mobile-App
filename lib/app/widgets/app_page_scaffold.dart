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
    this.scrollable,
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

  /// How the page body handles content taller than the viewport.
  ///
  /// * `null` (default): fill or scroll. The body is given at least the
  ///   viewport height, so `Spacer`/`Expanded` still centre content when there
  ///   is room, and it scrolls once the content grows taller than the screen.
  ///   This is the safe default. Forgetting to think about scrolling can no
  ///   longer strand a submit button below the fold.
  /// * `true`: always scroll. Plain [SingleChildScrollView]. The child must
  ///   not use unbounded flex (`Expanded`/`Spacer`) at its top level.
  /// * `false`: never scroll. The child is handed a bounded height, which is
  ///   what a page whose body *is* a `ListView`/`GridView` needs. Pass this
  ///   explicitly for those pages.
  final bool? scrollable;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bottomInset =
        includeBottomNavSpacing ? AppBottomNavBar.height + 32.0 : 32.0;
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
            child: AppPageBody(
              scrollable: scrollable,
              bottomInset: bottomInset,
              child: child,
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: DecoratedBox(
          decoration: BoxDecoration(color: colors.background),
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
/// The scrolling behaviour of an [AppPageScaffold] body, extracted so it can be
/// exercised directly in tests without the provider-backed [AppHeader].
///
/// See [AppPageScaffold.scrollable] for what each mode means.
class AppPageBody extends StatelessWidget {
  const AppPageBody({
    super.key,
    required this.child,
    required this.scrollable,
    this.bottomInset = 32,
  });

  final Widget child;
  final bool? scrollable;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    // Explicit opt-out: the child needs a bounded height because its body is a
    // ListView/GridView, which supplies its own scrolling.
    if (scrollable == false) return child;

    // Explicit opt-in: plain scroll view, no intrinsic pass. The child must not
    // use unbounded flex at its top level.
    if (scrollable == true) {
      return SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: child,
      );
    }

    // Default: fill or scroll. ConstrainedBox(minHeight) makes the child at
    // least as tall as the viewport, so Spacer/Expanded still distribute the
    // slack, and IntrinsicHeight gives the Column a bounded height so that flex
    // resolves instead of throwing inside the scroll view. Once the content
    // outgrows the viewport it simply scrolls.
    return LayoutBuilder(
      builder: (context, constraints) {
        final minHeight =
            (constraints.maxHeight - bottomInset).clamp(0.0, double.infinity);
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: IntrinsicHeight(child: child),
          ),
        );
      },
    );
  }
}
