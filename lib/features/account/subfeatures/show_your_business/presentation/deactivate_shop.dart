import 'package:flutter/material.dart';

import '../../../../../core/widgets/confirmation_modal.dart';

class DeactivateShopScreen extends StatelessWidget {
  const DeactivateShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF241508)),
        ),
        title: const Text(
          'Deactivate shop',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Campton',
            fontWeight: FontWeight.w600,
            color: Color(0xFF241508),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Deactivate your shop',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w700,
                color: Color(0xFF241508),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This will hide your business from customers until you reactivate it.',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w400,
                color: Color(0xFF777F84),
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                ConfirmationModal.show(
                  context,
                  title: 'Deactivate shop',
                  message: 'Are you sure you want to deactivate your shop?',
                  confirmLabel: 'Deactivate',
                  onConfirm: () {
                    // TODO: deactivate later.
                  },
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
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
                    )
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Deactivate',
                    style: TextStyle(
                      color: Color(0xFFFFFBF5),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Campton',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
