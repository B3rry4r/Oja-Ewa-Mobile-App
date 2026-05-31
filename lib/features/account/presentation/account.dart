// profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/resources/app_assets.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/core/auth/auth_providers.dart';
import 'package:ojaewa/features/account/presentation/controllers/profile_controller.dart';
import 'package:ojaewa/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ojaewa/features/account/subfeatures/start_selling/presentation/controllers/seller_status_controller.dart';
import 'package:ojaewa/features/account/subfeatures/show_your_business/presentation/controllers/business_status_controller.dart';
import 'package:ojaewa/features/account/subfeatures/connect/presentation/controllers/connect_controller.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/widgets/confirmation_modal.dart';
import 'package:ojaewa/core/widgets/seller_badge.dart';
import 'package:ojaewa/features/auth/data/auth_repository_impl.dart';
import 'package:ojaewa/features/notifications/data/notifications_repository_impl.dart';

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
    return AppPageScaffold(
      showBack: false,
      includeBottomNavSpacing: true,
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          profile.when(
            loading: () => const Text(
              'Hello',
              style: TextStyle(
                fontSize: 33,
                fontWeight: FontWeight.w600,
              ),
            ),
            error: (e, st) => const Text(
              'Hello',
              style: TextStyle(
                fontSize: 33,
                fontWeight: FontWeight.w600,
              ),
            ),
            data: (u) => Text(
              'Hello ${u?.fullName ?? 'Guest'}',
              style: const TextStyle(
                fontSize: 33,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Profile'),
          _buildMenuItem(
            context: context,
            iconAsset: AppIcons.editYourProfile,
            label: 'Edit your profile',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.editProfile),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Orders'),
          _buildMenuItem(
            context: context,
            iconAsset: AppIcons.yourOrders,
            label: 'Your orders',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.orders),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Settings'),
          _buildSettingsList(context, ref),

          if (isLoggedIn) ...[
            const SizedBox(height: 16),
            _buildBadgeStatusCard(context, ref),
          ],

          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Ojá-Ẹwà Business'),
          _buildBusinessList(context, ref),

          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Support'),
          _buildSupportList(context, ref, isLoggedIn: isLoggedIn),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String text) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: colors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String iconAsset,
    required String label,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;
    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: colors.accentSoft,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      iconAsset,
                      width: 16,
                      height: 16,
                      colorFilter: ColorFilter.mode(
                        colors.textPrimary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              Icon(Icons.chevron_right, size: 20, color: colors.textPrimary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildMenuItem(
          context: context,
          iconAsset: AppIcons.yourAddress,
          label: 'Your Addresses',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.addresses),
        ),
        _buildMenuItem(
          context: context,
          iconAsset: AppIcons.notification,
          label: 'Notifications',
          onTap: () =>
              Navigator.of(context).pushNamed(AppRoutes.notificationsSettings),
        ),
        _buildMenuItem(
          context: context,
          iconAsset: AppIcons.password,
          label: 'Password',
          onTap: () =>
              Navigator.of(context).pushNamed(AppRoutes.changePassword),
        ),
      ],
    );
  }

  Widget _buildBadgeStatusCard(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final sellerStatus = ref.watch(sellerStatusProvider);
    final badge = (sellerStatus?.badge ?? '').trim();
    final hasBadge = badge.isNotEmpty;
    final hasSellerProfile = sellerStatus?.id != null;
    final uploadLimit = sellerStatus?.productUploadLimit;
    final canUploadMoreProducts = sellerStatus?.canUploadMoreProducts;
    final badgeColor = _badgeColor(badge, colors);
    final badgeIconColor = _badgeIconColor(badge);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: hasBadge ? badgeColor : colors.borderStrong,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              hasBadge ? Icons.verified : Icons.workspace_premium_outlined,
              color: hasBadge ? badgeIconColor : Colors.white,
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
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasSellerProfile
                      ? 'Badges strengthen trust on your seller profile and unlock stronger selling privileges.'
                      : 'Create your seller profile first, then apply for a badge.',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                ),
                if (hasSellerProfile && uploadLimit != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    canUploadMoreProducts == false
                        ? 'Product upload limit: $uploadLimit reached'
                        : 'Product upload limit: $uploadLimit',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!hasBadge)
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.badgeVerifications),
              child: const Text(
                'View badges',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFDAF40),
                ),
              ),
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

  Widget _buildBusinessList(BuildContext context, WidgetRef ref) {
    final isSellerApproved = ref.watch(isSellerApprovedProvider);
    final hasApprovedBusiness = ref.watch(hasApprovedBusinessProvider);

    return Column(
      children: [
        _buildMenuItem(
          context: context,
          iconAsset: AppIcons.startSelling,
          label: 'Start selling',
          onTap: () => Navigator.of(context).pushNamed(
            isSellerApproved
                ? AppRoutes.yourShopDashboard
                : AppRoutes.sellerOnboarding,
          ),
        ),
        _buildMenuItem(
          context: context,
          iconAsset: AppIcons.showYourBusiness,
          label: 'Show your business',
          onTap: () => Navigator.of(context).pushNamed(
            hasApprovedBusiness
                ? AppRoutes.businessSettings
                : AppRoutes.businessOnboarding,
          ),
        ),
      ],
    );
  }

  Widget _buildSupportList(
    BuildContext context,
    WidgetRef ref, {
    required bool isLoggedIn,
  }) {
    final colors = context.appColors;
    return Column(
      children: [
        _buildMenuItem(
          context: context,
          iconAsset: AppIcons.emailUs,
          label: 'Email Us',
          onTap: () => _handleEmailUs(context, ref),
        ),
        _buildMenuItem(
          context: context,
          iconAsset: AppIcons.privacyPolicy,
          label: 'Privacy Policy',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.privacyPolicy),
        ),
        _buildMenuItem(
          context: context,
          iconAsset: AppIcons.termsOfService,
          label: 'Terms of Service',
          onTap: () =>
              Navigator.of(context).pushNamed(AppRoutes.termsOfService),
        ),
        _buildMenuItem(
          context: context,
          iconAsset: AppIcons.faq,
          label: 'FAQ',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.faq),
        ),
        _buildMenuItem(
          context: context,
          iconAsset: AppIcons.connectToUs,
          label: 'Connect to us',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.connectToUs),
        ),

        // Test notification button (only for test users)
        if (_isTestUser(ref)) _buildTestNotificationButton(context, ref),

        // Delete Account — only shown when logged in
        if (isLoggedIn) _buildDeleteAccountButton(context, ref),

        // Sign Out or Sign In based on auth state
        Container(
          height: 48,
          margin: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                if (isLoggedIn) {
                  // Logout flow
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                  );
                  try {
                    await ref
                        .read(authFlowControllerProvider.notifier)
                        .logout();
                    if (!context.mounted) return;
                    Navigator.of(context).pop(); // close loader
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.onboarding,
                      (r) => false,
                    );
                  } catch (_) {
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  }
                } else {
                  // Navigate to sign in
                  Navigator.of(context).pushNamed(AppRoutes.signIn);
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isLoggedIn
                              ? const Color(0xFF8B1E1E).withValues(alpha: 0.18)
                              : colors.accentSoft,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          AppIcons.signOut,
                          width: 16,
                          height: 16,
                          colorFilter: ColorFilter.mode(
                            isLoggedIn
                                ? const Color(0xFFFF8A80)
                                : colors.textPrimary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isLoggedIn ? 'Sign Out' : 'Sign In',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: isLoggedIn
                              ? const Color(0xFFFF8A80)
                              : colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: isLoggedIn
                        ? const Color(0xFFFF8A80)
                        : colors.textPrimary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleEmailUs(BuildContext context, WidgetRef ref) async {
    // Try to get email from connect info, fallback to default
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

  Widget _buildDeleteAccountButton(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
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
          borderRadius: BorderRadius.circular(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF8B1E1E).withValues(alpha: 0.18)
                          : const Color(0xFFF7E5E5),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.delete_forever_outlined,
                      size: 16,
                      color: isDarkMode
                          ? const Color(0xFFFF8A80)
                          : const Color(0xFFD32F2F),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Delete Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: isDarkMode
                          ? const Color(0xFFFF8A80)
                          : const Color(0xFFD32F2F),
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: isDarkMode
                    ? const Color(0xFFFF8A80)
                    : const Color(0xFFD32F2F),
              ),
            ],
          ),
        ),
      ),
    );
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
    // Show test button for these test emails
    return email == 'test@user.com' ||
        email == 'test@ojaewa.com' ||
        email.startsWith('test+');
  }

  /// Build test notification button (only visible for test users)
  Widget _buildTestNotificationButton(BuildContext context, WidgetRef ref) {
    return Container(
      height: 56,
      margin: const EdgeInsets.only(bottom: 8, top: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFDAF40).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFDAF40), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _sendTestNotification(context, ref),
          borderRadius: BorderRadius.circular(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.notifications_active,
                color: Color(0xFFFDAF40),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Send Test Notification',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFDAF40),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Send test notification via backend
  Future<void> _sendTestNotification(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // Call backend to send test notification
      final notificationsApi = ref.read(notificationsRepositoryProvider);
      await notificationsApi.sendTestNotification();

      // Hide loading
      if (!context.mounted) return;
      Navigator.of(context).pop();

      // Show success message
      AppSnackbars.showSuccess(
        context,
        'Test notification sent! Check your device.',
      );
    } catch (e) {
      // Hide loading
      if (!context.mounted) return;
      Navigator.of(context).pop();

      // Show error
      AppSnackbars.showError(context, 'Failed to send test notification: $e');
    }
  }
}
