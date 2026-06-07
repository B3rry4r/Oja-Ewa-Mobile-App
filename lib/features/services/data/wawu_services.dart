import 'package:flutter/material.dart';

/// A single WAWUAfrica service entry surfaced in the Services tab.
class WawuService {
  const WawuService({
    required this.label,
    required this.path,
    required this.icon,
    this.soon = false,
  });

  final String label;
  final String path;
  final IconData icon;
  final bool soon;
}

/// Every WAWUAfrica service surfaced from WAWUBeauty. The `path` values are
/// hub deep-links appended to `wawuAfricaHubUrl`; keep them unchanged so
/// existing WAWUAfrica deep links keep working.
const List<WawuService> wawuServices = [
  WawuService(
    label: 'EasyBuy',
    path: '/services/easybuy/apply',
    icon: Icons.shopping_bag_outlined,
  ),
  WawuService(
    label: 'Health Insurance',
    path: '/services/insurance',
    icon: Icons.health_and_safety_outlined,
    soon: true,
  ),
  WawuService(
    label: 'Pension',
    path: '/services/pension',
    icon: Icons.savings_outlined,
    soon: true,
  ),
  WawuService(
    label: 'Banking',
    path: '/services/banking',
    icon: Icons.account_balance_outlined,
    soon: true,
  ),
  WawuService(
    label: 'Grants & Funding',
    path: '/services/grants',
    icon: Icons.volunteer_activism_outlined,
    soon: true,
  ),
  WawuService(
    label: 'CAC Registration',
    path: '/services/cac-registration/apply',
    icon: Icons.assignment_outlined,
  ),
  WawuService(
    label: 'NEPC Registration',
    path: '/services/nepc-registration/apply',
    icon: Icons.public_outlined,
  ),
  WawuService(
    label: 'Mentorship',
    path: '/services/mentors',
    icon: Icons.diversity_3_outlined,
  ),
];
