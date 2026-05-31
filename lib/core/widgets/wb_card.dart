import 'package:flutter/material.dart';

import '../theme/wb_theme_exports.dart';

/// A floating white card with the system's `card` shadow and 24px radius.
class WBCard extends StatelessWidget {
  const WBCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(WBSpacing.lg),
    this.color = WBColors.surfaceCard,
    this.radius = WBRadius.card,
    this.shadow,
    this.clip = Clip.antiAlias,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final double radius;
  final List<BoxShadow>? shadow;
  final Clip clip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadow ?? WBShadows.card,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: clip,
        child: Padding(padding: padding, child: child),
      ),
    );
    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: card);
  }
}

/// Hairline divider (1px @ #E4E4E4), used inside cards & list rows.
class WBDivider extends StatelessWidget {
  const WBDivider({super.key, this.indent = 0, this.endIndent = 0});
  final double indent;
  final double endIndent;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: EdgeInsets.only(left: indent, right: endIndent),
      color: WBColors.bgDivider,
    );
  }
}
