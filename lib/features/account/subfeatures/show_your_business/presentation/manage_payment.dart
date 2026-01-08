import 'package:flutter/material.dart';

class ManagePaymentScreen extends StatelessWidget {
  const ManagePaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1), // Cream background from IR
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 140), // Spacing to match top: 214 intent
            
            // Expiration and Status Text
            const Text(
              "Your payment will expire on 24th july, 2023\nYour account will no longer show on the\nplatform if you dont renew",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w400,
                color: Color(0xFF3C4042),
                height: 1.5, // Line height for better readability
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Renew Subscription Button
            GestureDetector(
              onTap: () {
                // Logic for renewal payment
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
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
                child: const Center(
                  child: Text(
                    "Renew Subscription",
                    style: TextStyle(
                      color: Color(0xFFFFFBF5),
                      fontSize: 16,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w600,
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 70,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
        child: _HeaderButton(
          icon: Icons.arrow_back_ios_new, 
          onTap: () => Navigator.pop(context),
        ),
      ),
      centerTitle: true,
      title: const Text(
        "manage payment",
        style: TextStyle(
          color: Color(0xFF241508),
          fontSize: 22,
          fontFamily: 'Campton',
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          child: _HeaderButton(
            icon: Icons.notifications_none, 
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

/// Styled square button for AppBar actions
class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.onTap});

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
        child: Icon(icon, size: 18, color: const Color(0xFF1E2021)),
      ),
    );
  }
}