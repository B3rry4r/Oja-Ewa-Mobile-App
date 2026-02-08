import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/ui/ui_error_message.dart';
import '../controllers/auth_controller.dart';

/// Bottom sheet for users to add referral code after OAuth sign-up
class SetReferralCodeSheet extends ConsumerStatefulWidget {
  const SetReferralCodeSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => const SetReferralCodeSheet(),
    );
  }

  @override
  ConsumerState<SetReferralCodeSheet> createState() =>
      _SetReferralCodeSheetState();
}

class _SetReferralCodeSheetState extends ConsumerState<SetReferralCodeSheet> {
  final TextEditingController _referralCodeController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _referralCodeController.dispose();
    super.dispose();
  }

  Future<void> _submitReferralCode() async {
    final code = _referralCodeController.text.trim();
    
    if (code.isEmpty) {
      AppSnackbars.showError(context, 'Please enter a referral code');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref.read(authFlowControllerProvider.notifier).setReferralCode(
            referralCode: code,
          );

      if (!mounted) return;
      AppSnackbars.showSuccess(context, 'Referral code applied successfully!');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      AppSnackbars.showError(context, UiErrorMessage.from(e));
    }
  }

  void _skip() {
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8F1), // #fff8f1
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCCCCC),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),

              // Title
              Text(
                'Have a Referral Code?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Campton',
                  color: const Color(0xFF3C230C), // #3c230c
                ),
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                'Enter your referral code to unlock exclusive benefits and rewards.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Campton',
                  color: const Color(0xFF777F84), // #777f84
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // Referral Code Input
              _buildReferralCodeInput(),

              const SizedBox(height: 24),

              // Submit Button
              _buildSubmitButton(),

              const SizedBox(height: 12),

              // Skip Button
              _buildSkipButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReferralCodeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Referral Code',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Campton',
            color: const Color(0xFF777F84), // #777f84
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFCCCCCC), // #cccccc
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(
                  Icons.card_giftcard_outlined,
                  size: 20,
                  color: Color(0xFFCCCCCC),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _referralCodeController,
                    textCapitalization: TextCapitalization.characters,
                    enabled: !_isSubmitting,
                    autofocus: true,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Campton',
                      color: const Color(0xFF1E2021),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter referral code',
                      hintStyle: TextStyle(color: Color(0xFFCCCCCC)),
                    ),
                    onSubmitted: (_) => _submitReferralCode(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 57,
      decoration: BoxDecoration(
        color: _isSubmitting
            ? const Color(0xFFFDAF40).withValues(alpha: 0.5)
            : const Color(0xFFFDAF40),
        borderRadius: BorderRadius.circular(8),
        boxShadow: !_isSubmitting
            ? [
                BoxShadow(
                  color: const Color(0xFFFDAF40).withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _isSubmitting ? null : _submitReferralCode,
          child: Center(
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFFFFBF5),
                    ),
                  )
                : Text(
                    'Apply Code',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Campton',
                      color: const Color(0xFFFFFBF5),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Container(
      width: double.infinity,
      height: 57,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFCCCCCC), // #cccccc
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _isSubmitting ? null : _skip,
          child: Center(
            child: Text(
              'Skip for Now',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Campton',
                color: const Color(0xFF777F84),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
