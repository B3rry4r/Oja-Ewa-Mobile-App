import 'package:dio/dio.dart';

import 'location_data.dart';

/// API service for fetching countries and states data
class LocationApi {
  LocationApi() : _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    followRedirects: true,
    maxRedirects: 5,
  ));

  final Dio _dio;

  /// Fetches list of African countries with their details
  /// Uses REST Countries API
  Future<List<Country>> fetchAfricanCountries() async {
    try {
      final response = await _dio.get(
        'https://restcountries.com/v3.1/region/africa',
        queryParameters: {
          'fields': 'name,cca2,idd,flag',
        },
      );

      final List<dynamic> data = response.data;
      final countries = <Country>[];

      for (final item in data) {
        final name = item['name']?['common'] as String?;
        final code = item['cca2'] as String?;
        final flag = item['flag'] as String? ?? '';
        
        // Extract dial code
        final idd = item['idd'] as Map<String, dynamic>?;
        final root = idd?['root'] as String? ?? '';
        final suffixes = idd?['suffixes'] as List<dynamic>? ?? [];
        final suffix = suffixes.isNotEmpty ? suffixes.first as String : '';
        final dialCode = '$root$suffix';

        if (name != null && code != null && dialCode.isNotEmpty) {
          countries.add(Country(
            name: name,
            code: code,
            dialCode: dialCode,
            flag: flag,
          ));
        }
      }

      // Sort alphabetically by name
      countries.sort((a, b) => a.name.compareTo(b.name));

      return countries;
    } catch (e) {
      throw Exception('Failed to fetch countries: $e');
    }
  }

  /// Fetches all countries (not just Africa) for broader support
  Future<List<Country>> fetchAllCountries() async {
    try {
      final response = await _dio.get(
        'https://restcountries.com/v3.1/all',
        queryParameters: {
          'fields': 'name,cca2,idd,flag',
        },
      );

      final List<dynamic> data = response.data;
      final countries = <Country>[];

      for (final item in data) {
        final name = item['name']?['common'] as String?;
        final code = item['cca2'] as String?;
        final flag = item['flag'] as String? ?? '';
        
        // Extract dial code
        final idd = item['idd'] as Map<String, dynamic>?;
        final root = idd?['root'] as String? ?? '';
        final suffixes = idd?['suffixes'] as List<dynamic>? ?? [];
        final suffix = suffixes.isNotEmpty ? suffixes.first as String : '';
        final dialCode = '$root$suffix';

        if (name != null && code != null && dialCode.isNotEmpty) {
          countries.add(Country(
            name: name,
            code: code,
            dialCode: dialCode,
            flag: flag,
          ));
        }
      }

      // Sort alphabetically by name
      countries.sort((a, b) => a.name.compareTo(b.name));

      return countries;
    } catch (e) {
      throw Exception('Failed to fetch countries: $e');
    }
  }

  /// Fetches states/provinces for a given country
  /// Uses CountriesNow API (GET endpoint for better reliability)
  Future<List<StateProvince>> fetchStates(String countryName) async {
    try {
      final response = await _dio.get(
        'https://countriesnow.space/api/v0.1/countries/states/q',
        queryParameters: {'country': countryName},
      );

      final data = response.data as Map<String, dynamic>;
      if (data['error'] == true) {
        return [];
      }

      final statesData = data['data']?['states'] as List<dynamic>? ?? [];
      final countryCode = _getCountryCode(countryName);

      final states = statesData.map((item) {
        final name = item['name'] as String? ?? '';
        final code = item['state_code'] as String? ?? name;
        return StateProvince(
          name: name,
          code: code,
          countryCode: countryCode,
        );
      }).toList();

      // Sort alphabetically
      states.sort((a, b) => a.name.compareTo(b.name));

      return states;
    } catch (e) {
      throw Exception('Failed to fetch states for $countryName: $e');
    }
  }

  /// Helper to get country code from name (basic mapping for common countries)
  String _getCountryCode(String countryName) {
    final mapping = {
      'Nigeria': 'NG',
      'Ghana': 'GH',
      'Kenya': 'KE',
      'South Africa': 'ZA',
      'Egypt': 'EG',
      'Morocco': 'MA',
      'Ethiopia': 'ET',
      'Tanzania': 'TZ',
      'Uganda': 'UG',
      'Cameroon': 'CM',
    };
    return mapping[countryName] ?? countryName.substring(0, 2).toUpperCase();
  }
}
