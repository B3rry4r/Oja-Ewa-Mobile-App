/// Carries data collected across the multi-step "Show Your Business" flow.
///
/// UI-only draft + local file paths; mapped to API payload on submit.
import 'service_list_editor.dart';
import 'classes_offered_editor.dart';

class BusinessRegistrationDraft {
  BusinessRegistrationDraft({
    required this.categoryLabel,
  });

  /// The UI label coming from category picker (e.g. Beauty/Brands/Schools/Music).
  final String categoryLabel;

  /// Backend categorization (from /api/categories/all)
  int? categoryId;
  int? subcategoryId;

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

  /// Local file path
  String? identityDocumentPath;

  // Step 2 common
  String? businessName;
  String? businessDescription;

  /// backend enum: selling_product|providing_service
  String? offeringType;

  /// List of product names for selling_product offering type
  List<String>? productList;

  /// providing_service
  String? professionalTitle;
  List<ServiceListItem>? serviceList;

  /// school
  String? schoolType;
  String? schoolBiography;
  List<ClassOfferedItem>? classesOffered;

  /// music
  String? musicCategory; // dj|artist|producer

  /// uploads local paths
  String? businessLogoPath;
  List<Map<String, dynamic>>? businessCertificates;

  Map<String, dynamic> toJson() => {
        'categoryLabel': categoryLabel,
        'categoryId': categoryId,
        'subcategoryId': subcategoryId,
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
        'productList': productList,
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
    final draft = BusinessRegistrationDraft(
      categoryLabel: (json['categoryLabel'] as String?) ?? 'Beauty',
    );

    draft.categoryId = (json['categoryId'] as num?)?.toInt();
    draft.subcategoryId = (json['subcategoryId'] as num?)?.toInt();

    draft.country = json['country'] as String?;
    draft.state = json['state'] as String?;
    draft.city = json['city'] as String?;
    draft.address = json['address'] as String?;

    draft.businessEmail = json['businessEmail'] as String?;
    draft.businessPhoneNumber = json['businessPhoneNumber'] as String?;

    draft.websiteUrl = json['websiteUrl'] as String?;
    draft.instagram = json['instagram'] as String?;
    draft.facebook = json['facebook'] as String?;

    draft.youtube = json['youtube'] as String?;
    draft.spotify = json['spotify'] as String?;

    draft.identityDocumentPath = json['identityDocumentPath'] as String?;

    draft.businessName = json['businessName'] as String?;
    draft.businessDescription = json['businessDescription'] as String?;

    draft.offeringType = json['offeringType'] as String?;
    draft.productList = (json['productList'] is List)
        ? (json['productList'] as List).whereType<String>().toList()
        : null;

    draft.professionalTitle = json['professionalTitle'] as String?;
    draft.serviceList = (json['serviceList'] is List)
        ? (json['serviceList'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => ServiceListItem(
                  name: (e['name'] as String?) ?? '',
                  priceRange: (e['price_range'] as String?) ?? '',
                ))
            .toList()
        : null;

    draft.schoolType = json['schoolType'] as String?;
    draft.schoolBiography = json['schoolBiography'] as String?;
    draft.classesOffered = (json['classesOffered'] is List)
        ? (json['classesOffered'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => ClassOfferedItem(
                  name: (e['name'] as String?) ?? '',
                  duration: (e['duration'] as String?) ?? '',
                ))
            .toList()
        : null;

    draft.musicCategory = json['musicCategory'] as String?;
    draft.businessLogoPath = json['businessLogoPath'] as String?;
    draft.businessCertificates = (json['businessCertificates'] is List)
        ? (json['businessCertificates'] as List)
            .whereType<Map<String, dynamic>>()
            .toList()
        : null;

    return draft;
  }
}
