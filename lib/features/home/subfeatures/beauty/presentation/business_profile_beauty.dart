import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/features/business_details/presentation/controllers/business_details_controller.dart';
import 'package:ojaewa/features/product_detail/presentation/reviews.dart';

class BusinessProfileBeautyScreen extends ConsumerWidget {
  const BusinessProfileBeautyScreen({super.key, this.businessId});

  /// If provided, fetches data from API. Otherwise shows placeholder data.
  final int? businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If businessId is provided, fetch from API
    if (businessId != null) {
      final detailsAsync = ref.watch(businessDetailsProvider(businessId!));
      return detailsAsync.when(
        loading: () => const Scaffold(
          backgroundColor: Color(0xFFFFF8F1),
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          backgroundColor: const Color(0xFFFFF8F1),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFFF8F1),
            foregroundColor: const Color(0xFF241508),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Failed to load business'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(businessDetailsProvider(businessId!)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (business) => _buildContent(context, business),
      );
    }
    
    // Fallback to placeholder data (for backward compatibility)
    return _buildContent(context, null);
  }

  Widget _buildContent(BuildContext context, BusinessDetails? business) {
    // Use API data if available, otherwise fallback to placeholders
    final businessName = business?.businessName ?? 'Cream De la\nCream';
    final description = business?.businessDescription ?? 'Cream de la cream, is a beauty academy providing some of the best beauty related services like hair making, makeup, brow services e.t.c...';
    final services = business?.serviceList ?? ['Makeup', 'Hair Styling', 'Skincare', 'Nail Art'];
    final email = business?.businessEmail ?? 'creamlacream@gmail.com';
    final phone = business?.businessPhone ?? '08106628782';
    final location = business?.fullAddress ?? '33rd Street, New York';
    final instagram = business?.instagram;
    final facebook = business?.facebook;
    final website = business?.websiteUrl;
    final imageUrl = business?.imageUrl;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppHeader(
              backgroundColor: Color(0xFFFFF8F1),
              iconColor: Color(0xFF241508),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero image
                    Container(
                      height: 198,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5E0CE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 198,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.image, size: 80, color: Colors.white54),
                                ),
                              ),
                            )
                          : const Center(
                              child: Icon(Icons.image, size: 80, color: Colors.white54),
                            ),
                    ),

                    const SizedBox(height: 8),

                    // Business name and rating
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            businessName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF241508),
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFDB80),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '4.0',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF241508),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '(8)',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF777F84),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Description section
                    _buildSection(
                      title: 'Description',
                      content: description,
                    ),

                    // Services section
                    if (services.isNotEmpty)
                      _buildSection(
                        title: 'Services',
                        content: services.join('\n'),
                      ),

                    // Contact Details section
                    _buildContactDetailsSection(
                      address: location,
                      email: email,
                      phone: phone,
                      website: website,
                      instagram: instagram,
                      facebook: facebook,
                    ),

                    const SizedBox(height: 20),

                    // Reviews section
                    _buildReviewsSection(context),

                    const SizedBox(height: 180), // Space for bottom action bar
                  ],
                ),
              ),
            ),

            // Bottom action bar
            _buildBottomActionBar(phone),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFCCCCCC))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E2021),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1E2021),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactDetailsSection({
    required String address,
    required String email,
    required String phone,
    String? website,
    String? instagram,
    String? facebook,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFCCCCCC))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E2021),
            ),
          ),
          const SizedBox(height: 20),

          // Address
          _buildContactItem(
            icon: Icons.location_on,
            title: 'Address',
            content: address,
            actionText: 'Get Direction',
            hasAction: true,
          ),

          const SizedBox(height: 20),

          // Email
          _buildContactItem(
            icon: Icons.email_outlined,
            title: 'Email',
            content: email,
            hasAction: true,
          ),

          if (website != null && website.isNotEmpty) ...[
            const SizedBox(height: 20),
            // Website
            _buildContactItem(
              icon: Icons.language,
              title: 'Website',
              content: website,
              hasAction: true,
            ),
          ],

          const SizedBox(height: 20),

          // Socials
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF603814),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(2),
                child: SvgPicture.asset(
                  AppIcons.connectToUs,
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Socials',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E2021),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFCCCCCC)),
                        ),
                        child: SvgPicture.asset(
                          AppIcons.whatsapp,
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF1E2021),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 32,
                        height: 32,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFCCCCCC)),
                        ),
                        child: SvgPicture.asset(
                          AppIcons.phone,
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF1E2021),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String content,
    String? actionText,
    bool hasAction = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF603814),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(2),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E2021),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF000000),
                  height: 1.5,
                ),
              ),
              if (actionText != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      actionText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3C4042),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Color(0xFF3C4042),
                    ),
                  ],
                ),
              ] else if (hasAction) ...[
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Color(0xFF3C4042),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const ReviewsScreen())),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFDEDEDE))),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reviews header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reviews (4)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E2021),
                  ),
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    const Text(
                      '4.0',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E2021),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFDB80),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Sample review
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Lennox Len',
                      style: TextStyle(fontSize: 12, color: Color(0xFF3C4042)),
                    ),
                    Text(
                      'Aug 19, 2023',
                      style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) {
                    return const Icon(
                      Icons.star,
                      size: 11,
                      color: Color(0xFFFFDB80),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                const Text(
                  'So good',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E2021),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Good customer service, I was at the Spa some times back, the receptionist is ok and their agents are so goos aat what they do. Will use them again',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1E2021),
                    height: 1.4,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // See more icon
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.keyboard_arrow_down, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(String phone) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF603814),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Call button
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () => _makePhoneCall(phone),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFDAF40)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppIcons.phone,
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFFFDAF40),
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Call',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFDAF40),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // WhatsApp button
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: () => _openWhatsApp(phone),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppIcons.whatsapp,
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFFFFFBF5),
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Whatsapp',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFFFBF5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    // Clean phone number and ensure it has country code
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    // If Nigerian number without country code, add it
    if (cleanNumber.startsWith('0')) {
      cleanNumber = '234${cleanNumber.substring(1)}';
    } else if (!cleanNumber.startsWith('234') && cleanNumber.length == 10) {
      cleanNumber = '234$cleanNumber';
    }
    final uri = Uri.parse('https://wa.me/$cleanNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
