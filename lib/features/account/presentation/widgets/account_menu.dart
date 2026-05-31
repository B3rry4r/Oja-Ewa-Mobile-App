import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ojaewa/core/theme/wb_theme_exports.dart';
import 'package:ojaewa/core/widgets/wb_icon.dart';

/// One row inside an [AccountMenuSection] — a 36-square icon tile + label +
/// optional sub-text + chevron. Mirrors the WAWUBasket account menu, using the
/// app's SVG icon assets. `danger` paints the tile/label red (sign-out, delete).
class AccountMenuRow {
  const AccountMenuRow({
    required this.iconAsset,
    required this.label,
    required this.onTap,
    this.sub,
    this.trailing,
    this.danger = false,
  });

  final String iconAsset;
  final String label;
  final String? sub;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool danger;
}

/// A titled group of rows. `title` may be empty for the destructive section.
class AccountMenuSection {
  const AccountMenuSection({required this.title, required this.rows});
  final String title;
  final List<AccountMenuRow> rows;
}

/// Renders one [AccountMenuSection] as a single rounded WB card with hairline
/// dividers between rows.
class AccountMenuSectionCard extends StatelessWidget {
  const AccountMenuSectionCard({super.key, required this.section});
  final AccountMenuSection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WBColors.surfaceCard,
        borderRadius: BorderRadius.circular(WBRadius.card),
        boxShadow: WBShadows.card,
      ),
      padding: const EdgeInsets.symmetric(horizontal: WBSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 2),
              child: Text(
                section.title.toUpperCase(),
                style: WBTypography.label.copyWith(
                  fontWeight: FontWeight.w600,
                  color: WBColors.fgPlaceholder,
                  letterSpacing: 0.66,
                ),
              ),
            ),
          for (var i = 0; i < section.rows.length; i++)
            _MenuRowView(
              spec: section.rows[i],
              showDivider: i != section.rows.length - 1,
            ),
        ],
      ),
    );
  }
}

class _MenuRowView extends StatelessWidget {
  const _MenuRowView({required this.spec, required this.showDivider});
  final AccountMenuRow spec;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final fg = spec.danger ? WBColors.statusError : WBColors.fgHeader;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: spec.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(bottom: BorderSide(color: WBColors.bgDivider))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: spec.danger ? const Color(0x14EF4444) : WBColors.bgSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                spec.iconAsset,
                width: 17,
                height: 17,
                colorFilter: ColorFilter.mode(fg, BlendMode.srcIn),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spec.label,
                    style: WBTypography.body.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: fg,
                    ),
                  ),
                  if (spec.sub != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      spec.sub!,
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (spec.trailing != null)
              spec.trailing!
            else
              WBIcon(
                WBIconName.chevronRight,
                size: 16,
                color: spec.danger ? WBColors.statusError : WBColors.fgPlaceholder,
              ),
          ],
        ),
      ),
    );
  }
}
