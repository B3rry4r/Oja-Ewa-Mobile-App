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

          // Show default address(es) first, keeping all addresses visible.
          final sorted = [...items]
            ..sort((a, b) => (b.isDefault ? 1 : 0) - (a.isDefault ? 1 : 0));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: sorted.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (_, index) =>
                    _buildAddressCard(context, ref, sorted[index]),
              ),
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

  Widget _buildAddressCard(
    BuildContext context,
    WidgetRef ref,
    Address address,
  ) {
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                        final returnToOrderConfirmation = args is Map &&
                            args['returnTo'] == 'orderConfirmation';
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
                  InkWell(
                    onTap: () => _confirmDelete(context, ref, address),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 9),
                          const Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.redAccent,
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
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Address address,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete address?'),
        content: Text(
          'Are you sure you want to delete the address for ${address.fullName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final success =
        await ref.read(addressActionsProvider.notifier).delete(address.id);

    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    if (success) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Address deleted.')));
    } else {
      final error = ref.read(addressActionsProvider).error;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              'Could not delete address. ${error ?? 'Please try again.'}',
            ),
          ),
        );
    }
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
