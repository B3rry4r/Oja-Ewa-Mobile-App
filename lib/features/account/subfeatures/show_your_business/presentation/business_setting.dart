import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/features/account/subfeatures/show_your_business/presentation/controllers/business_status_controller.dart';
import 'package:ojaewa/features/account/subfeatures/show_your_business/domain/business_status.dart';

import '../../../../../app/router/app_router.dart';
import 'package:ojaewa/features/business_details/presentation/screens/business_details_screen.dart';

class BusinessSettingsScreen extends ConsumerWidget {
  const BusinessSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1), // Main background from IR
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeader(
                backgroundColor: Color(0xFFFFF8F1),
                iconColor: Color(0xFF241508),
              ),
              const SizedBox(height: 18),
              _buildTitleAndAddButton(context),
              const SizedBox(height: 16),
              _buildBusinessList(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  /// Title and "Add New Business" action
  Widget _buildTitleAndAddButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          const Text(
            "Your Business",
            style: TextStyle(
              fontSize: 33,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: Color(0xFF241508),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              // Add business should restart creation flow
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.businessCategory),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDAF40),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFDAF40).withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Text(
                  "Add New Business",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Campton',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// List of business items
  Widget _buildBusinessList(BuildContext context, WidgetRef ref) {
    final businessesAsync = ref.watch(myBusinessStatusesProvider);

    return businessesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Text('Failed to load businesses: $e'),
      ),
      data: (businesses) {
        if (businesses.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Text('No business profiles yet.'),
          );
        }

        return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: businesses.length,
      separatorBuilder: (_, __) => const Divider(color: Color(0xFFDEDEDE), height: 1),
      itemBuilder: (context, index) {
        final b = businesses[index];
        final status = b.storeStatus;
        final statusLabel = status.isEmpty ? '' : ' • $status';

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          onTap: () {
            // Open the business detail screen (public view) from management list
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BusinessDetailsScreen(businessId: b.id),
              ),
            );
          },
          title: Text(
            '${b.businessName}$statusLabel',
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E2021),
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.more_horiz, color: Color(0xFF1E2021)),
            onPressed: () => _showBusinessActions(context, b),
          ),
        );
      },
    );
      },
    );
  }

  /// Action Sheet inferred from response2.json
  void _showBusinessActions(BuildContext context, BusinessStatus business) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFF8F1),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pull handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              _buildModalOption(
                label: "Edit Business Information",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed(
                    AppRoutes.editBusiness,
                    arguments: {'businessId': business.id},
                  );
                },
              ),
              const Divider(color: Color(0xFFDEDEDE)),
              _buildModalOption(
                label: "Manage Payment",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed(
                    AppRoutes.managePayment,
                    arguments: {'businessId': business.id},
                  );
                },
              ),
              const Divider(color: Color(0xFFDEDEDE)),
              _buildModalOption(
                label: "Deactivate Shop",
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed(
                    AppRoutes.deactivateShop,
                    arguments: {'businessId': business.id},
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalOption({
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontFamily: 'Campton',
          fontWeight: FontWeight.w400,
          color: isDestructive ? Colors.red : const Color(0xFF1E2021),
        ),
      ),
      onTap: onTap,
    );
  }
}