class BadgeOption {
  const BadgeOption({
    required this.key,
    required this.name,
    required this.displayName,
    required this.priceNgn,
    required this.billingCycle,
    required this.requiresBadges,
    required this.requirements,
  });

  final String key;
  final String name;
  final String displayName;
  final num priceNgn;
  final String billingCycle;
  final List<String> requiresBadges;
  final List<String> requirements;

  factory BadgeOption.fromJson(Map<String, dynamic> json) {
    return BadgeOption(
      key: json['key'] as String? ?? '',
      name: json['name'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      priceNgn: (json['price_ngn'] as num?) ?? 0,
      billingCycle: json['billing_cycle'] as String? ?? '',
      requiresBadges: (json['requires_badges'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      requirements: (json['requirements'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
