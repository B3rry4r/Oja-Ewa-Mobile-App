import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/auth/auth_providers.dart';
import 'package:ojaewa/core/theme/wb_theme_exports.dart';
import 'package:ojaewa/core/ui/price_formatter.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/widgets/wb_widgets.dart';

import '../../domain/beauty_kit.dart';
import '../controllers/beauty_kits_controller.dart';

/// Beauty Kit detail: the bundled products (with their sellers) plus a
/// "Buy all" button that POSTs to /beauty-kits/{id}/add-to-cart and routes to
/// the cart. Browsing is guest-accessible; buying prompts login.
class BeautyKitDetailScreen extends ConsumerWidget {
  const BeautyKitDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final idOrSlug = (args is Map && args['idOrSlug'] is String)
        ? args['idOrSlug'] as String
        : null;

    if (idOrSlug == null) {
      return AppPageScaffold(
        title: 'Beauty Kit',
        child: const Center(child: Text('Missing kit reference')),
      );
    }

    final kitAsync = ref.watch(beautyKitDetailProvider(idOrSlug));

    return AppPageScaffold(
      title: 'Beauty Kit',
      child: kitAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load kit: $e')),
        data: (kit) => _BeautyKitDetailBody(kit: kit),
      ),
    );
  }
}

class _BeautyKitDetailBody extends ConsumerWidget {
  const _BeautyKitDetailBody({required this.kit});

  final BeautyKit kit;

  Future<void> _buyAll(BuildContext context, WidgetRef ref) async {
    // Gate on auth like the rest of the app's purchase flows.
    final token = ref.read(accessTokenProvider);
    if (token == null || token.isEmpty) {
      AppSnackbars.showError(context, 'Please sign in to add this kit to cart');
      Navigator.of(context).pushNamed(AppRoutes.signIn);
      return;
    }

    try {
      final result = await ref
          .read(beautyKitCartControllerProvider.notifier)
          .addKitToCart(kit.id);
      if (!context.mounted) return;
      final msg = result.skippedCount > 0
          ? 'Added ${result.addedCount} item${result.addedCount == 1 ? '' : 's'} '
              '(${result.skippedCount} unavailable)'
          : 'Added ${result.addedCount} item${result.addedCount == 1 ? '' : 's'} to cart';
      AppSnackbars.showSuccess(context, msg);
      Navigator.of(context).pushNamed(AppRoutes.cart);
    } catch (e) {
      if (context.mounted) {
        AppSnackbars.showError(context, 'Failed to add kit: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final addState = ref.watch(beautyKitCartControllerProvider);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 12, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(WBRadius.card),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: WBNetworkImage(url: kit.image ?? ''),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  kit.name,
                  style: WBTypography.section.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${kit.effectiveItemsCount} item'
                  '${kit.effectiveItemsCount == 1 ? '' : 's'}'
                  '${kit.sellerCount > 1 ? ' from ${kit.sellerCount} sellers' : ''}',
                  style: WBTypography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                if ((kit.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    kit.description!,
                    style: WBTypography.body.copyWith(
                      fontSize: 14,
                      color: colors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  'In this kit',
                  style: WBTypography.cardTitle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                for (int i = 0; i < kit.items.length; i++) ...[
                  _KitItemRow(item: kit.items[i]),
                  if (i < kit.items.length - 1) const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: WBButton(
              label: 'Buy all • ${formatPrice(kit.effectiveTotalPrice)}',
              fullWidth: true,
              size: WBButtonSize.lg,
              loading: addState.isLoading,
              onPressed: () => _buyAll(context, ref),
            ),
          ),
        ),
      ],
    );
  }
}

class _KitItemRow extends StatelessWidget {
  const _KitItemRow({required this.item});

  final BeautyKitItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 64,
            height: 64,
            child: WBNetworkImage(url: item.productImage ?? ''),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: WBTypography.body.copyWith(
                  fontSize: 14,
                  color: colors.textPrimary,
                ),
              ),
              if ((item.sellerName ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'by ${item.sellerName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: WBTypography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                formatPrice(item.productPrice),
                style: WBTypography.body.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (item.quantity > 1)
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 2),
            child: Text(
              'x${item.quantity}',
              style: WBTypography.caption.copyWith(color: colors.textSecondary),
            ),
          ),
      ],
    );
  }
}
