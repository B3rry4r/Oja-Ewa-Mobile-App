import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../presentation/selected_category_forms/classes_offered_editor.dart';
import '../presentation/selected_category_forms/service_list_editor.dart';

@immutable
class BusinessProfilePayload {
  const BusinessProfilePayload({
    required this.category,
    required this.categoryId,
    required this.subcategoryId,
    required this.country,
    required this.state,
    required this.city,
    required this.address,
    required this.businessEmail,
    required this.businessPhoneNumber,
    required this.businessName,
    required this.businessDescription,
    this.websiteUrl,
    this.instagram,
    this.facebook,
    this.identityDocument,
    this.businessLogo,
    this.offeringType,
    this.productList,
    this.serviceList,
    this.businessCertificates,
    this.professionalTitle,
    this.schoolType,
    this.schoolBiography,
    this.classesOffered,
    this.musicCategory,
    this.youtube,
    this.spotify,
  });

  /// enum: school|art (per API validation - afro_beauty_services removed)
  final String category;

  final int categoryId;
  final int subcategoryId;

  final String country;
  final String state;
  final String city;
  final String address;

  final String businessEmail;
  final String businessPhoneNumber;

  final String businessName;
  final String businessDescription;

  final String? websiteUrl;
  final String? instagram;
  final String? facebook;

  /// Remote URLs returned by upload endpoint (NOT local file paths).
  /// Local file paths are uploaded separately after business creation.
  final String? identityDocument;
  final String? businessLogo;

  /// enum: selling_product|providing_service
  final String? offeringType;

  /// Canonical JSON (confirmed): array of strings
  final List<String>? productList;

  /// Canonical JSON (confirmed): array of objects
  final List<ServiceListItem>? serviceList;

  /// Canonical JSON (confirmed): array of {name,url}
  final List<Map<String, dynamic>>? businessCertificates;

  final String? professionalTitle;

  /// school only
  final String? schoolType;
  final String? schoolBiography;
  final List<ClassOfferedItem>? classesOffered;

  /// music only
  final String? musicCategory; // dj|artist|producer
  final String? youtube;
  final String? spotify;

  /// Converts payload to JSON for POST /api/business.
  /// Note: identity_document, business_logo, and business_certificates are NOT included here.
  /// They are uploaded separately via POST /api/business/{id}/upload after creation.
  /// 
  /// IMPORTANT: The API expects certain list fields (product_list, service_list, 
  /// classes_offered, business_certificates) to be JSON-encoded strings, not native arrays.
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'category_id': categoryId,
      'subcategory_id': subcategoryId,
      'country': country,
      'state': state,
      'city': city,
      'address': address,
      'business_email': businessEmail,
      'business_phone_number': businessPhoneNumber,
      if (websiteUrl != null && websiteUrl!.isNotEmpty) 'website_url': websiteUrl,
      if (instagram != null && instagram!.isNotEmpty) 'instagram': instagram,
      if (facebook != null && facebook!.isNotEmpty) 'facebook': facebook,
      // identity_document, business_logo, business_certificates: uploaded separately after creation
      if (businessName.isNotEmpty) 'business_name': businessName,
      if (businessDescription.isNotEmpty) 'business_description': businessDescription,
      if (offeringType != null && offeringType!.isNotEmpty) 'offering_type': offeringType,
      // API requires these list fields as JSON-encoded strings
      if (productList != null && productList!.isNotEmpty) 
        'product_list': jsonEncode(productList),
      if (serviceList != null && serviceList!.isNotEmpty) 
        'service_list': jsonEncode(serviceList!.map((e) => e.toJson()).toList()),
      if (professionalTitle != null && professionalTitle!.isNotEmpty) 'professional_title': professionalTitle,
      if (schoolType != null && schoolType!.isNotEmpty) 'school_type': schoolType,
      if (schoolBiography != null && schoolBiography!.isNotEmpty) 'school_biography': schoolBiography,
      if (classesOffered != null && classesOffered!.isNotEmpty) 
        'classes_offered': jsonEncode(classesOffered!.map((e) => e.toJson()).toList()),
      if (musicCategory != null && musicCategory!.isNotEmpty) 'music_category': musicCategory,
      if (youtube != null && youtube!.isNotEmpty) 'youtube': youtube,
      if (spotify != null && spotify!.isNotEmpty) 'spotify': spotify,
    };
  }
}
