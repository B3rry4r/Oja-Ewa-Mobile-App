// profile_screen.dart
import 'package:flutter/material.dart';

import '../../../app/router/app_router.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF603814),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with three buttons
            Container(
              height: 104,
              color: const Color(0xFF603814),
              padding: const EdgeInsets.only(top: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Menu button
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: _buildIconButton(Icons.menu),
                  ),

                  // Right buttons
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Row(
                      children: [
                        _buildIconButton(Icons.search),
                        const SizedBox(width: 8),
                        _buildIconButton(Icons.more_vert),
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User greeting
                        const SizedBox(height: 16), // 120 - 104
                        const Text(
                          'Hello Sanusi',
                          style: TextStyle(
                            fontSize: 33,
                            fontFamily: 'Campton',
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF241508),
                          ),
                        ),

                        // Profile section
                        const SizedBox(height: 45), // 181 - 120 - 16
                        _buildSectionHeader('Profile'),
                        _buildMenuItem(
                          icon: Icons.person_outline,
                          label: 'Edit your profile',
                          onTap: () => Navigator.of(context).pushNamed(AppRoutes.editProfile),
                        ),

                        // Orders section
                        const SizedBox(height: 50), // 275 - 181 - 44
                        _buildSectionHeader('Orders'),
                        _buildMenuItem(
                          icon: Icons.shopping_bag_outlined,
                          label: 'Your orders',
                          onTap: () => Navigator.of(context).pushNamed(AppRoutes.orders),
                        ),

                        // Settings section
                        const SizedBox(height: 68), // 369 - 275 - 26
                        _buildSectionHeader('Settings'),
                        _buildSettingsList(),

                        // Business section
                        const SizedBox(height: 116), // 559 - 369 - 74
                        _buildSectionHeader('Oja Ewa Business'),
                        _buildBusinessList(),

                        // Support section
                        const SizedBox(height: 118), // 701 - 559 - 42
                        _buildSectionHeader('Support'),
                        _buildSupportList(),

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

  Widget _buildIconButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDEDEDE)),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: () {
          // TODO: Wire these top-bar actions when designs are ready.
        },
        padding: EdgeInsets.zero,
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
    required IconData icon,
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
                    child: Icon(icon, size: 16, color: const Color(0xFF1E2021)),
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

  Widget _buildSettingsList() {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.notifications_outlined,
          label: 'Notifications',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.location_on_outlined,
          label: 'Your Addresses',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.lock_outline,
          label: 'Password',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildBusinessList() {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.store_outlined,
          label: 'Start selling',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.business_outlined,
          label: 'Show your business',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSupportList() {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.email_outlined,
          label: 'Email Us',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.privacy_tip_outlined,
          label: 'Privacy Policy',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.description_outlined,
          label: 'Terms of Service',
          onTap: () {},
        ),
        _buildMenuItem(icon: Icons.help_outline, label: 'FAQ', onTap: () {}),
        _buildMenuItem(
          icon: Icons.contact_support_outlined,
          label: 'Connect to us',
          onTap: () {},
        ),
        // Sign Out with different styling
        Container(
          height: 48,
          margin: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
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
                        child: const Icon(
                          Icons.logout_outlined,
                          size: 16,
                          color: Color(0xFF1E2021),
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
