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

  /// ISO2 codes of African countries (for the Africa-only picker).
  static const _africanIso2 = <String>{
    'DZ', 'AO', 'BJ', 'BW', 'BF', 'BI', 'CV', 'CM', 'CF', 'TD', 'KM', 'CG', 'CD', 'CI', 'DJ', 'EG',
    'GQ', 'ER', 'SZ', 'ET', 'GA', 'GM', 'GH', 'GN', 'GW', 'KE', 'LS', 'LR', 'LY', 'MG', 'MW', 'ML',
    'MR', 'MU', 'MA', 'MZ', 'NA', 'NE', 'NG', 'RW', 'ST', 'SN', 'SC', 'SL', 'SO', 'ZA', 'SS', 'SD',
    'TZ', 'TG', 'TN', 'UG', 'ZM', 'ZW',
  };

  /// Fetches African countries with their dial codes.
  Future<List<Country>> fetchAfricanCountries() async {
    final all = await _fetchCountryCodes();
    final african = all.where((c) => _africanIso2.contains(c.code.toUpperCase())).toList();
    african.sort((a, b) => a.name.compareTo(b.name));
    // Safety: never hand back an empty list if the filter matched nothing.
    return african.isNotEmpty ? african : all;
  }

  /// Fetches all countries with their dial codes.
  Future<List<Country>> fetchAllCountries() async {
    final all = await _fetchCountryCodes();
    all.sort((a, b) => a.name.compareTo(b.name));
    return all;
  }

  /// Country name + ISO2 + dial code from CountriesNow. (REST Countries v3.1 was
  /// deprecated — it now 301-redirects to a "version deprecated" error, which is
  /// why the country-code list stopped loading.) The flag emoji is derived from
  /// the ISO2 code, so we don't depend on the provider returning one.
  Future<List<Country>> _fetchCountryCodes() async {
    try {
      final response = await _dio.get('https://countriesnow.space/api/v0.1/countries/codes');
      final data = (response.data is Map ? response.data['data'] : null) as List<dynamic>? ?? [];
      final countries = <Country>[];

      for (final item in data) {
        if (item is! Map) continue;
        final name = item['name'] as String?;
        final code = item['code'] as String?;
        final dialCode = (item['dial_code'] as String?)?.trim() ?? '';

        if (name != null && code != null && code.length == 2 && dialCode.isNotEmpty) {
          countries.add(Country(
            name: name,
            code: code,
            dialCode: dialCode,
            flag: _flagEmoji(code),
          ));
        }
      }

      return countries;
    } catch (e) {
      throw Exception('Failed to fetch countries: $e');
    }
  }

  /// Turn an ISO2 country code (e.g. "NG") into its flag emoji (🇳🇬).
  String _flagEmoji(String code) {
    final c = code.toUpperCase();
    if (c.length != 2) return '';
    final a = c.codeUnitAt(0);
    final b = c.codeUnitAt(1);
    if (a < 65 || a > 90 || b < 65 || b > 90) return '';
    return String.fromCharCode(0x1F1E6 + a - 65) + String.fromCharCode(0x1F1E6 + b - 65);
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

  /// Fetches cities for a given country and state
  /// Uses CountriesNow API
  Future<List<String>> fetchCities(String countryName, String stateName) async {
    try {
      // CountriesNow expects the state name without " State" suffix for some endpoints
      final cleanState = stateName.replaceAll(' State', '');
      
      final response = await _dio.post(
        'https://countriesnow.space/api/v0.1/countries/state/cities',
        data: {
          'country': countryName,
          'state': cleanState,
        },
      );

      final data = response.data as Map<String, dynamic>;
      if (data['error'] == true) {
        return [];
      }

      final List<dynamic> citiesData = data['data'] ?? [];
      final cities = citiesData.map((e) => e.toString()).toList();

      // Sort alphabetically
      cities.sort();

      return cities;
    } catch (e) {
      // Fallback: if post fails, try get with query params
      try {
        final response = await _dio.get(
          'https://countriesnow.space/api/v0.1/countries/state/cities/q',
          queryParameters: {
            'country': countryName,
            'state': stateName,
          },
        );
        final data = response.data as Map<String, dynamic>;
        if (data['error'] == true) return [];
        final List<dynamic> citiesData = data['data'] ?? [];
        final cities = citiesData.map((e) => e.toString()).toList();
        cities.sort();
        return cities;
      } catch (_) {
        throw Exception('Failed to fetch cities for $stateName, $countryName: $e');
      }
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
