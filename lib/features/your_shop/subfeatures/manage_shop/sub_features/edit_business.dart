import 'package:flutter/material.dart';

class EditBusinessScreen extends StatelessWidget {
  const EditBusinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1), // Primary BG
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildSectionHeader("Business Location"),
                    _buildInputField("Country", hint: "Nigeria", isDropdown: true),
                    _buildInputField("State", hint: "FCT", isDropdown: true),
                    _buildInputField("City", hint: "Your City"),
                    _buildInputField("Address Line", hint: "Street, house number etc"),
                    
                    const SizedBox(height: 32),
                    _buildSectionHeader("Mobiles"),
                    _buildInputField("Business Email", hint: "sanusimot@gmail.com"),
                    _buildPhoneField("Business Phone Number"),
                    
                    const SizedBox(height: 32),
                    _buildSectionHeader("Social handles"),
                    _buildInputField("Instagram", hint: "Your Instagram URL"),
                    _buildInputField("Facebook", hint: "Your Facebook URL"),
                    
                    const SizedBox(height: 32),
                    _buildSectionHeader("About Business"),
                    _buildInputField("Business Name", hint: "Your Business Name"),
                    _buildInputField("Description", hint: "Share details of your experience", maxLines: 4),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text("100 characters required", 
                        style: TextStyle(fontSize: 10, color: Color(0xFF595F63))),
                    ),
                    
                    const SizedBox(height: 32),
                    _buildLogoSection(),
                    
                    const SizedBox(height: 32),
                    _buildSectionHeader("Account"),
                    _buildInputField("Bank Name", hint: "Your Bank"),
                    _buildInputField("Account Number", hint: "Your Account Number"),
                    
                    const SizedBox(height: 40),
                    _buildSaveButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIconBox(Icons.arrow_back_ios_new),
          const Text(
            "Edit Business",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF241508),
            ),
          ),
          _buildIconBox(Icons.close),
        ],
      ),
    );
  }

  Widget _buildIconBox(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDEDEDE)),
      ),
      child: Icon(icon, size: 20, color: const Color(0xFF241508)),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF3C4042),
          fontFamily: 'Campton',
        ),
      ),
    );
  }

  Widget _buildInputField(String label, {required String hint, bool isDropdown = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF777F84))),
          const SizedBox(height: 8),
          TextField(
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 16),
              suffixIcon: isDropdown ? const Icon(Icons.keyboard_arrow_down, color: Color(0xFF777F84)) : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
        ],
      ),
    );
  }

  Widget _buildPhoneField(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF777F84))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCCCCCC)),
            ),
            child: Row(
              children: [
                const Icon(Icons.flag, size: 20), // Placeholder for country asset
                const SizedBox(width: 8),
                const Text("+234", style: TextStyle(fontSize: 16, color: Color(0xFF241508))),
                const SizedBox(width: 12),
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "8167654354",
                      hintStyle: TextStyle(color: Color(0xFFCCCCCC)),
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

  Widget _buildLogoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Business Logo", style: TextStyle(fontSize: 14, color: Color(0xFF777F84))),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 80,
              height: 74,
              decoration: BoxDecoration(
                color: const Color(0xFFF5E0CE), // Color from IR
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.business, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: const Color(0xFFFDAF40),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFFFDAF40)),
                ),
              ),
              child: const Text("Change", style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
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
          "Save and Continue",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}