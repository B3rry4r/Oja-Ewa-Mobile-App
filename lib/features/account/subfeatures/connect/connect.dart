// connect_to_us_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/ui/ui_error_message.dart';

import 'domain/connect_info.dart';
import 'presentation/controllers/connect_controller.dart';

class ConnectToUsScreen extends ConsumerWidget {
  const ConnectToUsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(connectInfoProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              backgroundColor: Color(0xFFFFF8F1),
              iconColor: Color(0xFF241508),
              title: Text(
                'Connect to us',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Campton',
                  color: Color(0xFF241508),
                ),
              ),
            ),
            Expanded(
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
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildContactCard(context, data),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, ConnectInfo data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDEDEDE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Us',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontFamily: 'Campton',
              fontSize: 18,
              color: Color(0xFF241508),
            ),
          ),
          const SizedBox(height: 16),
          
          // Email
          if (data.email.isNotEmpty)
            _buildContactItem(
              icon: Icons.email_outlined,
              label: 'Email',
              value: data.email,
              onTap: () => _launchEmail(context, data.email),
            ),
          
          if (data.email.isNotEmpty) const SizedBox(height: 12),
          
          // Phone
          if (data.phone.isNotEmpty)
            _buildContactItem(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: data.phone,
              onTap: () => _launchPhone(context, data.phone),
            ),
          
          if (data.phone.isNotEmpty) const SizedBox(height: 12),
          
          // Instagram
          if (data.instagram.isNotEmpty)
            _buildContactItem(
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
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
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
                color: const Color(0xFFFFF8F1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF241508),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Campton',
                      fontSize: 12,
                      color: Color(0xFF777F84),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontFamily: 'Campton',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF241508),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF777F84),
            ),
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
