class NepcRegistrationRequest {
  const NepcRegistrationRequest({
    required this.id,
    required this.status,
    required this.applicationType,
    required this.businessType,
    required this.businessName,
    required this.registrationNumber,
    required this.applicationReference,
    this.currency,
    this.amount,
    this.certificateUrl,
    this.adminNote,
  });

  final int id;
  final String status;
  final String applicationType;
  final String businessType;
  final String businessName;
  final String registrationNumber;
  final String applicationReference;
  final String? currency;
  final String? amount;
  final String? certificateUrl;
  final String? adminNote;

  factory NepcRegistrationRequest.fromJson(Map<String, dynamic> json) {
    return NepcRegistrationRequest(
      id: (json['id'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'submitted',
      applicationType: json['application_type'] as String? ?? '',
      businessType: json['business_type'] as String? ?? '',
      businessName: json['business_name'] as String? ?? '',
      registrationNumber: json['registration_number'] as String? ?? '',
      applicationReference: json['application_reference'] as String? ?? '',
      currency: json['currency'] as String?,
      amount: json['amount']?.toString(),
      certificateUrl: json['certificate_url'] as String?,
      adminNote: json['admin_note'] as String?,
    );
  }
}
