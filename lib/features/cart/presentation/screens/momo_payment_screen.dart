import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/widgets/app_header.dart';
import '../../../orders/data/orders_repository_impl.dart';
import '../../../orders/presentation/controllers/orders_controller.dart';

/// MoMo payment screen with polling logic
class MoMoPaymentScreen extends ConsumerStatefulWidget {
  const MoMoPaymentScreen({
    super.key,
    required this.referenceId,
    required this.orderId,
    required this.phone,
  });

  final String referenceId;
  final int orderId;
  final String phone;

  @override
  ConsumerState<MoMoPaymentScreen> createState() => _MoMoPaymentScreenState();
}

class _MoMoPaymentScreenState extends ConsumerState<MoMoPaymentScreen> {
  Timer? _pollTimer;
  bool _isPolling = false;
  String _status = 'pending';
  int _pollCount = 0;
  static const int _maxPolls = 36; // 36 * 5 seconds = 3 minutes
  bool _deepLinkHandled = false;

  @override
  void initState() {
    super.initState();
    // Wait a bit before starting polling - deep link should arrive first if payment is quick
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_deepLinkHandled && _status == 'pending') {
        _startPolling();
      }
    });
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }

  void _startPolling() {
    if (_deepLinkHandled) return; // Don't poll if deep link already handled
    _isPolling = true;
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkPaymentStatus();
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _isPolling = false;
  }

  Future<void> _checkPaymentStatus() async {
    if (!_isPolling || !mounted || _deepLinkHandled) return;

    _pollCount++;

    // Stop polling after max attempts
    if (_pollCount >= _maxPolls) {
      _stopPolling();
      if (mounted) {
        setState(() {
          _status = 'timeout';
        });
      }
      return;
    }

    try {
      final response = await ref.read(ordersRepositoryProvider).checkMoMoPaymentStatus(
        referenceId: widget.referenceId,
      );

      if (!mounted || _deepLinkHandled) return;

      if (response.isSuccessful) {
        _stopPolling();
        _deepLinkHandled = true; // Mark as handled
        setState(() {
          _status = 'success';
        });
        // Invalidate orders to refresh the list
        ref.invalidate(ordersProvider);
        _showSuccessAndNavigate();
      } else if (response.isFailed) {
        _stopPolling();
        _deepLinkHandled = true; // Mark as handled
        setState(() {
          _status = 'failed';
        });
      }
      // Continue polling if still pending
    } catch (e) {
      debugPrint('Error checking MoMo payment status (will retry): $e');
      // Continue polling on error, don't stop
    }
  }

  void _showSuccessAndNavigate() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierLabel: 'PaymentSuccess',
        barrierColor: const Color(0xFF1E2021).withValues(alpha: 0.8),
        pageBuilder: (context, anim1, anim2) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: 342,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBF5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Color(0xFF4CAF50),
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Payment Successful',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF603814),
                          fontFamily: 'Campton',
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Your order has been placed successfully!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF1E2021),
                          fontFamily: 'Campton',
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/',
                                  (route) => false,
                                );
                              },
                              child: Container(
                                height: 57,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFCCCCCC),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Continue',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF595F63),
                                      fontFamily: 'Campton',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  AppRoutes.orders,
                                  (route) => route.isFirst,
                                );
                              },
                              child: Container(
                                height: 57,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDAF40),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFDAF40).withValues(alpha: 0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    'View Orders',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFFFFBF5),
                                      fontFamily: 'Campton',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              backgroundColor: const Color(0xFFFFF8F1),
              iconColor: const Color(0xFF241508),
              showActions: false,
              title: const Text(
                'Processing Payment',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Campton',
                  color: Color(0xFF241508),
                ),
              ),
              onBack: () {
                if (_status == 'pending') {
                  _showCancelConfirmation();
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: _buildStatusContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusContent() {
    switch (_status) {
      case 'pending':
        return _buildPendingState();
      case 'success':
        return _buildSuccessState();
      case 'failed':
        return _buildFailedState();
      case 'timeout':
        return _buildTimeoutState();
      default:
        return _buildPendingState();
    }
  }

  Widget _buildPendingState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFFFCB05).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.phone_android,
            color: Color(0xFFFFCB05),
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Waiting for Payment',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF603814),
            fontFamily: 'Campton',
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please check your phone (${widget.phone}) and approve the payment request',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1E2021),
            fontFamily: 'Campton',
          ),
        ),
        const SizedBox(height: 32),
        const SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            color: Color(0xFFFDAF40),
            strokeWidth: 3,
          ),
        ),
        if (_isPolling && _pollCount > 0) ...[
          const SizedBox(height: 16),
          Text(
            'Verifying payment... (${_pollCount * 5}s)',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF777F84),
              fontFamily: 'Campton',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            color: Color(0xFF4CAF50),
            size: 50,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Payment Successful!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF603814),
            fontFamily: 'Campton',
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Your order has been confirmed',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF1E2021),
            fontFamily: 'Campton',
          ),
        ),
      ],
    );
  }

  Widget _buildFailedState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFE53935).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error,
            color: Color(0xFFE53935),
            size: 50,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Payment Failed',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF603814),
            fontFamily: 'Campton',
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'The payment was not successful. Please try again.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF1E2021),
            fontFamily: 'Campton',
          ),
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: double.infinity,
            height: 57,
            decoration: BoxDecoration(
              color: const Color(0xFFFDAF40),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFFBF5),
                  fontFamily: 'Campton',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeoutState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFFF9800).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.access_time,
            color: Color(0xFFFF9800),
            size: 50,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Payment Timeout',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF603814),
            fontFamily: 'Campton',
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'We couldn\'t verify your payment. Please check your orders or try again.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF1E2021),
            fontFamily: 'Campton',
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  height: 57,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCCCCCC)),
                  ),
                  child: const Center(
                    child: Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF595F63),
                        fontFamily: 'Campton',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.orders,
                    (route) => route.isFirst,
                  );
                },
                child: Container(
                  height: 57,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDAF40),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'View Orders',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFFBF5),
                        fontFamily: 'Campton',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Payment?'),
        content: const Text(
          'Payment is still being processed. Are you sure you want to go back?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue Waiting'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}
