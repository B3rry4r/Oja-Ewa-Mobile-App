import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/wb_theme_exports.dart';

/// Two-part hero tagline that randomises on every screen open. The first
/// half ([accent]) is rendered in the strong header colour; the trailing
/// half ([muted]) reads in placeholder grey so the eye lands on the
/// accent. Used on the customer / vendor / trader home heros.
class WBRandomTagline extends StatefulWidget {
  const WBRandomTagline({
    super.key,
    required this.pairs,
    this.fontSize = 32,
  });

  /// Candidate pairs to randomise from. Order is preserved in render
  /// (accent first, muted after a single space).
  final List<({String accent, String muted})> pairs;
  final double fontSize;

  @override
  State<WBRandomTagline> createState() => _WBRandomTaglineState();
}

class _WBRandomTaglineState extends State<WBRandomTagline> {
  late final ({String accent, String muted}) _pick =
      widget.pairs[Random().nextInt(widget.pairs.length)];

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: WBTypography.hero.copyWith(
          fontSize: widget.fontSize,
          height: 1.1,
          letterSpacing: -0.8,
        ),
        children: [
          TextSpan(
            text: '${_pick.accent} ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: _pick.muted,
            style: const TextStyle(
              color: WBColors.fgPlaceholder,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

/// Canonical tagline sets for each surface. Edit here and every screen
/// using [WBRandomTagline] picks up the new options.
abstract final class WBTaglines {
  /// Customer home, where the user starts the meal.
  static const customer = <({String accent, String muted})>[
    (accent: 'Hungry?', muted: 'Order & Eat'),
    (accent: 'Craving?', muted: 'Pick your basket'),
    (accent: 'Yum o\'clock?', muted: 'Fill your basket'),
    (accent: 'Dinner soon?', muted: 'Get the goods'),
    (accent: 'Lunch break?', muted: 'Tap, pay, eat'),
  ];

  /// Vendor dashboard, framing the day's work.
  static const vendor = <({String accent, String muted})>[
    (accent: "Today's haul.", muted: 'Cook, plate, ship'),
    (accent: 'Open kitchen.', muted: 'Orders are coming'),
    (accent: 'Fresh orders.', muted: 'Time to shine'),
    (accent: 'Steady hands.', muted: 'Big tips ahead'),
    (accent: 'Service on.', muted: 'Customers are watching'),
  ];

  /// Trader dashboard, framing the bulk-trade desk.
  static const trader = <({String accent, String muted})>[
    (accent: 'Bulk moves.', muted: 'Lots out, value in'),
    (accent: 'Corridor live.', muted: 'Buyers waiting'),
    (accent: 'Lots ready?', muted: "Let's get them sold"),
    (accent: 'Quote, ship, settle.', muted: 'Repeat tomorrow'),
    (accent: 'Borders open.', muted: 'Trade lanes are hot'),
  ];
}
