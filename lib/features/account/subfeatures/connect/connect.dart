// connect_to_us_screen.dart
import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ConnectToUsScreen extends StatelessWidget {
  const ConnectToUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const AppHeader(
                backgroundColor: Color(0xFFFFF8F1),
                iconColor: Color(0xFF241508),
              ),
              
              // Social media connections
              _buildSocialConnections(),
              
              // Decorative background image
              Align(
                alignment: Alignment.centerRight,
                child: Opacity(
                  opacity: 0.03,
                  child: Image.asset(
                    'assets/images/connect_decoration.png',
                    width: 234,
                    height: 347,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialConnections() {
    final List<SocialConnection> connections = [
      SocialConnection(
        platform: 'WhatsApp',
        username: '+234 000 000 0000',
        iconAsset: AppIcons.whatsapp,
        color: Color(0xFFF5E0CE),
      ),
      SocialConnection(
        platform: 'Phone',
        username: '+234 000 000 0000',
        iconAsset: AppIcons.phone,
        color: Color(0xFFF5E0CE),
      ),
      SocialConnection(
        platform: 'Email',
        username: 'support@ojaewa.com',
        iconAsset: AppIcons.emailUs,
        color: Color(0xFFF5E0CE),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 100, 16, 162),
      child: Column(
        children: [
          for (var connection in connections)
            _buildSocialConnectionItem(connection),
        ],
      ),
    );
  }

  Widget _buildSocialConnectionItem(SocialConnection connection) {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 0), // No bottom margin, items are stacked
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Icon and username
          Row(
            children: [
              // Social media icon
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: connection.color,
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  connection.iconAsset,
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF1E2021),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // Username
              Text(
                connection.username,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Campton',
                  color: Color(0xFF1E2021),
                ),
              ),
            ],
          ),
          
          // Right side: Link/External icon
          IconButton(
            icon: const Icon(
              Icons.open_in_new_rounded,
              size: 16,
              color: Color(0xFF1E2021),
            ),
            onPressed: () {
              // Open social media link
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 24,
              minHeight: 24,
            ),
          ),
        ],
      ),
    );
  }

}

class SocialConnection {
  final String platform;
  final String username;
  final String iconAsset;
  final Color color;

  SocialConnection({
    required this.platform,
    required this.username,
    required this.iconAsset,
    required this.color,
  });
}