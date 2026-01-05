// splash_screen.dart
import 'package:flutter/material.dart';

import '../../../app/router/app_router.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate loading and navigate to next screen after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1), // #fff8f1
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Brand Logo/Name
            _buildBrandLogo(),

            // Subtitle (optional - added for better UX)
            const SizedBox(height: 40),
            _buildLoadingIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background decorative element with low opacity
        Opacity(
          opacity: 0.1,
          child: Container(
            width: 311,
            height: 461,
            decoration: BoxDecoration(
              color: const Color(0xFFFDAF40).withOpacity(0.2),
              borderRadius: BorderRadius.circular(150),
            ),
            child: const Center(
              child: Icon(
                Icons.spa_rounded,
                size: 120,
                color: Color(0xFFFDAF40),
              ),
            ),
          ),
        ),

        // Brand Name Container
        Container(
          width: 231.01,
          height: 61.89,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Decorative dot before text
                Container(
                  width: 18.91,
                  height: 18.91,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDAF40),
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 20),

                // Brand Name
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'oj',
                        style: TextStyle(
                          fontSize: 43.81,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Inter',
                          color: Color(0xFF000000),
                        ),
                      ),
                      TextSpan(
                        text: 'à-ewà',
                        style: TextStyle(
                          fontSize: 43.81,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Inter',
                          color: Color(0xFF000000),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Registered trademark symbol
                const Padding(
                  padding: EdgeInsets.only(top: 12.0),
                  child: Text(
                    '®',
                    style: TextStyle(
                      fontSize: 12.18,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Inter',
                      color: Color(0xFF000000),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFFFDAF40)),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Loading...',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Campton',
            color: const Color(0xFF777F84),
          ),
        ),
      ],
    );
  }
}

