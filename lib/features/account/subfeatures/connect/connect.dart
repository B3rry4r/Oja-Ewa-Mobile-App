// connect_to_us_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/ui/ui_error_message.dart';

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
                      _section('Social', data.socialLinks),
                      const SizedBox(height: 12),
                      _section('Contact', data.contact),
                      const SizedBox(height: 12),
                      _section('App links', data.appLinks),
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

  Widget _section(String title, Map<String, String> items) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDEDEDE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Campton'),
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const Text(
              'No data',
              style: TextStyle(
                fontFamily: 'Campton',
                color: Color(0xFF777F84),
              ),
            )
          else
            for (final entry in items.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontFamily: 'Campton',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF241508),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          fontFamily: 'Campton',
                          color: Color(0xFF241508),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
