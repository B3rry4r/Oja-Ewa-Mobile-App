import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/nepc_services_api.dart';
import '../../domain/nepc_registration_request.dart';
import 'nepc_requests_controller.dart';

class PendingNepcRequest {
  const PendingNepcRequest({
    required this.applicationType,
    required this.businessType,
    required this.documents,
    required this.businessName,
    required this.registrationNumber,
    required this.businessAddress,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.productsToExport,
    required this.confirmedInformation,
    required this.amount,
  });

  final String applicationType;
  final String businessType;
  final List<Map<String, dynamic>> documents;
  final String businessName;
  final String registrationNumber;
  final String businessAddress;
  final String fullName;
  final String phoneNumber;
  final String email;
  final String productsToExport;
  final bool confirmedInformation;
  final num amount;
}

class NepcPaymentState {
  const NepcPaymentState({
    this.isProcessing = false,
    this.pendingRequest,
    this.createdRequest,
    this.error,
  });

  final bool isProcessing;
  final PendingNepcRequest? pendingRequest;
  final NepcRegistrationRequest? createdRequest;
  final String? error;

  NepcPaymentState copyWith({
    bool? isProcessing,
    PendingNepcRequest? pendingRequest,
    NepcRegistrationRequest? createdRequest,
    String? error,
    bool clearPending = false,
    bool clearCreated = false,
  }) {
    return NepcPaymentState(
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

class NepcPaymentController extends Notifier<NepcPaymentState> {
  @override
  NepcPaymentState build() => const NepcPaymentState();

  Future<String?> startCheckout(PendingNepcRequest request) async {
    state = state.copyWith(
      isProcessing: true,
      pendingRequest: request,
      error: null,
      clearCreated: true,
    );
    try {
      final paymentData = await ref
          .read(nepcServicesApiProvider)
          .createPaymentLink(applicationType: request.applicationType);
      final paymentUrl = paymentData['payment_url'] as String?;
      final amount = paymentData['amount'];
      final resolvedAmount = amount is num ? amount : request.amount;
      state = state.copyWith(
        isProcessing: false,
        pendingRequest: PendingNepcRequest(
          applicationType: request.applicationType,
          businessType: request.businessType,
          documents: request.documents,
          businessName: request.businessName,
          registrationNumber: request.registrationNumber,
          businessAddress: request.businessAddress,
          fullName: request.fullName,
          phoneNumber: request.phoneNumber,
          email: request.email,
          productsToExport: request.productsToExport,
          confirmedInformation: request.confirmedInformation,
          amount: resolvedAmount,
        ),
      );
      return paymentUrl;
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: e.toString());
      return null;
    }
  }

  Future<NepcRegistrationRequest?> finalizePayment({
    required String reference,
  }) async {
    final pending = state.pendingRequest;
    if (pending == null) {
      state = state.copyWith(error: 'No NEPC request is waiting for payment');
      return null;
    }

    state = state.copyWith(isProcessing: true, error: null);
    try {
      final request = await ref
          .read(nepcServicesApiProvider)
          .createRequest(
            applicationType: pending.applicationType,
            businessType: pending.businessType,
            documents: pending.documents,
            businessName: pending.businessName,
            registrationNumber: pending.registrationNumber,
            businessAddress: pending.businessAddress,
            fullName: pending.fullName,
            phoneNumber: pending.phoneNumber,
            email: pending.email,
            productsToExport: pending.productsToExport,
            confirmedInformation: pending.confirmedInformation,
            paymentReference: reference,
            currency: 'NGN',
            amount: pending.amount,
          );
      state = state.copyWith(
        isProcessing: false,
        createdRequest: request,
        clearPending: true,
      );
      ref.invalidate(nepcRequestsProvider);
      return request;
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: e.toString());
      return null;
    }
  }
}

final nepcPaymentControllerProvider =
    NotifierProvider<NepcPaymentController, NepcPaymentState>(
      NepcPaymentController.new,
    );
