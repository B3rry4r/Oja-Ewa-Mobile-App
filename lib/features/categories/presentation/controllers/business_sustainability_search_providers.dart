import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/core/network/dio_clients.dart';
import 'package:ojaewa/features/business_details/data/business_search_api.dart';
import 'package:ojaewa/features/sustainability_details/data/sustainability_search_api.dart';
import 'package:ojaewa/features/categories/presentation/controllers/listing_filters_controller.dart';
import 'package:ojaewa/features/categories/domain/category_items.dart';

final businessSearchApiProvider = Provider<BusinessSearchApi>((ref) {
  final dio = ref.watch(laravelDioProvider);
  return BusinessSearchApi(dio);
});

final sustainabilitySearchApiProvider = Provider<SustainabilitySearchApi>((ref) {
  final dio = ref.watch(laravelDioProvider);
  return SustainabilitySearchApi(dio);
});

typedef CategorySlugArg = ({String slug});

final filteredBusinessesByCategoryProvider = FutureProvider.family<List<CategoryBusinessItem>, CategorySlugArg>((ref, arg) async {
  final f = ref.watch(businessListingFiltersProvider);
  final api = ref.watch(businessSearchApiProvider);

  final res = await api.search(
    q: '',
    categorySlug: arg.slug,
    state: f.state,
    city: f.city,
    sort: f.sort,
    page: 1,
    perPage: 30,
  );

  final list = res['data'];
  if (list is List) {
    return list.whereType<Map<String, dynamic>>().map(CategoryBusinessItem.fromJson).toList();
  }
  return const [];
});

final filteredSustainabilityByCategoryProvider = FutureProvider.family<List<CategoryInitiativeItem>, CategorySlugArg>((ref, arg) async {
  final f = ref.watch(sustainabilityListingFiltersProvider);
  final api = ref.watch(sustainabilitySearchApiProvider);

  final res = await api.search(
    q: '',
    categorySlug: arg.slug,
    sort: f.sort,
    page: 1,
    perPage: 30,
  );

  final list = res['data'];
  if (list is List) {
    return list.whereType<Map<String, dynamic>>().map(CategoryInitiativeItem.fromJson).toList();
  }
  return const [];
});
