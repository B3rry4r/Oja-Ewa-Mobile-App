import 'package:flutter/material.dart';

import 'package:ojaewa/core/resources/app_assets.dart';

/// Consistent placeholder for image slots until real images are wired.
///
/// Uses the existing `logo_outline.png` asset so the UI looks intentional.
class AppImagePlaceholder extends StatelessWidget {
  const AppImagePlaceholder({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.backgroundColor = const Color(0xFFD9D9D9),
    this.padding = const EdgeInsets.all(12),
  });

  final double width;
  final double height;
  final double borderRadius;
  final Color backgroundColor;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Image.asset(
        AppImages.logoOutline,
        fit: BoxFit.contain,
      ),
    );
  }
}
