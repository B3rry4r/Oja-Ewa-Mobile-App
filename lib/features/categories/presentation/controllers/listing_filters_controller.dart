import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Business listing filters (within a category_slug context)
typedef BusinessListingFilters = ({String? state, String? city, String? sort});

class BusinessListingFiltersNotifier extends Notifier<BusinessListingFilters> {
  @override
  BusinessListingFilters build() => (state: null, city: null, sort: null);

  void setStateValue(String? v) => state = (state: v, city: state.city, sort: state.sort);
  void setCity(String? v) => state = (state: state.state, city: v, sort: state.sort);
  void setSort(String? v) => state = (state: state.state, city: state.city, sort: v);

  void clear() => state = (state: null, city: null, sort: null);
}

final businessListingFiltersProvider = NotifierProvider<BusinessListingFiltersNotifier, BusinessListingFilters>(
  BusinessListingFiltersNotifier.new,
);

/// Sustainability listing filters
typedef SustainabilityListingFilters = ({String? sort});

class SustainabilityListingFiltersNotifier extends Notifier<SustainabilityListingFilters> {
  @override
  SustainabilityListingFilters build() => (sort: null);

  void setSort(String? v) => state = (sort: v);
  void clear() => state = (sort: null);
}

final sustainabilityListingFiltersProvider = NotifierProvider<SustainabilityListingFiltersNotifier, SustainabilityListingFilters>(
  SustainabilityListingFiltersNotifier.new,
);
