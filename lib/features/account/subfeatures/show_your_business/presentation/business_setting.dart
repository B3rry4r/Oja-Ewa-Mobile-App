import 'package:flutter/material.dart';

class BusinessSettingsScreen extends StatelessWidget {
  const BusinessSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1), // Main background from IR
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 18),
              _buildTitleAndAddButton(context),
              const SizedBox(height: 16),
              _buildBusinessList(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Top Navigation Bar with circular-style buttons
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _IconButton(icon: Icons.arrow_back_ios_new, onTap: () {}),
          Row(
            children: [
              _IconButton(icon: Icons.search, onTap: () {}),
              const SizedBox(width: 4),
              _IconButton(icon: Icons.notifications_none, onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }

  /// Title and "Add New Business" action
  Widget _buildTitleAndAddButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            "Your Business",
            style: TextStyle(
              fontSize: 33,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: Color(0xFF241508),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFDAF40),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFDAF40).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: const Text(
                "Add New Business",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Campton',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// List of business items
  Widget _buildBusinessList(BuildContext context) {
    final businesses = ["Dija Stitches", "Arin World"];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: businesses.length,
      separatorBuilder: (_, __) => const Divider(color: Color(0xFFDEDEDE), height: 1),
      itemBuilder: (context, index) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          title: Text(
            businesses[index],
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E2021),
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.more_horiz, color: Color(0xFF1E2021)),
            onPressed: () => _showBusinessActions(context, businesses[index]),
          ),
        );
      },
    );
  }

  /// Action Sheet inferred from response2.json
  void _showBusinessActions(BuildContext context, String businessName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFF8F1),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
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
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              _buildModalOption(
                icon: Icons.edit_outlined,
                label: "Edit Business Information",
                onTap: () => Navigator.pop(context),
              ),
              const Divider(color: Color(0xFFDEDEDE)),
              _buildModalOption(
                icon: Icons.payment_outlined,
                label: "Manage Payment",
                onTap: () => Navigator.pop(context),
              ),
              const Divider(color: Color(0xFFDEDEDE)),
              _buildModalOption(
                icon: Icons.power_settings_new,
                label: "Deactivate Shop",
                isDestructive: true,
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : const Color(0xFF1E2021)),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontFamily: 'Campton',
          fontWeight: FontWeight.w400,
          color: isDestructive ? Colors.red : const Color(0xFF1E2021),
        ),
      ),
      onTap: onTap,
    );
  }
}

/// Reusable icon button component for the header
class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFDEDEDE)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF1E2021)),
      ),
    );
  }
}