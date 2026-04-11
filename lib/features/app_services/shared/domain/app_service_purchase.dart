class AppServicePurchase {
  const AppServicePurchase({
    required this.platform,
    required this.storeProductId,
    required this.storeTransactionId,
    this.purchaseToken,
    this.receiptData,
    this.environment,
    this.currency,
    this.amount,
    this.rawData,
  });

  final String platform;
  final String storeProductId;
  final String storeTransactionId;
  final String? purchaseToken;
  final String? receiptData;
  final String? environment;
  final String? currency;
  final num? amount;
  final Map<String, dynamic>? rawData;

  Map<String, dynamic> toJson() => {
    'platform': platform,
    'store_product_id': storeProductId,
    'store_transaction_id': storeTransactionId,
    if (purchaseToken != null) 'purchase_token': purchaseToken,
    if (receiptData != null) 'receipt_data': receiptData,
    if (environment != null) 'environment': environment,
    if (currency != null) 'currency': currency,
    if (amount != null) 'amount': amount,
    if (rawData != null) 'raw_data': rawData,
  };
}
