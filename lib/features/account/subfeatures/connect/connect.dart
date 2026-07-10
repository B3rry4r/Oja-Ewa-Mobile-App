// connect_to_us_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/ui/ui_error_message.dart';

import 'domain/connect_info.dart';
import 'presentation/controllers/connect_controller.dart';

class ConnectToUsScreen extends ConsumerWidget {
  const ConnectToUsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final info = ref.watch(connectInfoProvider);

    return AppPageScaffold(
      // Body is a ListView/GridView: it needs a bounded height and scrolls itself.
      scrollable: false,
      title: 'Connect to us',
      child: info.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AppSnackbars.showError(context, UiErrorMessage.from(e));
          });
          return Center(
            child: ElevatedButton(
              onPressed: () => ref.invalidate(connectInfoProvider),
              child: const Text('Retry'),
            ),
          );
        },
        data: (data) {
          return ListView(
            padding: const EdgeInsets.all(0),
            children: [_buildContactCard(context, data)],
          );
        },
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, ConnectInfo data) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Us',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Email
          if (data.email.isNotEmpty)
            _buildContactItem(
              context: context,
              icon: Icons.email_outlined,
              label: 'Email',
              value: data.email,
              onTap: () => _launchEmail(context, data.email),
            ),

          if (data.email.isNotEmpty) const SizedBox(height: 12),

          // Phone
          if (data.phone.isNotEmpty)
            _buildContactItem(
              context: context,
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: data.phone,
              onTap: () => _launchPhone(context, data.phone),
            ),

          if (data.phone.isNotEmpty) const SizedBox(height: 12),

          // Instagram
          if (data.instagram.isNotEmpty)
            _buildContactItem(
              context: context,
              icon: Icons.camera_alt_outlined,
              label: 'Instagram',
              value: '@ojaewa',
              onTap: () => _launchUrl(context, data.instagram),
            ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colors.textPrimary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: colors.textTertiary),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail(BuildContext context, String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        AppSnackbars.showError(context, 'Could not open email app');
      }
    }
  }

  Future<void> _launchPhone(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        AppSnackbars.showError(context, 'Could not open phone app');
      }
    }
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        AppSnackbars.showError(context, 'Could not open link');
      }
    }
  }
}
