import 'package:flutter/material.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';

class EditBusinessScreen extends StatelessWidget {
  const EditBusinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AppPageScaffold(
      title: 'Edit Business',
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildSectionHeader(context, "Business Location"),
          _buildInputField(
            context,
            "Country",
            hint: "Nigeria",
            isDropdown: true,
          ),
          _buildInputField(context, "State", hint: "FCT", isDropdown: true),
          _buildInputField(context, "City", hint: "Your City"),
          _buildInputField(
            context,
            "Address Line",
            hint: "Street, house number etc",
          ),

          const SizedBox(height: 32),
          _buildSectionHeader(context, "Mobiles"),
          _buildInputField(
            context,
            "Business Email",
            hint: "sanusimot@gmail.com",
          ),
          _buildPhoneField(context, "Business Phone Number"),

          const SizedBox(height: 32),
          _buildSectionHeader(context, "Social handles"),
          _buildInputField(context, "Instagram", hint: "Your Instagram URL"),
          _buildInputField(context, "Facebook", hint: "Your Facebook URL"),

          const SizedBox(height: 32),
          _buildSectionHeader(context, "About Business"),
          _buildInputField(
            context,
            "Business Name",
            hint: "Your Business Name",
          ),
          _buildInputField(
            context,
            "Description",
            hint: "Share details of your experience",
            maxLines: 4,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "100 characters required",
              style: TextStyle(fontSize: 10, color: colors.textTertiary),
            ),
          ),

          const SizedBox(height: 32),
          _buildLogoSection(context),

          const SizedBox(height: 32),
          _buildSectionHeader(context, "Account"),
          _buildInputField(context, "Bank Name", hint: "Your Bank"),
          _buildInputField(
            context,
            "Account Number",
            hint: "Your Account Number",
          ),

          const SizedBox(height: 40),
          _buildSaveButton(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildInputField(
    BuildContext context,
    String label, {
    required String hint,
    bool isDropdown = false,
    int maxLines = 1,
  }) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: colors.textSecondary),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.border),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextField(
              maxLines: maxLines,
              style: TextStyle(color: colors.textPrimary, fontSize: 16),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: colors.textTertiary, fontSize: 16),
                suffixIcon: isDropdown
                    ? Icon(
                        Icons.keyboard_arrow_down,
                        color: colors.textSecondary,
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField(BuildContext context, String label) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: colors.textSecondary),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.border),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.flag,
                  size: 20,
                ), // Placeholder for country asset
                const SizedBox(width: 8),
                Text(
                  "+234",
                  style: TextStyle(fontSize: 16, color: colors.textPrimary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "8167654354",
                      hintStyle: TextStyle(color: colors.textTertiary),
                      border: InputBorder.none,
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

  Widget _buildLogoSection(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Business Logo",
          style: TextStyle(fontSize: 14, color: colors.textSecondary),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 80,
              height: 74,
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.business, color: colors.accent, size: 32),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.surfaceElevated,
                foregroundColor: colors.accent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(color: colors.accent),
                ),
              ),
              child: const Text(
                "Change",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      height: 57,
      decoration: BoxDecoration(
        color: colors.accent,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colors.accent.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          "Save and Continue",
          style: TextStyle(
            color: colors.onAccent,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
