import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'location_api.dart';
import 'location_data.dart';

/// Provider for the location API
final locationApiProvider = Provider<LocationApi>((ref) {
  return LocationApi();
});

/// Provider that fetches African countries
final africanCountriesProvider = FutureProvider<List<Country>>((ref) async {
  final api = ref.watch(locationApiProvider);
  return api.fetchAfricanCountries();
});

/// Provider that fetches all countries
final allCountriesProvider = FutureProvider<List<Country>>((ref) async {
  final api = ref.watch(locationApiProvider);
  return api.fetchAllCountries();
});

/// Provider that fetches states for a given country name
final statesProvider = FutureProvider.family<List<StateProvince>, String>((ref, countryName) async {
  final api = ref.watch(locationApiProvider);
  return api.fetchStates(countryName);
});

/// Helper provider to get a country by its code
final countryByCodeProvider = Provider.family<Country?, String>((ref, code) {
  final countriesAsync = ref.watch(africanCountriesProvider);
  return countriesAsync.whenOrNull(
    data: (countries) => countries.where((c) => c.code == code).firstOrNull,
  );
});

/// Helper provider to get a country by its dial code
final countryByDialCodeProvider = Provider.family<Country?, String>((ref, dialCode) {
  final countriesAsync = ref.watch(africanCountriesProvider);
  return countriesAsync.whenOrNull(
    data: (countries) => countries.where((c) => c.dialCode == dialCode).firstOrNull,
  );
});
