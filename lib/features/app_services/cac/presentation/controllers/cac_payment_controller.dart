import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/features/app_services/cac/data/cac_services_api.dart';
import 'package:ojaewa/features/app_services/cac/domain/cac_registration_request.dart';
import 'package:ojaewa/features/app_services/cac/presentation/controllers/cac_requests_controller.dart';

class PendingCacRequest {
  const PendingCacRequest({
    required this.firstChoiceName,
    required this.secondChoiceName,
    required this.acceptedNameModificationAuthorization,
    required this.businessObjective,
    required this.proprietors,
    required this.email,
  });

  final String firstChoiceName;
  final String secondChoiceName;
  final bool acceptedNameModificationAuthorization;
  final String businessObjective;
  final List<Map<String, dynamic>> proprietors;
  final String email;
}

class CacPaymentState {
  const CacPaymentState({
    this.isProcessing = false,
    this.pendingRequest,
    this.createdRequest,
    this.error,
  });

  final bool isProcessing;
  final PendingCacRequest? pendingRequest;
  final CacRegistrationRequest? createdRequest;
  final String? error;

  CacPaymentState copyWith({
    bool? isProcessing,
    PendingCacRequest? pendingRequest,
    CacRegistrationRequest? createdRequest,
    String? error,
    bool clearPending = false,
    bool clearCreated = false,
  }) {
    return CacPaymentState(
      isProcessing: isProcessing ?? this.isProcessing,
      pendingRequest: clearPending
          ? null
          : (pendingRequest ?? this.pendingRequest),
      createdRequest: clearCreated
          ? null
          : (createdRequest ?? this.createdRequest),
      error: error,
    );
  }
}

class CacPaymentController extends Notifier<CacPaymentState> {
  static const cacAmountNgn = 15000;

  @override
  CacPaymentState build() => const CacPaymentState();

  Future<String?> startCheckout(PendingCacRequest request) async {
    state = state.copyWith(
      isProcessing: true,
      pendingRequest: request,
      error: null,
      clearCreated: true,
    );

    try {
      final paymentUrl = await ref
          .read(cacServicesApiProvider)
          .createPaymentLink(email: request.email, amount: cacAmountNgn);
      state = state.copyWith(isProcessing: false);
      return paymentUrl;
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: e.toString());
      return null;
    }
  }

  Future<CacRegistrationRequest?> finalizePayment({
    required String reference,
  }) async {
    final pending = state.pendingRequest;
    if (pending == null) {
      state = state.copyWith(error: 'No CAC request is waiting for payment');
      return null;
    }

    state = state.copyWith(isProcessing: true, error: null);
    try {
      final verify = await ref
          .read(cacServicesApiProvider)
          .verifyPayment(reference: reference);
      final verifyData = verify['data'] as Map<String, dynamic>? ?? const {};
      final paymentStatus = (verifyData['payment_status'] ?? verify['status'])
          ?.toString();
      if (paymentStatus != 'success') {
        state = state.copyWith(
          isProcessing: false,
          error: 'CAC payment verification failed',
        );
        return null;
      }

      final request = await ref
          .read(cacServicesApiProvider)
          .createRequest(
            firstChoiceName: pending.firstChoiceName,
            secondChoiceName: pending.secondChoiceName,
            acceptedNameModificationAuthorization:
                pending.acceptedNameModificationAuthorization,
            businessObjective: pending.businessObjective,
            proprietors: pending.proprietors,
            paymentReference: reference,
            currency: 'NGN',
            amount: cacAmountNgn,
            rawData: {
              'gateway_response': verifyData['gateway_response'],
              'paid_at': verifyData['paid_at'],
            },
          );
      state = state.copyWith(
        isProcessing: false,
        createdRequest: request,
        clearPending: true,
      );
      ref.invalidate(cacRequestsProvider);
      return request;
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: e.toString());
      return null;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final cacPaymentControllerProvider =
    NotifierProvider<CacPaymentController, CacPaymentState>(
      CacPaymentController.new,
    );
