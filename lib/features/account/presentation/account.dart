// account.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/core/i18n/l10n_ext.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/core/theme/wb_theme_exports.dart';
import 'package:ojaewa/core/widgets/wb_widgets.dart';
import 'package:ojaewa/core/auth/auth_providers.dart';
import 'package:ojaewa/features/account/domain/user_profile.dart';
import 'package:ojaewa/features/account/presentation/controllers/profile_controller.dart';
import 'package:ojaewa/features/account/presentation/widgets/account_menu.dart';
import 'package:ojaewa/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ojaewa/features/account/subfeatures/start_selling/presentation/controllers/seller_status_controller.dart';
import 'package:ojaewa/features/account/subfeatures/show_your_business/presentation/controllers/business_status_controller.dart';
import 'package:ojaewa/features/account/subfeatures/connect/presentation/controllers/connect_controller.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/widgets/confirmation_modal.dart';
import 'package:ojaewa/core/widgets/seller_badge.dart';
import 'package:ojaewa/features/auth/data/auth_repository_impl.dart';
import 'package:ojaewa/features/notifications/data/notifications_repository_impl.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final token = ref.watch(accessTokenProvider);
    final isLoggedIn = token != null && token.isNotEmpty;

    ref.listen(authFlowControllerProvider, (prev, next) {
      if (prev?.isLoading == true && next.hasValue) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.onboarding, (r) => false);
      }
    });

    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
          children: [
            _AccountHeader(profile: profile.value),
            const SizedBox(height: 24),
            for (final section in _sections(context, ref)) ...[
              AccountMenuSectionCard(section: section),
              const SizedBox(height: 12),
            ],
            if (isLoggedIn) ...[
              _buildBadgeStatusCard(context, ref),
              const SizedBox(height: 12),
            ],
            if (_isTestUser(ref)) ...[
              _buildTestNotificationButton(context, ref),
              const SizedBox(height: 12),
            ],
            AccountMenuSectionCard(
              section: _destructiveSection(context, ref, isLoggedIn),
            ),
          ],
        ),
      ),
    );
  }

  List<AccountMenuSection> _sections(BuildContext context, WidgetRef ref) {
    final isSellerApproved = ref.watch(isSellerApprovedProvider);
    final hasApprovedBusiness = ref.watch(hasApprovedBusinessProvider);
    void go(String route) => Navigator.of(context).pushNamed(route);

    return [
      AccountMenuSection(
        title: 'Account',
        rows: [
          AccountMenuRow(
            iconAsset: AppIcons.editYourProfile,
            label: 'Edit your profile',
            sub: 'Name, photo and contact details',
            onTap: () => go(AppRoutes.editProfile),
          ),
          AccountMenuRow(
            iconAsset: AppIcons.yourOrders,
            label: 'Your orders',
            sub: 'Track and review past orders',
            onTap: () => go(AppRoutes.orders),
          ),
          AccountMenuRow(
            iconAsset: AppIcons.yourAddress,
            label: 'Your addresses',
            sub: 'Delivery locations',
            onTap: () => go(AppRoutes.addresses),
          ),
          AccountMenuRow(
            iconAsset: AppIcons.notification,
            label: 'Notifications',
            sub: 'Push and email preferences',
            onTap: () => go(AppRoutes.notificationsSettings),
          ),
          AccountMenuRow(
            iconAsset: AppIcons.password,
            label: 'Password',
            sub: 'Change your password',
            onTap: () => go(AppRoutes.changePassword),
          ),
          AccountMenuRow(
            iconAsset: AppIcons.connectToUs,
            label: context.l10n.languageTitle,
            sub: context.l10n.languageSubtitle,
            onTap: () => go(AppRoutes.language),
          ),
        ],
      ),
      AccountMenuSection(
        title: 'WAWUBeauty Business',
        rows: [
          AccountMenuRow(
            iconAsset: AppIcons.startSelling,
            label: 'Start selling',
            sub: 'List your products and reach buyers',
            onTap: () => go(
              isSellerApproved
                  ? AppRoutes.yourShopDashboard
                  : AppRoutes.sellerOnboarding,
            ),
          ),
          AccountMenuRow(
            iconAsset: AppIcons.showYourBusiness,
            label: 'Show your business',
            sub: 'Your heritage and brand story',
            onTap: () => go(
              hasApprovedBusiness
                  ? AppRoutes.businessSettings
                  : AppRoutes.businessOnboarding,
            ),
          ),
        ],
      ),
      AccountMenuSection(
        title: 'Support',
        rows: [
          AccountMenuRow(
            iconAsset: AppIcons.emailUs,
            label: 'Email us',
            onTap: () => _handleEmailUs(context, ref),
          ),
          AccountMenuRow(
            iconAsset: AppIcons.privacyPolicy,
            label: 'Privacy Policy',
            onTap: () => go(AppRoutes.privacyPolicy),
          ),
          AccountMenuRow(
            iconAsset: AppIcons.termsOfService,
            label: 'Terms of Service',
            onTap: () => go(AppRoutes.termsOfService),
          ),
          AccountMenuRow(
            iconAsset: AppIcons.faq,
            label: 'FAQ',
            onTap: () => go(AppRoutes.faq),
          ),
          AccountMenuRow(
            iconAsset: AppIcons.connectToUs,
            label: 'Connect to us',
            onTap: () => go(AppRoutes.connectToUs),
          ),
        ],
      ),
    ];
  }

  AccountMenuSection _destructiveSection(
    BuildContext context,
    WidgetRef ref,
    bool isLoggedIn,
  ) {
    return AccountMenuSection(
      title: '',
      rows: [
        if (isLoggedIn)
          AccountMenuRow(
            iconAsset: AppIcons.signOut,
            label: 'Delete Account',
            danger: true,
            onTap: () {
              ConfirmationModal.show(
                context,
                title: 'Delete Account',
                message:
                    'Are you sure you want to permanently delete your account? '
                    'This action cannot be undone. All your data, orders, and '
                    'profile information will be permanently removed.',
                confirmLabel: 'Delete Account',
                cancelLabel: 'Cancel',
                onConfirm: () => _handleDeleteAccount(context, ref),
              );
            },
          ),
        AccountMenuRow(
          iconAsset: AppIcons.signOut,
          label: isLoggedIn ? 'Sign Out' : 'Sign In',
          danger: isLoggedIn,
          onTap: () => _handleAuthAction(context, ref, isLoggedIn),
        ),
      ],
    );
  }

  Future<void> _handleAuthAction(
    BuildContext context,
    WidgetRef ref,
    bool isLoggedIn,
  ) async {
    if (!isLoggedIn) {
      Navigator.of(context).pushNamed(AppRoutes.signIn);
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await ref.read(authFlowControllerProvider.notifier).logout();
      if (!context.mounted) return;
      Navigator.of(context).pop(); // close loader
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.onboarding, (r) => false);
    } catch (_) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
    }
  }

  Widget _buildBadgeStatusCard(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final sellerStatus = ref.watch(sellerStatusProvider);
    final badge = (sellerStatus?.badge ?? '').trim();
    final hasBadge = badge.isNotEmpty;
    final hasSellerProfile = sellerStatus != null;
    final uploadLimit = sellerStatus?.productUploadLimit;
    final canUploadMoreProducts = sellerStatus?.canUploadMoreProducts;
    final badgeColor = _badgeColor(badge, colors);
    final badgeIconColor = _badgeIconColor(badge);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WBColors.surfaceCard,
        borderRadius: BorderRadius.circular(WBRadius.card),
        boxShadow: WBShadows.card,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: hasBadge ? badgeColor : WBColors.bgSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              hasBadge ? Icons.verified : Icons.workspace_premium_outlined,
              color: hasBadge ? badgeIconColor : WBColors.fgHeader,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasBadge ? _badgeLabel(badge) : 'No verification badge yet',
                  style: WBTypography.body.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasSellerProfile
                      ? 'Badges strengthen trust on your seller profile and unlock stronger selling privileges.'
                      : 'Create your seller profile first, then apply for a badge.',
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgSecondary,
                  ),
                ),
                if (hasSellerProfile && uploadLimit != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    canUploadMoreProducts == false
                        ? 'Product upload limit: $uploadLimit reached'
                        : 'Product upload limit: $uploadLimit',
                    style: WBTypography.caption.copyWith(
                      fontWeight: FontWeight.w500,
                      color: WBColors.fgPlaceholder,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!hasBadge)
            WBButton(
              label: 'View',
              size: WBButtonSize.sm,
              variant: WBButtonVariant.secondary,
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.badgeVerifications),
            ),
        ],
      ),
    );
  }

  String _badgeLabel(String badge) =>
      SellerBadge.labelFor(badge) ?? 'Badge Active';

  Color _badgeColor(String badge, AppThemeColors colors) =>
      SellerBadge.backgroundFor(badge) ?? colors.accent;

  Color _badgeIconColor(String badge) => SellerBadge.foregroundFor(badge);

  Future<void> _handleEmailUs(BuildContext context, WidgetRef ref) async {
    String email = 'support@ojaewa.com';
    try {
      final connectInfo = await ref.read(connectInfoProvider.future);
      email = connectInfo.email.isNotEmpty
          ? connectInfo.email
          : 'support@ojaewa.com';
    } catch (_) {
      // Use fallback email if API fails
    }

    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        AppSnackbars.showError(context, 'Could not open email app');
      }
    }
  }

  Future<void> _handleDeleteAccount(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await ref.read(authRepositoryProvider).deleteAccount();
      if (!context.mounted) return;
      Navigator.of(context).pop(); // close loader
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.onboarding, (r) => false);
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // close loader
      AppSnackbars.showError(
        context,
        'Failed to delete account. Please try again.',
      );
    }
  }

  /// Check if current user is a test user
  bool _isTestUser(WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).value;
    final email = profile?.email ?? '';
    return email == 'test@user.com' ||
        email == 'test@ojaewa.com' ||
        email.startsWith('test+');
  }

  Widget _buildTestNotificationButton(BuildContext context, WidgetRef ref) {
    return WBButton(
      label: 'Send Test Notification',
      fullWidth: true,
      variant: WBButtonVariant.secondary,
      onPressed: () => _sendTestNotification(context, ref),
    );
  }

  Future<void> _sendTestNotification(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      final notificationsApi = ref.read(notificationsRepositoryProvider);
      await notificationsApi.sendTestNotification();
      if (!context.mounted) return;
      Navigator.of(context).pop();
      AppSnackbars.showSuccess(
        context,
        'Test notification sent! Check your device.',
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      AppSnackbars.showError(context, 'Failed to send test notification: $e');
    }
  }
}

/// WAWUBasket-style account header: avatar + name + email + edit button.
class _AccountHeader extends StatelessWidget {
  const _AccountHeader({required this.profile});
  final UserProfile? profile;

  String get _initials {
    final name = (profile?.fullName ?? '').trim();
    if (name.isEmpty) return '?';
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final name = (profile?.fullName ?? '').trim();
    final email = (profile?.email ?? '').trim();
    final avatarUrl = profile?.avatarUrl;

    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: WBColors.bgDivider, width: 1.5),
          ),
          child: ClipOval(
            child: avatarUrl != null && avatarUrl.isNotEmpty
                ? WBNetworkImage(url: avatarUrl)
                : Container(
                    color: WBColors.surfaceDark,
                    alignment: Alignment.center,
                    child: Text(
                      _initials,
                      style: WBTypography.hero.copyWith(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isNotEmpty ? name : 'Guest',
                style: WBTypography.cardTitle.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (email.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  email,
                  style: WBTypography.caption.copyWith(
                    color: WBColors.fgSecondary,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.editProfile),
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: WBColors.bgSoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const WBIcon(WBIconName.more, size: 16, color: WBColors.fgHeader),
          ),
        ),
      ],
    );
  }
}
