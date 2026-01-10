import 'package:flutter/material.dart';

import 'package:ojaewa/core/resources/app_assets.dart';

/// Decorative background watermark used in several screens.
///
/// This replaces placeholder decoration images.
class BackgroundLogoWatermark extends StatelessWidget {
  const BackgroundLogoWatermark({
    super.key,
    this.opacity = 0.03,
    this.width = 234,
    this.height = 347,
    this.right = -40,
    this.bottom = -40,
  });

  final double opacity;
  final double width;
  final double height;

  /// Positioned offsets.
  final double right;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: right,
      bottom: bottom,
      child: Opacity(
        opacity: opacity,
        child: SizedBox(
          width: width,
          height: height,
          child: Image.asset(
            AppImages.logoOutline,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
