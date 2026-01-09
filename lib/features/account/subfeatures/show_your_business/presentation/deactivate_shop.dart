import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';

import '../../../../../app/router/app_router.dart';
import '../../../../../core/widgets/confirmation_modal.dart';

class DeactivateShopScreen extends StatelessWidget {
  const DeactivateShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: Column(
        children: [
          const AppHeader(
            backgroundColor: Color(0xFFFFF8F1),
            iconColor: Color(0xFF241508),
            title: Text(
              'Deactivate shop',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w600,
                color: Color(0xFF241508),
              ),
            ),
          ),
          Expanded(
            child: Padding(
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
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.home,
                            (route) => false,
                          );
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
          ),
        ],
      ),
    );
  }
}
