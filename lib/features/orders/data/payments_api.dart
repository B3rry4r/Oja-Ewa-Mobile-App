import 'package:dio/dio.dart';

import '../../../core/network/dio_error_mapper.dart';
import '../domain/order_models.dart';

class PaymentsApi {
  PaymentsApi(this._dio);

  final Dio _dio;

  /// The callback URL scheme for deep linking back to the app after payment
  static const callbackUrl = 'ojaewa://payment/callback';

  Future<PaymentLink> createOrderPaymentLink({
    required int orderId,
    // Currency is optional — server derives it from the order's shipping country.
    // Passing it here is belt-and-suspenders: the server will prefer its own
    // stored value but having it in the request aids debugging.
    String? currency,
  }) async {
    try {
      final body = <String, dynamic>{
        'order_id': orderId,
        'callback_url': callbackUrl,
      };
      if (currency != null && currency.isNotEmpty) {
        body['currency'] = currency.toUpperCase();
      }
      final res = await _dio.post('/api/payment/link', data: body);
      final data = res.data;
      if (data is! Map<String, dynamic>) throw const FormatException('Unexpected response');
      return PaymentLink.fromWrappedResponse((data['data'] as Map?)?.cast<String, dynamic>() ?? const {});
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<PaymentVerifyResult> verify({required String reference, String? transactionId}) async {
    try {
      final body = <String, dynamic>{'reference': reference};
      if (transactionId != null && transactionId.isNotEmpty) {
        body['transaction_id'] = int.tryParse(transactionId) ?? transactionId;
      }
      final res = await _dio.post('/api/payment/verify', data: body);
      final data = res.data;
      if (data is! Map<String, dynamic>) throw const FormatException('Unexpected response');
      return PaymentVerifyResult.fromWrappedResponse((data['data'] as Map?)?.cast<String, dynamic>() ?? const {});
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
