import 'package:flutter/material.dart';

class SellerBadge extends StatelessWidget {
  final String? badge;

  const SellerBadge({super.key, this.badge});

  @override
  Widget build(BuildContext context) {
    if (badge == null || badge!.isEmpty) {
      return const SizedBox.shrink(); // Don't show "None" badge
    }

    switch (badge) {
      case "certified_authentic":
        return _buildBadge("Certified Authentic", const Color(0xFF2B2B2B), Colors.white);
      case "heritage_artisan":
        return _buildBadge("Heritage Artisan", const Color(0xFFD4AF37), Colors.white);
      case "sustainable_innovator":
        return _buildBadge("Sustainable Innovator", const Color(0xFF2E7D32), Colors.white);
      case "design_excellence":
        return _buildBadge("Design Excellence", const Color(0xFF2F80ED), Colors.white);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBadge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: const Color(0xFF603814).withOpacity(0.2)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified,
            size: 14,
            color: fg,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: fg,
              fontFamily: 'Campton',
            ),
          ),
        ],
      ),
    );
  }
}
