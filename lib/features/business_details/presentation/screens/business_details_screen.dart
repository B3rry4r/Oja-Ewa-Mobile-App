import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
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
    final colors = context.appColors;

    if (!isLoggedIn) {
      return AppPageScaffold(
        title: 'Business',
        showActions: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 48, color: colors.textTertiary),
              const SizedBox(height: 16),
              Text(
                'Sign in to view business profiles',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create an account to access full business details.',
                style: TextStyle(
                  fontSize: 13,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.signIn),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accent,
                  foregroundColor: colors.onAccent,
                ),
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    return AppPageScaffold(
      title: 'Business',
      showActions: false,
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Failed to load business')),
        data: (b) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                b.businessName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              if ((b.businessDescription ?? '').trim().isNotEmpty)
                Text(b.businessDescription!),
              const SizedBox(height: 16),
              if (b.serviceList.isNotEmpty) ...[
                const Text(
                  'Services',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: b.serviceList
                      .map((s) => Chip(label: Text(s.name)))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
