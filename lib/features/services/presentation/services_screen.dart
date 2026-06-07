import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_bottom_nav_bar.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/constants/app_urls.dart';
import 'package:ojaewa/core/i18n/l10n_ext.dart';
import 'package:ojaewa/core/theme/wb_theme_exports.dart';

import '../data/wawu_services.dart';

/// WAWUAfrica services tab. Surfaces every WAWUAfrica service (EasyBuy,
/// Health Insurance, Pension, …) in the app's standard grid layout, each cell
/// deep-linking into the WAWUAfrica hub.
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  Future<void> _openHub(BuildContext context, String path) async {
    final uri = Uri.parse('$wawuAfricaHubUrl$path');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WAWUAfrica')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AppPageScaffold(
      title: context.l10n.navServices,
      showBack: false,
      includeBottomNavSpacing: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppBottomNavBar.height),
        child: GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 120,
          ),
          itemCount: wawuServices.length,
          itemBuilder: (context, index) {
            final service = wawuServices[index];
            return _ServiceItem(
              service: service,
              colors: colors,
              onTap: () => _openHub(context, service.path),
            );
          },
        ),
      ),
    );
  }
}

class _ServiceItem extends StatelessWidget {
  const _ServiceItem({
    required this.service,
    required this.colors,
    required this.onTap,
  });

  final WawuService service;
  final AppThemeColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(WBRadius.card),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(service.icon, size: 26, color: colors.textPrimary),
            const SizedBox(height: 8),
            Text(
              service.label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: WBTypography.body.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 11.5,
                height: 1.15,
              ),
            ),
            if (service.soon) ...[
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(WBRadius.pill),
                ),
                child: const Text(
                  'Soon',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
