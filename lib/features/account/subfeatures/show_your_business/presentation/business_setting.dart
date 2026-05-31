import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/features/account/subfeatures/show_your_business/presentation/controllers/business_status_controller.dart';
import 'package:ojaewa/features/account/subfeatures/show_your_business/domain/business_status.dart';
import 'package:ojaewa/features/home/subfeatures/beauty/presentation/business_profile_beauty.dart';
import 'package:ojaewa/features/home/subfeatures/music/presentation/music_artist_profile.dart';

import '../../../../../app/router/app_router.dart';

class BusinessSettingsScreen extends ConsumerWidget {
  const BusinessSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppPageScaffold(
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),
          _buildTitleAndAddButton(context),
          const SizedBox(height: 16),
          _buildBusinessList(context, ref),
        ],
      ),
    );
  }

  /// Title and "Add New Business" action
  Widget _buildTitleAndAddButton(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          Text(
            "Your Business",
            style: TextStyle(
              fontSize: 33,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              // Add business should restart creation flow
              onTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.businessCategory),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: colors.accent.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Text(
                  "Add New Business",
                  style: TextStyle(
                    color: colors.onAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// List of business items
  Widget _buildBusinessList(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final businessesAsync = ref.watch(myBusinessStatusesProvider);

    return businessesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Text('Failed to load businesses: $e'),
      ),
      data: (businesses) {
        if (businesses.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Text('No business profiles yet.'),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: businesses.length,
          separatorBuilder: (_, separatorIndex) =>
              Divider(color: colors.border, height: 1),
          itemBuilder: (context, index) {
            final b = businesses[index];
            final status = b.storeStatus;

            Color chipBg;
            Color chipFg;
            String chipText;
            switch (status) {
              case 'approved':
                chipBg = const Color(0xFF2ECC71).withAlpha(25);
                chipFg = const Color(0xFF2ECC71);
                chipText = 'Approved';
                break;
              case 'pending':
                chipBg = const Color(0xFF111111).withAlpha(25);
                chipFg = const Color(0xFF111111);
                chipText = 'Pending';
                break;
              case 'deactivated':
                chipBg = const Color(0xFFE74C3C).withAlpha(25);
                chipFg = const Color(0xFFE74C3C);
                chipText = 'Deactivated';
                break;
              default:
                chipBg = colors.textTertiary.withAlpha(25);
                chipFg = colors.textTertiary;
                chipText = status.isEmpty ? 'Unknown' : status;
            }

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              onTap: () {
                // Navigate to category-specific detail screen
                _navigateToBusinessDetail(context, b);
              },
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      b.businessName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      chipText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: chipFg,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.more_horiz, color: colors.textPrimary),
                onPressed: () => _showBusinessActions(context, b),
              ),
            );
          },
        );
      },
    );
  }

  /// Navigate to the category-specific business detail screen
  void _navigateToBusinessDetail(
    BuildContext context,
    BusinessStatus business,
  ) {
    final category = business.category.toLowerCase();

    switch (category) {
      case 'music':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MusicArtistProfileScreen(businessId: business.id),
          ),
        );
        break;
      case 'school':
        // School detail screen - under development
        // Navigate to schools screen with businessId for now
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.schools, arguments: {'businessId': business.id});
        break;
      case 'art':
      case 'brand':
        // Art/Brand - sustainability screen for now (under development)
        Navigator.of(context).pushNamed(
          AppRoutes.sustainability,
          arguments: {'businessId': business.id},
        );
        break;
      default:
        // Fallback to beauty screen for any unhandled category
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                BusinessProfileBeautyScreen(businessId: business.id),
          ),
        );
        break;
    }
  }

  /// Action Sheet inferred from response2.json
  void _showBusinessActions(BuildContext context, BusinessStatus business) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colors = context.appColors;
        return Container(
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            border: Border(top: BorderSide(color: colors.border)),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pull handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: colors.borderStrong,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              _buildModalOption(
                label: "Edit Business Information",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed(
                    AppRoutes.editBusiness,
                    arguments: {'businessId': business.id},
                  );
                },
              ),
              Divider(color: colors.border),
              // TODO: Uncomment when subscription feature is active
              // _buildModalOption(
              //   label: "Manage Payment",
              //   onTap: () {
              //     Navigator.pop(context);
              //     Navigator.of(context).pushNamed(
              //       AppRoutes.managePayment,
              //       arguments: {'businessId': business.id},
              //     );
              //   },
              // ),
              // const Divider(color: Color(0xFFDEDEDE)),
              _buildModalOption(
                label: "Deactivate Shop",
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed(
                    AppRoutes.deactivateShop,
                    arguments: {'businessId': business.id},
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalOption({
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: isDestructive ? Colors.red : Colors.black,
        ),
      ),
      onTap: onTap,
    );
  }
}
