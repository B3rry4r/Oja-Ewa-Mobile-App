import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/core/auth/auth_providers.dart';
import '../controllers/business_details_controller.dart';

/// Minimal business details screen that can be used by category listings.
///
/// UI is intentionally simple to avoid redesigning existing category-specific
/// detail screens. We can later map fields into the dedicated Beauty/Music/etc
/// detail UIs as needed.
class BusinessDetailsScreen extends ConsumerWidget {
  const BusinessDetailsScreen({super.key, required this.businessId});

  final int businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(businessDetailsProvider(businessId));
    final token = ref.watch(accessTokenProvider);
    final isLoggedIn = token != null && token.isNotEmpty;

    if (!isLoggedIn) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF8F1),
        appBar: AppBar(
          backgroundColor: const Color(0xFF603814),
          foregroundColor: Colors.white,
          title: const Text('Business'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 48, color: Color(0xFF777F84)),
              const SizedBox(height: 16),
              const Text(
                'Sign in to view business profiles',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF241508),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create an account to access full business details.',
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Campton',
                  color: const Color(0xFF241508).withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.signIn),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFDAF40),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF603814),
        foregroundColor: Colors.white,
        title: const Text('Business'),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Failed to load business')),
        data: (b) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(b.businessName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              if ((b.businessDescription ?? '').trim().isNotEmpty) Text(b.businessDescription!),
              const SizedBox(height: 16),
              if (b.serviceList.isNotEmpty) ...[
                const Text('Services', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: b.serviceList.map((s) => Chip(label: Text(s.name))).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
