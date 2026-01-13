// profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/app/widgets/app_bottom_nav_bar.dart';
import 'package:ojaewa/core/resources/app_assets.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/features/account/presentation/controllers/profile_controller.dart';
import 'package:ojaewa/features/auth/presentation/controllers/auth_controller.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

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
            Container(
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
                        HeaderIconButton(
                          asset: AppIcons.notificationSmall,
                          iconColor: Colors.white,
                          onTap: () => Navigator.of(context).pushNamed(
                            AppRoutes.notifications,
                          ),
                        ),
                        const SizedBox(width: 8),
                        HeaderIconButton(
                          asset: AppIcons.bag,
                          iconColor: Colors.white,
                          onTap: () => Navigator.of(context).pushNamed(
                            AppRoutes.shoppingBag,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                           'Hello ${u.fullName}',
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

                        // Business section
                        const SizedBox(height: 24),
                        _buildSectionHeader('Oja Ewa Business'),
                        _buildBusinessList(context),

                        // Support section
                        const SizedBox(height: 24),
                        _buildSectionHeader('Support'),
                        _buildSupportList(context, ref),

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

  Widget _buildBusinessList(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          iconAsset: AppIcons.startSelling,
          label: 'Start selling',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.sellerOnboarding),
        ),
        _buildMenuItem(
          iconAsset: AppIcons.showYourBusiness,
          label: 'Show your business',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.businessOnboarding),
        ),
      ],
    );
  }

  Widget _buildSupportList(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildMenuItem(
          iconAsset: AppIcons.emailUs,
          label: 'Email Us',
          onTap: () {},
        ),
        _buildMenuItem(
          iconAsset: AppIcons.privacyPolicy,
          label: 'Privacy Policy',
          onTap: () {},
        ),
        _buildMenuItem(
          iconAsset: AppIcons.termsOfService,
          label: 'Terms of Service',
          onTap: () {},
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
        // Sign Out with different styling
        Container(
          height: 48,
          margin: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                await ref.read(authFlowControllerProvider.notifier).logout();
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
                      const Text(
                        'Sign Out',
                        style: TextStyle(
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
}
