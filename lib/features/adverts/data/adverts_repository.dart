import '../domain/advert.dart';

abstract interface class AdvertsRepository {
  Future<List<Advert>> listAdverts({String? position, int page, int perPage});
  Future<Advert> getAdvert(int id);
}
