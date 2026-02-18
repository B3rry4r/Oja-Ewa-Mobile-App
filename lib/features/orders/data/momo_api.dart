import 'package:dio/dio.dart';

import '../../../core/network/dio_error_mapper.dart';

/// MTN MoMo Payment API
class MoMoApi {
  MoMoApi(this._dio);

  final Dio _dio;

  /// Initialize MoMo payment for an order
  /// Returns reference_id for polling and callback tracking
  Future<MoMoPaymentInitResponse> initializePayment({
    required int orderId,
    required String phone,
  }) async {
    try {
      final res = await _dio.post('/api/momo/initialize', data: {
        'order_id': orderId,
        'phone': phone,
      });
      final data = res.data;
      if (data is! Map<String, dynamic>) throw const FormatException('Unexpected response');
      
      final responseData = (data['data'] as Map?)?.cast<String, dynamic>() ?? const {};
      return MoMoPaymentInitResponse.fromJson(responseData);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  /// Check MoMo payment status
  Future<MoMoPaymentStatusResponse> checkPaymentStatus({
    required String referenceId,
  }) async {
    try {
      final res = await _dio.post('/api/momo/check-status', data: {
        'reference_id': referenceId,
      });
      final data = res.data;
      if (data is! Map<String, dynamic>) throw const FormatException('Unexpected response');
      
      final responseData = (data['data'] as Map?)?.cast<String, dynamic>() ?? const {};
      return MoMoPaymentStatusResponse.fromJson(responseData);
    } catch (e) {
      throw mapDioError(e);
    }
  }
}

/// MoMo payment initialization response
class MoMoPaymentInitResponse {
  const MoMoPaymentInitResponse({
    required this.referenceId,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.phone,
    required this.paymentStatus,
  });

  final String referenceId;
  final int orderId;
  final num amount;
  final String currency;
  final String phone;
  final String paymentStatus;

  factory MoMoPaymentInitResponse.fromJson(Map<String, dynamic> json) {
    return MoMoPaymentInitResponse(
      referenceId: json['reference_id'] as String? ?? '',
      orderId: json['order_id'] as int? ?? 0,
      amount: json['amount'] as num? ?? 0,
      currency: json['currency'] as String? ?? 'NGN',
      phone: json['phone'] as String? ?? '',
      paymentStatus: json['payment_status'] as String? ?? 'pending',
    );
  }
}

/// MoMo payment status check response
class MoMoPaymentStatusResponse {
  const MoMoPaymentStatusResponse({
    required this.transactionStatus,
    required this.referenceId,
    required this.order,
  });

  final String transactionStatus; // SUCCESSFUL | PENDING | FAILED
  final String referenceId;
  final MoMoOrderInfo? order;

  factory MoMoPaymentStatusResponse.fromJson(Map<String, dynamic> json) {
    final orderData = json['order'] as Map<String, dynamic>?;
    return MoMoPaymentStatusResponse(
      transactionStatus: json['transaction_status'] as String? ?? 'PENDING',
      referenceId: json['reference_id'] as String? ?? '',
      order: orderData != null ? MoMoOrderInfo.fromJson(orderData) : null,
    );
  }

  bool get isSuccessful => transactionStatus == 'SUCCESSFUL';
  bool get isPending => transactionStatus == 'PENDING';
  bool get isFailed => transactionStatus == 'FAILED';
}

/// Order info from MoMo payment status
class MoMoOrderInfo {
  const MoMoOrderInfo({
    required this.id,
    required this.paymentStatus,
    required this.status,
  });

  final int id;
  final String paymentStatus;
  final String status;

  factory MoMoOrderInfo.fromJson(Map<String, dynamic> json) {
    return MoMoOrderInfo(
      id: json['id'] as int? ?? 0,
      paymentStatus: json['payment_status'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}
