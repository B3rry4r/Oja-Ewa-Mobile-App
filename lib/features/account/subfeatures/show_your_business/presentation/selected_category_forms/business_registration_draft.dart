/// Carries data collected across the multi-step "Show Your Business" flow.
///
/// This is UI-only for now (API wiring will come later).
class BusinessRegistrationDraft {
  BusinessRegistrationDraft({
    required this.categoryLabel,
    this.country,
    this.state,
    this.city,
    this.address,
    this.businessEmail,
    this.businessPhoneNumber,
    this.websiteUrl,
    this.instagram,
    this.facebook,
    this.youtube,
    this.spotify,
    this.identityDocumentPath,
  });

  /// The UI label coming from category picker (e.g. Beauty/Brands/Schools/Music).
  final String categoryLabel;

  String? country;
  String? state;
  String? city;
  String? address;

  String? businessEmail;
  String? businessPhoneNumber;

  String? websiteUrl;
  String? instagram;
  String? facebook;

  // Music fields (required: at least one of youtube/spotify when category=music)
  String? youtube;
  String? spotify;

  /// Placeholder until upload is implemented.
  String? identityDocumentPath;

  Map<String, dynamic> toJson() => {
        'categoryLabel': categoryLabel,
        'country': country,
        'state': state,
        'city': city,
        'address': address,
        'businessEmail': businessEmail,
        'businessPhoneNumber': businessPhoneNumber,
        'websiteUrl': websiteUrl,
        'instagram': instagram,
        'facebook': facebook,
        'youtube': youtube,
        'spotify': spotify,
        'identityDocumentPath': identityDocumentPath,
      };

  static BusinessRegistrationDraft fromJson(Map<String, dynamic> json) {
    return BusinessRegistrationDraft(
      categoryLabel: (json['categoryLabel'] as String?) ?? 'Beauty',
      country: json['country'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
      businessEmail: json['businessEmail'] as String?,
      businessPhoneNumber: json['businessPhoneNumber'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
      instagram: json['instagram'] as String?,
      facebook: json['facebook'] as String?,
      youtube: json['youtube'] as String?,
      spotify: json['spotify'] as String?,
      identityDocumentPath: json['identityDocumentPath'] as String?,
    );
  }
}
