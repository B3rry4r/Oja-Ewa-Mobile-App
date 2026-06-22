// account.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/core/constants/app_urls.dart';
import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/core/i18n/l10n_ext.dart';
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

    // Guest gating (mirrors WAWUBasket's ProfileScreen): a logged-out user
    // sees a clean "Sign in / Create account" prompt instead of a "?" avatar
    // and a menu full of rows that all require auth.
    if (!isLoggedIn) {
      return _buildGuestAccount(context);
    }

    return _buildSignedInAccount(context, ref, profile.value);
  }

  /// Clean logged-out state: no fake avatar, no "?", just a sign-in prompt.
  /// Structure mirrors WAWUBasket's `ProfileScreen._buildGuest`.
  Widget _buildGuestAccount(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            WBSpacing.screenPadding,
            80,
            WBSpacing.screenPadding,
            180,
          ),
          children: [
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: WBColors.bgSoft,
                  borderRadius: BorderRadius.circular(28),
                ),
                alignment: Alignment.center,
                child: const WBIcon(
                  WBIconName.user,
                  size: 36,
                  color: WBColors.fgHeader,
                ),
              ),
            ),
            const SizedBox(height: WBSpacing.lg),
            // TODO(i18n): key=accountGuestTitle / accountGuestBody
            Text(
              'Sign in to your account',
              textAlign: TextAlign.center,
              style: WBTypography.hero.copyWith(fontSize: 24),
            ),
            const SizedBox(height: WBSpacing.sm),
            Text(
              'Save your favorites, track orders, and manage your profile.',
              textAlign: TextAlign.center,
              style: WBTypography.body.copyWith(
                color: WBColors.fgSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: WBSpacing.xl),
            WBButton(
              label: l.authSignIn,
              size: WBButtonSize.lg,
              fullWidth: true,
              trailingIcon: WBIconName.arrowRight,
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.signIn),
            ),
            const SizedBox(height: WBSpacing.sm + 4),
            WBButton(
              label: l.authCreateAccount,
              size: WBButtonSize.lg,
              fullWidth: true,
              variant: WBButtonVariant.secondary,
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.createAccount),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignedInAccount(
    BuildContext context,
    WidgetRef ref,
    UserProfile? profile,
  ) {
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
          children: [
            _AccountHeader(profile: profile),
            const SizedBox(height: 24),
            for (final section in _sections(context, ref)) ...[
              AccountMenuSectionCard(section: section),
              const SizedBox(height: 12),
            ],
            _buildBadgeStatusCard(context, ref),
            const SizedBox(height: 12),
            if (_isTestUser(ref)) ...[
              _buildTestNotificationButton(context, ref),
              const SizedBox(height: 12),
            ],
            AccountMenuSectionCard(
              section: _destructiveSection(context, ref, true),
            ),
          ],
        ),
      ),
    );
  }

  List<AccountMenuSection> _sections(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final isSellerApproved = ref.watch(isSellerApprovedProvider);
    final hasApprovedBusiness = ref.watch(hasApprovedBusinessProvider);
    void go(String route) => Navigator.of(context).pushNamed(route);

    return [
      AccountMenuSection(
        title: l.accountSectionAccount,
        rows: [
          AccountMenuRow(
            icon: WBIconName.user,
            label: l.accountEditProfile,
            sub: l.accountEditProfileSub,
            onTap: () => go(AppRoutes.editProfile),
          ),
          AccountMenuRow(
            icon: WBIconName.basket,
            label: l.accountYourOrders,
            sub: l.accountYourOrdersSub,
            onTap: () => go(AppRoutes.orders),
          ),
          AccountMenuRow(
            icon: WBIconName.pin,
            label: l.accountAddresses,
            sub: l.accountAddressesSub,
            onTap: () => go(AppRoutes.addresses),
          ),
          AccountMenuRow(
            icon: WBIconName.bell,
            label: l.accountNotifications,
            sub: l.accountNotificationsSub,
            onTap: () => go(AppRoutes.notificationsSettings),
          ),
          AccountMenuRow(
            icon: WBIconName.lock,
            label: l.accountPassword,
            sub: l.accountPasswordSub,
            onTap: () => go(AppRoutes.changePassword),
          ),
          AccountMenuRow(
            icon: WBIconName.globe,
            label: l.languageTitle,
            sub: l.languageSubtitle,
            onTap: () => go(AppRoutes.language),
          ),
        ],
      ),
      AccountMenuSection(
        title: l.accountSectionBusiness,
        rows: [
          AccountMenuRow(
            icon: WBIconName.store,
            label: l.accountStartSelling,
            sub: l.accountStartSellingSub,
            onTap: () => go(
              isSellerApproved
                  ? AppRoutes.yourShopDashboard
                  : AppRoutes.sellerOnboarding,
            ),
          ),
          AccountMenuRow(
            icon: WBIconName.store,
            label: l.accountShowBusiness,
            sub: l.accountShowBusinessSub,
            onTap: () => go(
              hasApprovedBusiness
                  ? AppRoutes.businessSettings
                  : AppRoutes.businessOnboarding,
            ),
          ),
          AccountMenuRow(
            icon: WBIconName.shield,
            label: 'Verified Badges',
            sub: 'View and apply for seller verification badges',
            onTap: () => go(AppRoutes.badgeVerifications),
          ),
        ],
      ),
      AccountMenuSection(
        title: l.accountSectionSupport,
        rows: [
          AccountMenuRow(
            icon: WBIconName.message,
            label: l.accountEmailUs,
            onTap: () => _handleEmailUs(context, ref),
          ),
          AccountMenuRow(
            icon: WBIconName.shield,
            label: l.accountPrivacy,
            onTap: () => launchUrl(
              Uri.parse(AppUrls.privacyPolicyUrl),
              mode: LaunchMode.externalApplication,
            ),
          ),
          AccountMenuRow(
            icon: WBIconName.doc,
            label: l.accountTerms,
            onTap: () => go(AppRoutes.termsOfService),
          ),
          AccountMenuRow(
            icon: WBIconName.help,
            label: l.accountFaq,
            onTap: () => go(AppRoutes.faq),
          ),
          AccountMenuRow(
            icon: WBIconName.phone,
            label: l.accountConnect,
            onTap: () => go(AppRoutes.connectToUs),
          ),
        ],
      ),
    ];
  }

  // Only rendered for signed-in users (the guest state replaces the whole
  // screen with a sign-in prompt), so [isLoggedIn] is always true here. The
  // parameter is retained for call-site clarity.
  AccountMenuSection _destructiveSection(
    BuildContext context,
    WidgetRef ref,
    bool isLoggedIn,
  ) {
    final l = context.l10n;
    return AccountMenuSection(
      title: '',
      rows: [
        AccountMenuRow(
          icon: WBIconName.trash,
          label: l.accountDelete,
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
          icon: WBIconName.logout,
          label: l.authSignOut,
          danger: true,
          onTap: () => _handleAuthAction(context, ref),
        ),
      ],
    );
  }

  Future<void> _handleAuthAction(
    BuildContext context,
    WidgetRef ref,
  ) async {
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
    String email = 'beauty@wawuafrica.com';
    try {
      final connectInfo = await ref.read(connectInfoProvider.future);
      email = connectInfo.email.isNotEmpty
          ? connectInfo.email
          : 'beauty@wawuafrica.com';
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
                // Signed-in only (guests get the dedicated guest screen), so
                // fall back to a neutral label rather than "Guest" when a
                // signed-in profile has no name yet.
                name.isNotEmpty ? name : 'WAWUBeauty user',
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
