import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/wb_theme_exports.dart';

/// Network image with a calm placeholder + error fallback that respects the
/// monochrome aesthetic. Keeps the surface readable while images load instead
/// of flashing black.
///
/// Uses [CachedNetworkImage] for automatic disk-persistent caching via the
/// [DefaultCacheManager] (7-day TTL). Images are served from disk on subsequent
/// navigations, eliminating re-download flicker across route push/pop.
class WBNetworkImage extends StatelessWidget {
  const WBNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  final String url;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return Container(color: WBColors.bgSoft);
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      alignment: alignment,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      placeholder: (_, _) => Container(color: WBColors.bgSoft),
      errorWidget: (_, _, _) => Container(color: WBColors.bgSoft),
    );
  }
}
