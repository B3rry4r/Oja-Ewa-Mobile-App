/// Carries data collected across the multi-step "Show Your Business" flow.
///
/// This is UI-only for now (API wiring will come later).
import 'service_list_editor.dart';
import 'classes_offered_editor.dart';

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

    // Step 2 fields
    this.businessName,
    this.businessDescription,
    this.offeringType,
    this.productListText,
    this.professionalTitle,
    this.serviceList,
    this.schoolType,
    this.schoolBiography,
    this.classesOffered,
    this.musicCategory,
    this.businessLogoPath,
    this.businessCertificates,
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

  // Step 2 common
  String? businessName;
  String? businessDescription;

  /// backend enum: selling_product|providing_service
  String? offeringType;

  /// UI free-text list; will be converted to canonical JSON on submit
  String? productListText;

  /// providing_service
  String? professionalTitle;
  List<ServiceListItem>? serviceList;

  /// school
  String? schoolType;
  String? schoolBiography;
  List<ClassOfferedItem>? classesOffered;

  /// music
  String? musicCategory; // dj|artist|producer

  /// uploads placeholders
  String? businessLogoPath;
  List<Map<String, dynamic>>? businessCertificates;

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
        'businessName': businessName,
        'businessDescription': businessDescription,
        'offeringType': offeringType,
        'productListText': productListText,
        'professionalTitle': professionalTitle,
        'serviceList': serviceList?.map((e) => e.toJson()).toList(),
        'schoolType': schoolType,
        'schoolBiography': schoolBiography,
        'classesOffered': classesOffered?.map((e) => e.toJson()).toList(),
        'musicCategory': musicCategory,
        'businessLogoPath': businessLogoPath,
        'businessCertificates': businessCertificates,
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
      businessName: json['businessName'] as String?,
      businessDescription: json['businessDescription'] as String?,
      offeringType: json['offeringType'] as String?,
      productListText: json['productListText'] as String?,
      professionalTitle: json['professionalTitle'] as String?,
      serviceList: (json['serviceList'] is List)
          ? (json['serviceList'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => ServiceListItem(
                    name: (e['name'] as String?) ?? '',
                    priceRange: (e['price_range'] as String?) ?? '',
                  ))
              .toList()
          : null,
      schoolType: json['schoolType'] as String?,
      schoolBiography: json['schoolBiography'] as String?,
      classesOffered: (json['classesOffered'] is List)
          ? (json['classesOffered'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => ClassOfferedItem(
                    name: (e['name'] as String?) ?? '',
                    duration: (e['duration'] as String?) ?? '',
                  ))
              .toList()
          : null,
      musicCategory: json['musicCategory'] as String?,
      businessLogoPath: json['businessLogoPath'] as String?,
      businessCertificates: (json['businessCertificates'] is List)
          ? (json['businessCertificates'] as List).whereType<Map<String, dynamic>>().toList()
          : null,
    );
  }
}
