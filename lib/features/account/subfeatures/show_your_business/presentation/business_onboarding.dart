import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/features/account/subfeatures/show_your_business/presentation/controllers/business_status_controller.dart';
import 'package:ojaewa/core/subscriptions/subscription_constants.dart';
import 'package:ojaewa/core/subscriptions/subscription_controller.dart';
import 'package:ojaewa/core/subscriptions/iap_service.dart';

import '../../../../../app/router/app_router.dart';

class BusinessOnboardingScreen extends ConsumerWidget {
  const BusinessOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final businessesAsync = ref.watch(myBusinessStatusesProvider);
    final subscriptionAsync = ref.watch(subscriptionControllerProvider);
    final subscription = subscriptionAsync.value?.subscription;
    final hasPro = subscription != null && subscription.status.isActive;

    businessesAsync.whenOrNull(
      data: (items) {
        if (items.isEmpty) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          final hasApproved = items.any((b) => b.storeStatus == 'approved');
          if (hasApproved) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(AppRoutes.businessSettings, (r) => false);
          } else {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.businessApprovalStatus,
              (r) => false,
            );
          }
        });
      },
    );

    return AppPageScaffold(
      title: 'Show',
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          Text(
            "Share your Business Heritage on Ojá-Ẹwà",
            style: TextStyle(
              fontSize: 33,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
              fontFamily: 'Campton',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Craftsmanship, agency, and the tangible connection between cultural identity and creative expression.",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: colors.textSecondary,
              fontFamily: 'Campton',
            ),
          ),

          const SizedBox(height: 48),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: colors.surfaceSecondary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "How it works",
                  style: TextStyle(
                    fontSize: 33,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                    fontFamily: 'Campton',
                  ),
                ),
                const SizedBox(height: 24),
                _buildStepRow(
                  context,
                  "1",
                  "Provide your business information",
                ),
                _buildStepRow(
                  context,
                  "2",
                  "Wait for Ojá-Ẹwà to approve your details",
                ),
                _buildStepRow(
                  context,
                  "3",
                  "Wait and let people looking for your products or services find you",
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          hasPro
              ? _buildPrimaryButton(context, "Get Started")
              : _buildSubscriptionGate(context, ref),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSubscriptionGate(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final subscriptionState = ref.watch(subscriptionControllerProvider);
    final isLoading = subscriptionState.value?.isLoading ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ojaewa Pro Required',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Campton',
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Subscribe to Ojaewa Pro to publish your business profile and sell on the platform. AI tools are included.',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Campton',
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.termsOfService),
                  child: Text(
                    'View Terms of Service',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w600,
                      color: colors.accent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        await ref
                            .read(iapServiceProvider)
                            .purchaseSubscription(
                              SubscriptionProducts.ojaewaProYearly,
                            );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accent,
                  foregroundColor: colors.onAccent,
                  disabledBackgroundColor: colors.borderStrong,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('Subscribe'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context, String text) {
    final colors = context.appColors;
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.businessCategory),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        height: 57,
        decoration: BoxDecoration(
          color: colors.accent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: colors.onAccent,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Campton',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow(
    BuildContext context,
    String number,
    String description,
  ) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.textPrimary,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: TextStyle(
                color: colors.background,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: colors.textPrimary,
                fontFamily: 'Campton',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
