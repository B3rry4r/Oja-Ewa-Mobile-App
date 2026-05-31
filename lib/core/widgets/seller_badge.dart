import 'package:flutter/material.dart';
import 'package:ojaewa/app/theme/app_theme_colors.dart';

class SellerBadge extends StatelessWidget {
  final String? badge;

  const SellerBadge({super.key, this.badge});

  /// Single source of truth for badge → display label.
  /// Badges currently live in three places (this widget, the account screen,
  /// and the API). Keep them aligned with this helper.
  static String? labelFor(String? badge) {
    switch (badge) {
      case 'certified_authentic':
        return 'White Badge Active';
      case 'heritage_artisan':
        return 'Gold Badge Active';
      case 'sustainable_innovator':
        return 'Green Badge Active';
      default:
        return null;
    }
  }

  /// Background color for the badge pill. Returns null for unknown badges.
  static Color? backgroundFor(String? badge) {
    switch (badge) {
      case 'certified_authentic':
        return const Color(0xFFF5F5F5);
      case 'heritage_artisan':
        return const Color(0xFFD4AF37);
      case 'sustainable_innovator':
        return const Color(0xFF2E7D32);
      default:
        return null;
    }
  }

  /// Foreground (icon + text) color paired with [backgroundFor].
  static Color foregroundFor(String? badge) {
    switch (badge) {
      case 'certified_authentic':
      case 'heritage_artisan':
        return const Color(0xFF111111);
      default:
        return const Color(0xFFFFFFFF);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (badge == null || badge!.isEmpty) {
      return const SizedBox.shrink(); // Don't show "None" badge
    }

    switch (badge) {
      case "certified_authentic":
        return _buildBadge(
          context,
          "Certified Authentic",
          const Color(0xFFF5F5F5),
          const Color(0xFF111111),
          borderColor: const Color(0xFFD0D0D0),
        );
      case "heritage_artisan":
        return _buildBadge(
          context,
          "Heritage Artisan",
          const Color(0xFFD4AF37),
          Colors.white,
        );
      case "sustainable_innovator":
        return _buildBadge(
          context,
          "Sustainable Innovator",
          const Color(0xFF2E7D32),
          Colors.white,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBadge(
    BuildContext context,
    String text,
    Color bg,
    Color fg, {
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(
          color: borderColor ?? context.appColors.accent.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
