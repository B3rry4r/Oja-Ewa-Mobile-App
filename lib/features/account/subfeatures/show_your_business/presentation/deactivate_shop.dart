import 'package:flutter/material.dart';

class DeactivateShopScreen extends StatefulWidget {
  const DeactivateShopScreen({super.key});

  @override
  State<DeactivateShopScreen> createState() => _DeactivateShopScreenState();
}

class _DeactivateShopScreenState extends State<DeactivateShopScreen> {
  int _selectedReasonIndex = 0;

  final List<String> _reasons = [
    "Not making money",
    "I have a better alternative",
    "The fees are too high",
    "Technical issues",
    "Other reasons",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Main Heading from IR
              const Text(
                "Why are you deactivating",
                style: TextStyle(
                  fontSize: 33,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF241508),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 32),

              // Selectable Reasons List
              Expanded(
                child: ListView.separated(
                  itemCount: _reasons.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final isSelected = _selectedReasonIndex == index;
                    return InkWell(
                      onTap: () => setState(() => _selectedReasonIndex = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            // Custom Radio/Checkbox from IR
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFFDAF40)
                                      : const Color(0xFF777F84),
                                  width: 2,
                                ),
                                color: isSelected
                                    ? const Color(0xFFFDAF40)
                                    : Colors.transparent,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _reasons[index],
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Campton',
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF1E2021),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Primary Action Button
              _buildDeactivateButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _HeaderButton(
          icon: Icons.arrow_back_ios_new,
          onTap: () => Navigator.pop(context),
        ),
      ),
      actions: [
        _HeaderButton(icon: Icons.search, onTap: () {}),
        const SizedBox(width: 8),
        _HeaderButton(icon: Icons.notifications_none, onTap: () {}),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildDeactivateButton() {
    return Container(
      width: double.infinity,
      height: 57,
      decoration: BoxDecoration(
        color: const Color(0xFFFDAF40),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFDAF40).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          "Continue to deactivate",
          style: TextStyle(
            color: Color(0xFFFFFBF5),
            fontSize: 16,
            fontFamily: 'Campton',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
