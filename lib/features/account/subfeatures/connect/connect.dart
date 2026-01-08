// connect_to_us_screen.dart
import 'package:flutter/material.dart';

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
              // Header
              _buildHeader(),
              
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          _buildIconButton(Icons.arrow_back_ios_new_rounded),
          
          // Title
          const Text(
            'Connect to Us',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              fontFamily: 'Campton',
              color: Color(0xFF241508),
            ),
          ),
          
          // Close button
          _buildIconButton(Icons.close_rounded),
        ],
      ),
    );
  }

  Widget _buildSocialConnections() {
    final List<SocialConnection> connections = [
      SocialConnection(
        platform: 'Instagram',
        username: '@oja_ewa',
        icon: Icons.camera_alt_outlined,
        color: Color(0xFFF5E0CE),
      ),
      SocialConnection(
        platform: 'Facebook',
        username: 'Oja Ewa',
        icon: Icons.facebook,
        color: Color(0xFFF5E0CE),
      ),
      SocialConnection(
        platform: 'Twitter',
        username: 'Oja_Ewa',
        icon: Icons.flutter_dash, // Using flutter_dash as placeholder for Twitter/X
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
                child: Icon(
                  connection.icon,
                  size: 16,
                  color: const Color(0xFF1E2021),
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

  Widget _buildIconButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDEDEDE)),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 20,
        ),
        onPressed: () {},
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class SocialConnection {
  final String platform;
  final String username;
  final IconData icon;
  final Color color;

  SocialConnection({
    required this.platform,
    required this.username,
    required this.icon,
    required this.color,
  });
}