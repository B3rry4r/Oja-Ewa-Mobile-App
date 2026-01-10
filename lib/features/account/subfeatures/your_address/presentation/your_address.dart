// addresses_screen.dart
import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/widgets/image_placeholder.dart';

import '../data/mock_addresses.dart';
import '../domain/address.dart';
import 'add_edit_address.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock state for now.
    final addresses = mockAddresses;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              backgroundColor: const Color(0xFFFFF8F1),
              iconColor: const Color(0xFF241508),
              title: const Text(
                'Addresses',
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF241508),
                ),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (addresses.isEmpty) ...[
                      _buildEmptyState(context),
                    ] else ...[
                      // Address Card (current design)
                      _buildAddressCard(context, addresses.first),
                      const SizedBox(height: 40),

                      // Add New Address Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: _buildAddAddressButton(context),
                      ),

                      // Decorative background (placeholder until asset exists)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Opacity(
                          opacity: 0.03,
                          child: const AppImagePlaceholder(
                            width: 234,
                            height: 347,
                            borderRadius: 0,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ),

                      // Summary section at bottom
                      _buildSummarySection(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, Address address) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCCCCC)),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          Text(
            address.fullName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Campton',
              color: Color(0xFF1E2021),
            ),
          ),
          const SizedBox(height: 28),

          // Address and phone number with edit icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Address text
              Expanded(
                child: Text(
                  '${address.phone}\n${address.addressLine}, ${address.city}, ${address.state},\n${address.country} ${address.postCode}',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Campton',
                    color: const Color(0xFF3C4042),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(width: 48),

              // Default/selected indicator (not an edit icon)
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFCCCCCC)),
                    color: address.isDefault ? const Color(0xFFFDAF40) : Colors.transparent,
                  ),
                  child: address.isDefault
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Default address tag and edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Default address tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFCCCCCC)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Default Address',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Campton',
                    color: Color(0xFF3C4042),
                  ),
                ),
              ),

              // Edit button with icon
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          AddEditAddressScreen(initialAddress: address),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: Color(0xFF3C4042),
                      ),
                      const SizedBox(width: 9),
                      Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Campton',
                          color: const Color(0xFF3C4042),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            'No saved address',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: Color(0xFF241508),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add an address to make checkout faster.',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w400,
              color: Color(0xFF777F84),
            ),
          ),
          const SizedBox(height: 24),
          _buildAddAddressButton(context),
        ],
      ),
    );
  }

  Widget _buildAddAddressButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDAF40),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFDAF40).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddEditAddressScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
            alignment: Alignment.center,
            child: const Text(
              'Add New Address',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      color: const Color(0xFF603814), // Dark brown background
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Delivery text (IR shows position at top: 806)
          const Text(
            'Delivery',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w500,
              color: Color(0xFFFBFBFB),
            ),
          ),
          const SizedBox(height: 60), // Spacing between Delivery and Total
          // Total row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFFBFBFB),
                ),
              ),

              Text(
                'N44,000',
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFBFBFB),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
