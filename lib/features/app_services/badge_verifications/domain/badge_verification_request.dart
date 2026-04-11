class BadgeVerificationRequest {
  const BadgeVerificationRequest({
    required this.id,
    required this.status,
    required this.badge,
    required this.applicationReference,
    this.currency,
    this.amount,
  });

  final int id;
  final String status;
  final String badge;
  final String applicationReference;
  final String? currency;
  final String? amount;

  factory BadgeVerificationRequest.fromJson(Map<String, dynamic> json) {
    return BadgeVerificationRequest(
      id: (json['id'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'submitted',
      badge: json['badge'] as String? ?? '',
      applicationReference: json['application_reference'] as String? ?? '',
      currency: json['currency'] as String?,
      amount: json['amount']?.toString(),
    );
  }
}
