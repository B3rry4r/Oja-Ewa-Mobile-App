import 'package:flutter/material.dart';
import 'package:ojaewa/app/theme/app_theme_colors.dart';

/// Payment method selection bottom sheet
/// Allows users to choose between Paystack and MTN MoMo
class PaymentMethodSheet extends StatelessWidget {
  const PaymentMethodSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.textTertiary.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Select Payment Method',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                  fontFamily: 'Campton',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how you want to pay',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.textTertiary,
                  fontFamily: 'Campton',
                ),
              ),
              const SizedBox(height: 24),

              // MTN MoMo option
              _PaymentMethodOption(
                title: 'MTN Mobile Money',
                subtitle: 'Pay with MTN Mobile Money',
                onTap: () => Navigator.of(context).pop('momo'),
              ),
              const SizedBox(height: 16),

              // Paystack option
              _PaymentMethodOption(
                title: 'Paystack',
                subtitle: 'Pay with Paystack',
                onTap: () => Navigator.of(context).pop('paystack'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Show payment method selection sheet
  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PaymentMethodSheet(),
    );
  }
}

class _PaymentMethodOption extends StatelessWidget {
  const _PaymentMethodOption({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                      fontFamily: 'Campton',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textTertiary,
                      fontFamily: 'Campton',
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: colors.textTertiary, size: 16),
          ],
        ),
      ),
    );
  }
}
