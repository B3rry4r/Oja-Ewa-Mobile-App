// addresses_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/widgets/image_placeholder.dart';

import '../domain/address.dart';
import 'add_edit_address.dart';
import 'controllers/address_controller.dart';

class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final addresses = ref.watch(addressesProvider);

    return AppPageScaffold(
      title: 'Addresses',
      scrollable: true,
      child: addresses.when(
        loading: () => const Padding(
          padding: EdgeInsets.only(top: 48),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, st) => Padding(
          padding: const EdgeInsets.only(top: 48),
          child: Center(child: Text('Failed to load addresses.\n$e')),
        ),
        data: (items) {
          if (items.isEmpty) {
            return _buildEmptyState(context);
          }

          final defaultAddress = items.firstWhere(
            (a) => a.isDefault,
            orElse: () => items.first,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAddressCard(context, defaultAddress),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _buildAddAddressButton(context),
              ),
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
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, Address address) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(12),
        color: colors.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            address.fullName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${address.phone}\n${address.addressLine}, ${address.city}, ${address.state},\n${address.country} ${address.postCode}',
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(width: 48),
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.border),
                    color: address.isDefault
                        ? colors.accent
                        : Colors.transparent,
                  ),
                  child: address.isDefault
                      ? Icon(Icons.check, size: 16, color: colors.onAccent)
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.border),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  address.isDefault ? 'Default Address' : 'Address',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  final updated = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          AddEditAddressScreen(initialAddress: address),
                    ),
                  );

                  if (updated == true && context.mounted) {
                    // Pop back to order confirmation flow if needed.
                    final args = ModalRoute.of(context)?.settings.arguments;
                    final returnToOrderConfirmation =
                        args is Map && args['returnTo'] == 'orderConfirmation';
                    if (returnToOrderConfirmation) {
                      Navigator.of(context).pop(true);
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: colors.textSecondary,
                      ),
                      SizedBox(width: 9),
                      Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
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
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'No saved address',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add an address to make checkout faster.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          _buildAddAddressButton(context),
        ],
      ),
    );
  }

  Widget _buildAddAddressButton(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.accent,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () async {
            final updated = await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddEditAddressScreen()),
            );

            if (updated == true && context.mounted) {
              final args = ModalRoute.of(context)?.settings.arguments;
              final returnToOrderConfirmation =
                  args is Map && args['returnTo'] == 'orderConfirmation';
              if (returnToOrderConfirmation) Navigator.of(context).pop(true);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
            alignment: Alignment.center,
            child: Text(
              'Add New Address',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.onAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
