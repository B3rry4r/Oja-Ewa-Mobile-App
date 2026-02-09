class ShopProduct {
  const ShopProduct({
    required this.id,
    required this.name,
    required this.status,
    required this.gender,
    required this.style,
    required this.tribe,
    required this.description,
    required this.sizes,
    required this.normalDays,
    required this.normalPrice,
    required this.quickDays,
    required this.quickPrice,
  });

  final String id;
  final String name;
  final String status;

  // Fields used by the add/edit form
  final String gender;
  final String style;
  final String tribe;
  final String description;
  final List<String> sizes;

  final String normalDays;
  final String normalPrice;
  final String quickDays;
  final String quickPrice;

  factory ShopProduct.fromJson(Map<String, dynamic> json) {
    // Handle both "sizes" (array) and "size" (single value) from API
    final sizesRaw = json['sizes'] ?? json['size'];
    final sizes = sizesRaw is List 
        ? sizesRaw.map((e) => e.toString()).toList() 
        : sizesRaw != null 
            ? [sizesRaw.toString()] 
            : <String>[];
    
    // Get status and capitalize first letter for filter matching
    final rawStatus = (json['status'] as String?) ?? (json['approval_status'] as String?) ?? 'pending';
    final status = rawStatus.isEmpty 
        ? 'Pending' 
        : rawStatus[0].toUpperCase() + rawStatus.substring(1).toLowerCase();

    return ShopProduct(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] as String?) ?? '',
      status: status, // Now properly capitalized (approved → Approved)
      gender: (json['gender'] as String?) ?? '',
      style: (json['style'] as String?) ?? '',
      tribe: (json['tribe'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      sizes: sizes,
      normalDays: (json['processing_days'] ?? '').toString(),
      normalPrice: (json['price'] ?? '').toString(),
      quickDays: '',
      quickPrice: '',
    );
  }
}
