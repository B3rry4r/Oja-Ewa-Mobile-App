import 'package:flutter/material.dart';

import '../../../../../app/router/app_router.dart';
class ManageShopScreen extends StatelessWidget {
  const ManageShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1), // Background from IR
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 28),
              _buildHeader(),
              const SizedBox(height: 18),
              
              // Title: Manage Shop
              const Text(
                "Manage Shop",
                style: TextStyle(
                  fontSize: 33,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF241508),
                  fontFamily: 'Campton',
                ),
              ),
              const SizedBox(height: 24),

              // Menu Options
              _buildMenuOption(
                title: "Edit Business Information",
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.editBusiness),
              ),
              _buildMenuOption(
                title: "Delete Shop",
                titleColor: const Color(0xFFC95353), // Semantic Red for delete
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.deleteShop),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildIconBox(Icons.arrow_back_ios_new), // Back button
        Row(
          children: [
            _buildIconBox(Icons.notifications_none), // Notification
            const SizedBox(width: 8),
            _buildIconBox(Icons.person_outline), // Profile
          ],
        ),
      ],
    );
  }

  Widget _buildIconBox(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDEDEDE)), // Border from IR
      ),
      child: Icon(icon, size: 20, color: const Color(0xFF241508)),
    );
  }

  Widget _buildMenuOption({
    required String title,
    required VoidCallback onTap,
    Color titleColor = const Color(0xFF1E2021),
  }) {
    return Container(
      width: double.infinity,
      height: 72, // Height from IR
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFDEDEDE), width: 1), // Divider style
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: titleColor,
                fontFamily: 'Campton',
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF777F84),
            ),
          ],
        ),
      ),
    );
  }
}