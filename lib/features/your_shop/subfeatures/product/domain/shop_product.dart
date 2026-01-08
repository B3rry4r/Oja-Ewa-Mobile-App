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
}
