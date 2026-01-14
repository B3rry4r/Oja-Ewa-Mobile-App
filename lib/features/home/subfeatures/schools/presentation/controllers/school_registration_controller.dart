import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/core/network/dio_clients.dart';
import 'package:ojaewa/features/home/subfeatures/schools/data/school_registration_api.dart';

/// Provider for the school registration API (uses authenticated Dio with token interceptor)
final schoolRegistrationApiProvider = Provider<SchoolRegistrationApi>((ref) {
  final dio = ref.watch(laravelDioProvider);
  return SchoolRegistrationApi(dio);
});

/// School registration state
@immutable
class SchoolRegistrationState {
  const SchoolRegistrationState({
    this.isSubmitting = false,
    this.isGeneratingPaymentLink = false,
    this.registrationId,
    this.paymentUrl,
    this.error,
  });

  final bool isSubmitting;
  final bool isGeneratingPaymentLink;
  final int? registrationId;
  final String? paymentUrl;
  final String? error;

  SchoolRegistrationState copyWith({
    bool? isSubmitting,
    bool? isGeneratingPaymentLink,
    int? registrationId,
    String? paymentUrl,
    String? error,
  }) {
    return SchoolRegistrationState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isGeneratingPaymentLink: isGeneratingPaymentLink ?? this.isGeneratingPaymentLink,
      registrationId: registrationId ?? this.registrationId,
      paymentUrl: paymentUrl ?? this.paymentUrl,
      error: error,
    );
  }
}

/// Notifier for school registration flow
class SchoolRegistrationNotifier extends Notifier<SchoolRegistrationState> {
  @override
  SchoolRegistrationState build() => const SchoolRegistrationState();

  SchoolRegistrationApi get _api => ref.read(schoolRegistrationApiProvider);

  /// Submit registration form
  Future<bool> submitRegistration({
    required String country,
    required String fullName,
    required String phoneNumber,
    required String userState,
    required String city,
    required String address,
    int? businessId,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final response = await _api.submitRegistration(
        country: country,
        fullName: fullName,
        phoneNumber: phoneNumber,
        state: userState,
        city: city,
        address: address,
        businessId: businessId,
      );

      final data = response['data'] as Map<String, dynamic>?;
      final registrationId = (data?['id'] as num?)?.toInt();

      if (registrationId != null) {
        state = state.copyWith(
          isSubmitting: false,
          registrationId: registrationId,
        );
        return true;
      } else {
        state = state.copyWith(
          isSubmitting: false,
          error: 'Failed to get registration ID',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Generate payment link for the registration
  Future<String?> createPaymentLink({
    required String email,
  }) async {
    if (state.registrationId == null) {
      state = state.copyWith(error: 'No registration found');
      return null;
    }

    state = state.copyWith(isGeneratingPaymentLink: true, error: null);

    try {
      final response = await _api.createPaymentLink(
        registrationId: state.registrationId!,
        email: email,
      );

      final data = response['data'] as Map<String, dynamic>?;
      final paymentUrl = data?['payment_url'] as String?;

      if (paymentUrl != null) {
        state = state.copyWith(
          isGeneratingPaymentLink: false,
          paymentUrl: paymentUrl,
        );
        return paymentUrl;
      } else {
        state = state.copyWith(
          isGeneratingPaymentLink: false,
          error: 'Failed to generate payment link',
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        isGeneratingPaymentLink: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Reset state
  void reset() {
    state = const SchoolRegistrationState();
  }
}

/// Provider for school registration controller
final schoolRegistrationProvider =
    NotifierProvider.autoDispose<SchoolRegistrationNotifier, SchoolRegistrationState>(
  SchoolRegistrationNotifier.new,
);
