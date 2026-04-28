import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/features/account/subfeatures/start_selling/domain/bank_option.dart';
import 'package:ojaewa/features/account/subfeatures/start_selling/presentation/controllers/bank_options_controller.dart';

class BankPickerSheet extends ConsumerStatefulWidget {
  const BankPickerSheet({
    super.key,
    required this.selectedBankCode,
    this.country = 'NG',
  });

  final String? selectedBankCode;
  final String country;

  static Future<BankOption?> show(
    BuildContext context, {
    String? selectedBankCode,
    String country = 'NG',
  }) {
    return showModalBottomSheet<BankOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: context.appColors.shadow.withValues(alpha: 0.82),
      builder: (context) => BankPickerSheet(
        selectedBankCode: selectedBankCode,
        country: country,
      ),
    );
  }

  @override
  ConsumerState<BankPickerSheet> createState() => _BankPickerSheetState();
}

class _BankPickerSheetState extends ConsumerState<BankPickerSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final banksAsync = ref.watch(bankOptionsProvider(widget.country));

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border(top: BorderSide(color: colors.border)),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.borderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Bank',
                    style: TextStyle(
                      fontFamily: 'Campton',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  HeaderIconButton(
                    asset: AppIcons.back,
                    iconColor: colors.textPrimary,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(color: colors.border, thickness: 0.5),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: _buildSearchField(context),
            ),
            Expanded(
              child: banksAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Failed to load banks',
                        style: TextStyle(color: colors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref.invalidate(
                          bankOptionsProvider(widget.country),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (banks) {
                  final filtered = _searchQuery.isEmpty
                      ? banks
                      : banks
                          .where(
                            (bank) =>
                                bank.name.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                ) ||
                                bank.code.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                ),
                          )
                          .toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'No banks found',
                        style: TextStyle(
                          fontFamily: 'Campton',
                          color: colors.textTertiary,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        Divider(color: colors.border),
                    itemBuilder: (context, index) {
                      final bank = filtered[index];
                      final isSelected = bank.code == widget.selectedBankCode;
                      return ListTile(
                        title: Text(
                          bank.name,
                          style: TextStyle(
                            fontFamily: 'Campton',
                            fontSize: 16,
                            color: colors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          bank.code,
                          style: TextStyle(color: colors.textTertiary),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check, color: colors.accent)
                            : null,
                        onTap: () => Navigator.of(context).pop(bank),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final colors = context.appColors;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.search, color: colors.textTertiary),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: TextStyle(
                fontFamily: 'Campton',
                fontSize: 16,
                color: colors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search bank...',
                hintStyle: TextStyle(
                  fontFamily: 'Campton',
                  color: colors.textTertiary,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: colors.textTertiary),
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            ),
        ],
      ),
    );
  }
}
