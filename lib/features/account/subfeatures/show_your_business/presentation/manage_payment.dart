import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';

class ManagePaymentScreen extends StatelessWidget {
  const ManagePaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1), // Cream background from IR
      body: Column(
        children: [
          const AppHeader(
            backgroundColor: Color(0xFFFFF8F1),
            iconColor: Color(0xFF241508),
            title: Text(
              'manage payment',
              style: TextStyle(
                color: Color(0xFF241508),
                fontSize: 22,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 140), // Spacing to match top: 214 intent

                  // Expiration and Status Text
                  const Text(
                    'Your payment will expire on 24th july, 2023\n'
                    'Your account will no longer show on the\n'
                    'platform if you dont renew',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF3C4042),
                      height: 1.5,
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
                          'Renew Subscription',
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
          ),
        ],
      ),
    );
  }
}
