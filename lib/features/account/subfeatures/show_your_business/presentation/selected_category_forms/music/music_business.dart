import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';

import '../../../../../../../app/router/app_router.dart';
import '../draft_utils.dart';

class MusicBusinessDetailsScreen extends StatefulWidget {
  const MusicBusinessDetailsScreen({super.key});

  @override
  State<MusicBusinessDetailsScreen> createState() =>
      _MusicBusinessDetailsScreenState();
}

class _MusicBusinessDetailsScreenState
    extends State<MusicBusinessDetailsScreen> {
  // UI label values
  String _selectedCategoryLabel = "DJ";

  // Backend enum values (dj|artist|producer)
  String get _musicCategoryValue {
    switch (_selectedCategoryLabel) {
      case 'Artiste':
        return 'artist';
      default:
        return _selectedCategoryLabel.toLowerCase();
    }
  }

  final _businessNameController = TextEditingController();
  final _businessDescriptionController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _spotifyController = TextEditingController();

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessDescriptionController.dispose();
    _youtubeController.dispose();
    _spotifyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(104),
        child: AppHeader(
          backgroundColor: Color(0xFFFFF8F1),
          iconColor: Color(0xFF241508),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildStepper(),
            const SizedBox(height: 32),

            const Text(
              "About Business",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w600,
                color: Color(0xFF3C4042),
              ),
            ),
            const SizedBox(height: 16),

            _buildInputField("Music School/Studio Name", "Enter name", controller: _businessNameController),
            const SizedBox(height: 24),

            const Text(
              "Select Category",
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Campton',
                color: Color(0xFF777F84),
              ),
            ),
            const SizedBox(height: 12),
            _buildCategoryGrid(),

            const SizedBox(height: 24),
            _buildInputField(
              "Business Description",
              "Describe your music services or school",
              maxLines: 4,
              helperText: "100 characters required",
              controller: _businessDescriptionController,
            ),

            const SizedBox(height: 24),
            _buildInputField(
              "YouTube",
              "Paste your YouTube link",
              controller: _youtubeController,
            ),
            const SizedBox(height: 24),
            _buildInputField(
              "Spotify",
              "Paste your Spotify link",
              controller: _spotifyController,
            ),

            const SizedBox(height: 32),
            _buildUploadSection("Identity Document"),
            const SizedBox(height: 24),
            _buildUploadSection("Business Logo"),

            const SizedBox(height: 40),
            _buildContinueButton(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStep(Icons.check, "Basic\nInfo", true),
        _buildStep(null, "Business\nDetails", true, stepNum: "2"),
        _buildStep(null, "Account\non review", false, stepNum: "3"),
      ],
    );
  }

  Widget _buildStep(
    IconData? icon,
    String label,
    bool isActive, {
    String? stepNum,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF603814) : const Color(0xFFE9E9E9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: icon != null
                ? Icon(icon, color: Colors.white, size: 16)
                : Text(
                    stepNum ?? "",
                    style: TextStyle(
                      color: isActive ? Colors.white : const Color(0xFF777F84),
                      fontSize: 10,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontFamily: 'Campton',
            color: isActive ? const Color(0xFF603814) : const Color(0xFF777F84),
            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    final categories = ["DJ", "Artiste", "Producer"];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: categories.map((cat) {
        final isSelected = _selectedCategoryLabel == cat;

        return InkWell(
          onTap: () => setState(() => _selectedCategoryLabel = cat),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFA15E22)
                    : const Color(0xFFCCCCCC),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.add_circle_outline,
                  size: 18,
                  color: isSelected
                      ? const Color(0xFFA15E22)
                      : const Color(0xFF777F84),
                ),
                const SizedBox(width: 8),
                Text(
                  cat,
                  style: TextStyle(
                    color: const Color(0xFF241508),
                    fontSize: 15,
                    fontFamily: 'Campton',
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInputField(
    String label,
    String hint, {
    int maxLines = 1,
    String? helperText,
    TextEditingController? controller,
  }) { 

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF777F84), fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(
            fontFamily: 'Campton',
            fontSize: 16,
            color: Color(0xFF1E2021),
          ),
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 15),
            contentPadding: const EdgeInsets.all(16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFFDAF40)),
            ),
          ),
        ),
        if (helperText != null)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                helperText,
                style: const TextStyle(fontSize: 10, color: Color(0xFF595F63)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUploadSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Color(0xFF777F84), fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF89858A),
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                color: Color(0xFF603814),
                size: 30,
              ),
              SizedBox(height: 8),
              Text(
                "Browse Document",
                style: TextStyle(fontSize: 16, color: Color(0xFF1E2021)),
              ),
              SizedBox(height: 8),
              Text(
                "PNG, JPG formats (200x200px recommended)",
                style: TextStyle(fontSize: 10, color: Color(0xFF777F84)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return InkWell(
      onTap: () {
        final draft = draftFromArgs(
            ModalRoute.of(context)?.settings.arguments,
            categoryLabelFallback: 'Music',
          );
          final updated = draft
            ..businessName = _businessNameController.text.trim()
            ..businessDescription = _businessDescriptionController.text.trim()
            ..musicCategory = _musicCategoryValue
            ..youtube = _youtubeController.text.trim()
            ..spotify = _spotifyController.text.trim();

          Navigator.of(context).pushNamed(
            AppRoutes.businessAccountReview,
            arguments: updated.toJson(),
          );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFFDAF40),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFDAF40).withOpacity(0.35),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "Continue",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
