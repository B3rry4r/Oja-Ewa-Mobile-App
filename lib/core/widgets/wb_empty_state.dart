import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/wb_theme_exports.dart';

/// Full-area empty state with a centred illustration, bold label, and
/// optional sub-text. Use [WBEmptyIllustration] constants for the asset path.
class WBEmptyState extends StatelessWidget {
  const WBEmptyState({
    super.key,
    required this.illustration,
    required this.label,
    this.sub,
  });

  final String illustration;
  final String label;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              illustration,
              width: 220,
              height: 220,
              fit: BoxFit.contain,
              placeholderBuilder: (_) => const SizedBox(width: 220, height: 220),
            ),
            const SizedBox(height: 24),
            Text(
              label,
              style: WBTypography.body.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            if (sub != null) ...[
              const SizedBox(height: 8),
              Text(
                sub!,
                style: WBTypography.caption.copyWith(
                  color: WBColors.fgSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

abstract final class WBEmptyIllustration {
  static const noOrders         = 'assets/empty_states/No Order Right now.svg';
  static const noOrderInTrack   = 'assets/empty_states/No Order in track.svg';
  static const noNewOrder       = 'assets/empty_states/No new order.svg';
  static const noMealInKitchen  = 'assets/empty_states/No meal in kitchen.svg';
  static const noProducts       = 'assets/empty_states/No Product available.svg';
  static const noProducts2      = 'assets/empty_states/No product available 2.svg';
  static const noDish           = 'assets/empty_states/No Dish available.svg';
  static const noTrips          = 'assets/empty_states/No Trips.svg';
  static const noActiveLoads    = 'assets/empty_states/No Active Loads.svg';
  static const noOpenLoads      = 'assets/empty_states/No Open Loads.svg';
  static const noActiveListing  = 'assets/empty_states/No Active Listing.svg';
  static const noDraftListing   = 'assets/empty_states/No Draft Listing.svg';
  static const noSoldListing    = 'assets/empty_states/No Sold Listing.svg';
  static const noExpiredListing = 'assets/empty_states/No expired listing.svg';
  static const noTransaction    = 'assets/empty_states/No Recent Transaction.svg';
  static const noActiveDelivery = 'assets/empty_states/No Active Delivery.svg';
  static const noOffers         = 'assets/empty_states/No Offer Available.svg';
}
