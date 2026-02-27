// profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/app/widgets/app_bottom_nav_bar.dart';
import 'package:ojaewa/core/resources/app_assets.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/core/auth/auth_providers.dart';
import 'package:ojaewa/features/account/presentation/controllers/profile_controller.dart';
import 'package:ojaewa/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ojaewa/features/account/subfeatures/start_selling/presentation/controllers/seller_status_controller.dart';
import 'package:ojaewa/features/account/subfeatures/show_your_business/presentation/controllers/business_status_controller.dart';
import 'package:ojaewa/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:ojaewa/features/account/subfeatures/connect/presentation/controllers/connect_controller.dart';
import 'package:ojaewa/core/subscriptions/subscription_constants.dart';
import 'package:ojaewa/core/subscriptions/subscription_controller.dart';
import 'package:ojaewa/core/subscriptions/iap_service.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/widgets/confirmation_modal.dart';
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
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.onboarding, (r) => false);
      }
    });
    return Scaffold(
      backgroundColor: const Color(0xFF603814),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top bar (Account is a tab-root: no left/back icon)
            Builder(
              builder: (context) {
                final unreadCount = isLoggedIn
                    ? ref.watch(unreadCountProvider).maybeWhen(
                          data: (count) => count,
                          orElse: () => 0,
                        )
                    : 0;

                return Container(
                  height: 104,
                  color: const Color(0xFF603814),
                  padding: const EdgeInsets.only(top: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Row(
                          children: [
                            // Notification icon with badge
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                HeaderIconButton(
                                  asset: AppIcons.notificationSmall,
                                  iconColor: Colors.white,
                                  onTap: () => Navigator.of(context).pushNamed(
                                    AppRoutes.notifications,
                                  ),
                                ),
                                if (unreadCount > 0)
                                  Positioned(
                                    right: -4,
                                    top: -4,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFDAF40),
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 18,
                                        minHeight: 18,
                                      ),
                                      child: Text(
                                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Campton',
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            HeaderIconButton(
                              asset: AppIcons.bag,
                              iconColor: Colors.white,
                              onTap: () => Navigator.of(context).pushNamed(
                                AppRoutes.cart,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Main content card
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF8F1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: AppBottomNavBar.height),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User greeting
                        const SizedBox(height: 16), // 120 - 104
                        profile.when(
                          loading: () => const Text(
                            'Hello',
                            style: TextStyle(
                              fontSize: 33,
                              fontFamily: 'Campton',
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF241508),
                            ),
                          ),
                          error: (e, st) => const Text(
                            'Hello',
                            style: TextStyle(
                              fontSize: 33,
                              fontFamily: 'Campton',
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF241508),
                            ),
                          ),
                          data: (u) => Text(
                           'Hello ${u?.fullName ?? 'Guest'}',
                           style: const TextStyle(
                             fontSize: 33,
                             fontFamily: 'Campton',
                             fontWeight: FontWeight.w600,
                             color: Color(0xFF241508),
                           ),
                         ),
                       ),

                        // Profile section
                        const SizedBox(height: 24),
                        _buildSectionHeader('Profile'),
                        _buildMenuItem(
                          iconAsset: AppIcons.editYourProfile,
                          label: 'Edit your profile',
                          onTap: () => Navigator.of(context).pushNamed(AppRoutes.editProfile),
                        ),

                        // Orders section
                        const SizedBox(height: 24),
                        _buildSectionHeader('Orders'),
                        _buildMenuItem(
                          iconAsset: AppIcons.yourOrders,
                          label: 'Your orders',
                          onTap: () => Navigator.of(context).pushNamed(AppRoutes.orders),
                        ),

                        // Settings section
                        const SizedBox(height: 24),
                        _buildSectionHeader('Settings'),
                        _buildSettingsList(context),

                        if (isLoggedIn) ...[
                          // Subscription status
                          const SizedBox(height: 16),
                          _buildSubscriptionStatusCard(ref),

                          // AI Features section
                          /*
                          const SizedBox(height: 24),
                          _buildSectionHeader('AI Features'),
                          _buildAiFeaturesList(context),
                          */
                        ],

                        // Business section
                        const SizedBox(height: 24),
                        _buildSectionHeader('Ojá-Ẹwà Business'),
                        _buildBusinessList(context, ref),

                        // Support section
                        const SizedBox(height: 24),
                        _buildSectionHeader('Support'),
                        _buildSupportList(context, ref, isLoggedIn: isLoggedIn),

                        // Bottom spacing
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'Campton',
          fontWeight: FontWeight.w400,
          color: Color(0xFF777F84),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String iconAsset,
    required String label,
    required VoidCallback onTap,
  }) {
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
                      color: const Color(0xFFF5E0CE),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      iconAsset,
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF1E2021),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF1E2021),
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: Color(0xFF1E2021),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          iconAsset: AppIcons.yourAddress,
          label: 'Your Addresses',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.addresses),
        ),
        _buildMenuItem(
          iconAsset: AppIcons.notification,
          label: 'Notifications',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.notificationsSettings),
        ),
        _buildMenuItem(
          iconAsset: AppIcons.password,
          label: 'Password',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.changePassword),
        ),
      ],
    );
  }

  Widget _buildAiFeaturesList(BuildContext context) {
    return Column(
      children: [
        _buildMenuItemWithIcon(
          icon: Icons.psychology,
          label: 'Cultural AI Assistant',
          subtitle: 'Get fashion advice with Nigerian context',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.aiChat),
        ),
        _buildMenuItemWithIcon(
          icon: Icons.auto_awesome,
          label: 'Your Style Profile',
          subtitle: 'Discover your personalized style DNA',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.styleDnaQuiz),
        ),
        _buildMenuItemWithIcon(
          icon: Icons.recommend,
          label: 'For You',
          subtitle: 'AI-curated recommendations',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.personalizedRecommendations),
        ),
      ],
    );
  }

  Widget _buildMenuItemWithIcon({
    required IconData icon,
    required String label,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      height: subtitle != null ? 64 : 48,
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDAF40).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: const Color(0xFFFDAF40),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Campton',
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF241508),
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Campton',
                          color: const Color(0xFF241508).withOpacity(0.6),
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Color(0xFFCCCCCC),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionStatusCard(WidgetRef ref) {
    final subscriptionState = ref.watch(subscriptionControllerProvider).value;
    final subscription = subscriptionState?.subscription;
    final hasPro = subscription != null && subscription.status.isActive;
    final expiresText = subscription?.expiresAt != null
        ? 'Expires on ${subscription!.expiresAt.toLocal().toString().split(' ').first}'
        : 'Subscribe to unlock seller AI tools';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5E0CE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: hasPro ? const Color(0xFF4CAF50) : const Color(0xFFCCCCCC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              hasPro ? Icons.verified : Icons.lock_outline,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasPro ? 'Ojaewa Pro Active' : 'Ojaewa Pro Inactive',
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF241508),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasPro ? expiresText : 'Subscribe to sell and publish your business profile',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Campton',
                    color: Color(0xFF777F84),
                  ),
                ),
              ],
            ),
          ),
          if (!hasPro)
            TextButton(
              onPressed: () async {
                await ref.read(iapServiceProvider).purchaseSubscription(
                      SubscriptionProducts.ojaewaProYearly,
                    );
              },
              child: const Text(
                'Subscribe',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFDAF40),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBusinessList(BuildContext context, WidgetRef ref) {
    final isSellerApproved = ref.watch(isSellerApprovedProvider);
    final hasApprovedBusiness = ref.watch(hasApprovedBusinessProvider);

    return Column(
      children: [
        _buildMenuItem(
          iconAsset: AppIcons.startSelling,
          label: 'Start selling',
          onTap: () => Navigator.of(context).pushNamed(
            isSellerApproved ? AppRoutes.yourShopDashboard : AppRoutes.sellerOnboarding,
          ),
        ),
        _buildMenuItem(
          iconAsset: AppIcons.showYourBusiness,
          label: 'Show your business',
          onTap: () => Navigator.of(context).pushNamed(
            hasApprovedBusiness ? AppRoutes.businessSettings : AppRoutes.businessOnboarding,
          ),
        ),
      ],
    );
  }

  Widget _buildSupportList(BuildContext context, WidgetRef ref, {required bool isLoggedIn}) {
    return Column(
      children: [
        _buildMenuItem(
          iconAsset: AppIcons.emailUs,
          label: 'Email Us',
          onTap: () => _handleEmailUs(context, ref),
        ),
        _buildMenuItem(
          iconAsset: AppIcons.privacyPolicy,
          label: 'Privacy Policy',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.privacyPolicy),
        ),
        _buildMenuItem(
          iconAsset: AppIcons.termsOfService,
          label: 'Terms of Service',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.termsOfService),
        ),
        _buildMenuItem(
          iconAsset: AppIcons.faq,
          label: 'FAQ',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.faq),
        ),
        _buildMenuItem(
          iconAsset: AppIcons.connectToUs,
          label: 'Connect to us',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.connectToUs),
        ),
        
        // Test notification button (only for test users)
        if (_isTestUser(ref))
          _buildTestNotificationButton(context, ref),
        
        // Delete Account — only shown when logged in
        if (isLoggedIn)
          _buildDeleteAccountButton(context, ref),

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
                    builder: (_) => const Center(child: CircularProgressIndicator()),
                  );
                  try {
                    await ref.read(authFlowControllerProvider.notifier).logout();
                    if (!context.mounted) return;
                    Navigator.of(context).pop(); // close loader
                    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.onboarding, (r) => false);
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
                          color: isLoggedIn ? const Color(0xFFF7E5E5) : const Color(0xFFE5F7E5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          AppIcons.signOut,
                          width: 16,
                          height: 16,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF1E2021),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isLoggedIn ? 'Sign Out' : 'Sign In',
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Campton',
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF1E2021),
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Color(0xFF1E2021),
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
      email = connectInfo.email.isNotEmpty ? connectInfo.email : 'support@ojaewa.com';
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
                      color: const Color(0xFFF7E5E5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.delete_forever_outlined,
                      size: 16,
                      color: Color(0xFFD32F2F),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Delete Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFD32F2F),
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: Color(0xFFD32F2F),
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
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.onboarding,
        (r) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // close loader
      AppSnackbars.showError(context, 'Failed to delete account. Please try again.');
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
        color: const Color(0xFFFDAF40).withOpacity(0.1),
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
                  fontFamily: 'Campton',
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
  Future<void> _sendTestNotification(BuildContext context, WidgetRef ref) async {
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
      AppSnackbars.showSuccess(context, 'Test notification sent! Check your device.');
    } catch (e) {
      // Hide loading
      if (!context.mounted) return;
      Navigator.of(context).pop();

      // Show error
      AppSnackbars.showError(context, 'Failed to send test notification: $e');
    }
  }
}
