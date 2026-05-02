class AdvertPlacementRequest {
  const AdvertPlacementRequest({
    required this.id,
    required this.status,
    required this.title,
    required this.placement,
    required this.mediaType,
    required this.applicationReference,
    this.thumbnailUrl,
    this.startDate,
    this.endDate,
    this.displayCurrency,
    this.displayTotalAmount,
    this.adminNote,
  });

  final int id;
  final String status;
  final String title;
  final String placement;
  final String mediaType;
  final String applicationReference;
  final String? thumbnailUrl;
  final String? startDate;
  final String? endDate;
  final String? displayCurrency;
  final String? displayTotalAmount;
  final String? adminNote;

  factory AdvertPlacementRequest.fromJson(Map<String, dynamic> json) {
    return AdvertPlacementRequest(
      id: (json['id'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'submitted',
      title: json['title'] as String? ?? '',
      placement: json['placement'] as String? ?? '',
      mediaType: json['media_type'] as String? ?? '',
      applicationReference: json['application_reference'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      displayCurrency: json['display_currency'] as String?,
      displayTotalAmount: json['display_total_amount']?.toString(),
      adminNote: json['admin_note'] as String?,
    );
  }
}
