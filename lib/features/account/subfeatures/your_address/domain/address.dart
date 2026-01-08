class Address {
  const Address({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.country,
    required this.state,
    required this.city,
    required this.postCode,
    required this.addressLine,
    this.isDefault = false,
  });

  final String id;
  final String fullName;
  final String phone;
  final String country;
  final String state;
  final String city;
  final String postCode;
  final String addressLine;
  final bool isDefault;
}
