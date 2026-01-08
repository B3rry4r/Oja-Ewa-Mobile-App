import 'package:flutter/material.dart';

class EditBusinessScreen extends StatelessWidget {
  const EditBusinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1), // Background from IR
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Business Location"),
            const SizedBox(height: 16),
            _buildDropdownField("Country", "Nigeria"),
            const SizedBox(height: 16),
            _buildDropdownField("State", "FCT"),
            const SizedBox(height: 16),
            _buildTextField("City", "Your City"),
            const SizedBox(height: 16),
            _buildTextField("Address Line", "Street, house number etc"),
            
            const SizedBox(height: 32),
            _buildSectionHeader("Mobiles"),
            const SizedBox(height: 16),
            _buildTextField("Business Email", "sanusimot@gmail.com"),
            const SizedBox(height: 16),
            _buildPhoneInput(),

            const SizedBox(height: 32),
            _buildSectionHeader("Social handles"),
            const SizedBox(height: 16),
            _buildTextField("Instagram", "Your Instagram URL"),
            const SizedBox(height: 16),
            _buildTextField("Facebook", "Your Facebook URL"),
            const SizedBox(height: 16),
            _buildTextField("Website URL", "sanusimot@gmail.com"),

            const SizedBox(height: 32),
            _buildSectionHeader("About Business"),
            const SizedBox(height: 16),
            _buildTextField("Business Name", "Your City"),
            const SizedBox(height: 16),
            _buildTextField(
              "Description", 
              "Share details of your experience", 
              maxLines: 4,
              helperText: "100 characters required",
            ),
            const SizedBox(height: 16),
            _buildTextField("Product List", "List your products here", maxLines: 4),

            const SizedBox(height: 32),
            _buildLogoSection(),

            const SizedBox(height: 40),
            _buildSubmitButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 70,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
        child: _HeaderButton(icon: Icons.arrow_back_ios_new, onTap: () => Navigator.pop(context)),
      ),
      centerTitle: true,
      title: const Text(
        "Edit Business",
        style: TextStyle(
          color: Color(0xFF241508),
          fontSize: 22,
          fontFamily: 'Campton',
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          child: _HeaderButton(icon: Icons.notifications_none, onTap: () {}),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF3C4042),
        fontFamily: 'Campton',
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {int maxLines = 1, String? helperText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF777F84), fontSize: 14, fontFamily: 'Campton'),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 16),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              helperText,
              style: const TextStyle(color: Color(0xFF595F63), fontSize: 10),
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildDropdownField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF777F84), fontSize: 14, fontFamily: 'Campton'),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCCCCCC)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(fontSize: 16, color: Color(0xFF1E2021))),
              const Icon(Icons.keyboard_arrow_down, color: Color(0xFF777F84)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Business Phone Number",
          style: TextStyle(color: Color(0xFF777F84), fontSize: 14, fontFamily: 'Campton'),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCCCCCC)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.flag, size: 20), // Placeholder for country flag
                    SizedBox(width: 8),
                    Text("+234", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: "8167654354",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoSection() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Business Logo",
              style: TextStyle(color: Color(0xFF777F84), fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              width: 80,
              height: 74,
              decoration: BoxDecoration(
                color: const Color(0xFFF5E0CE),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(child: Icon(Icons.camera_alt_outlined)),
            ),
          ],
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: const Color(0xFFFDAF40),
            elevation: 0,
            side: const BorderSide(color: Color(0xFFFDAF40)),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("Change"),
        )
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 57,
      decoration: BoxDecoration(
        color: const Color(0xFFFDAF40),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFDAF40).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: const Center(
        child: Text(
          "Save Changes",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Campton',
          ),
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFDEDEDE)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF1E2021)),
      ),
    );
  }
}