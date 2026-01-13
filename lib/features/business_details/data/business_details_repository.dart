abstract interface class BusinessDetailsRepository {
  Future<Map<String, dynamic>> getBusiness(int id);
}
