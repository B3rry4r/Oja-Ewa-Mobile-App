import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/theme/wb_theme_exports.dart';
import 'package:ojaewa/core/ui/price_formatter.dart';
import 'package:ojaewa/core/widgets/wb_widgets.dart';

import '../../domain/beauty_kit.dart';
import '../controllers/beauty_kits_controller.dart';

/// Browse curated Beauty Kits ("buy all in one" bundles). Mirrors WAWUBasket's
/// recipes list screen. Guest-accessible — no auth required to browse.
class BeautyKitsScreen extends ConsumerWidget {
  const BeautyKitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kitsAsync = ref.watch(beautyKitsListProvider);

    return AppPageScaffold(
      // Body is a ListView/GridView: it needs a bounded height and scrolls itself.
      scrollable: false,
      title: 'Beauty Kits',
      child: kitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(beautyKitsListProvider),
          child: ListView(
            children: const [
              SizedBox(height: 160),
              Center(child: Text('Failed to load beauty kits')),
            ],
          ),
        ),
        data: (kits) {
          if (kits.isEmpty) {
            return const WBEmptyState(
              illustration: WBEmptyIllustration.noProducts,
              label: 'No beauty kits yet',
              sub: 'Curated bundles will show up here soon.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(beautyKitsListProvider),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: kits.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) =>
                  _BeautyKitCard(kit: kits[index]),
            ),
          );
        },
      ),
    );
  }
}

class _BeautyKitCard extends StatelessWidget {
  const _BeautyKitCard({required this.kit});

  final BeautyKit kit;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final sellerCount = kit.sellerCount;

    return InkWell(
      borderRadius: BorderRadius.circular(WBRadius.card),
      onTap: () => Navigator.of(context).pushNamed(
        AppRoutes.beautyKitDetail,
        // Prefer slug; fall back to id when slug is missing.
        arguments: {'idOrSlug': kit.slug.isNotEmpty ? kit.slug : '${kit.id}'},
      ),
      child: Container(
        decoration: BoxDecoration(
          color: WBColors.surfaceCard,
          borderRadius: BorderRadius.circular(WBRadius.card),
          boxShadow: WBShadows.card,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: WBNetworkImage(url: kit.image ?? ''),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kit.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: WBTypography.cardTitle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  if ((kit.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      kit.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: WBTypography.body.copyWith(
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        formatPrice(kit.effectiveTotalPrice),
                        style: WBTypography.cardTitle.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${kit.effectiveItemsCount} item'
                        '${kit.effectiveItemsCount == 1 ? '' : 's'}'
                        '${sellerCount > 1 ? ' • $sellerCount sellers' : ''}',
                        style: WBTypography.caption.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
