import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/adverts_repository_impl.dart';
import '../../domain/advert.dart';

final advertsByPositionProvider = FutureProvider.family<List<Advert>, String?>((ref, position) async {
  return ref.watch(advertsRepositoryProvider).listAdverts(position: position, page: 1, perPage: 10);
});
