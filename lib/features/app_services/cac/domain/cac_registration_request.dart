class CacRegistrationRequest {
  const CacRegistrationRequest({
    required this.id,
    required this.status,
    required this.firstChoiceName,
    required this.secondChoiceName,
    required this.applicationReference,
    required this.proprietorsCount,
    this.platform,
    this.currency,
    this.amount,
    this.paidAt,
    this.adminNote,
  });

  final int id;
  final String status;
  final String firstChoiceName;
  final String secondChoiceName;
  final String applicationReference;
  final int proprietorsCount;
  final String? platform;
  final String? currency;
  final String? amount;
  final DateTime? paidAt;
  final String? adminNote;

  factory CacRegistrationRequest.fromJson(Map<String, dynamic> json) {
    return CacRegistrationRequest(
      id: (json['id'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'submitted',
      firstChoiceName: json['first_choice_name'] as String? ?? '',
      secondChoiceName: json['second_choice_name'] as String? ?? '',
      applicationReference: json['application_reference'] as String? ?? '',
      proprietorsCount: (json['proprietors_count'] as num?)?.toInt() ?? 0,
      platform: json['platform'] as String?,
      currency: json['currency'] as String?,
      amount: json['amount']?.toString(),
      paidAt: json['paid_at'] != null
          ? DateTime.tryParse(json['paid_at'].toString())
          : null,
      adminNote: json['admin_note'] as String?,
    );
  }
}
