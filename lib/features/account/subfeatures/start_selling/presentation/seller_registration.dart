import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';

import '../../../../../app/router/app_router.dart';

import 'draft_utils.dart';
import 'seller_registration_draft.dart';

class SellerRegistrationScreen extends StatefulWidget {
  const SellerRegistrationScreen({super.key});

  @override
  State<SellerRegistrationScreen> createState() => _SellerRegistrationScreenState();
}

class _SellerRegistrationScreenState extends State<SellerRegistrationScreen> {
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _instagramController = TextEditingController();
  final _facebookController = TextEditingController();

  @override
  void dispose() {
    _cityController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1), // Main background from IR
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AppHeader(
              backgroundColor: Color(0xFFFFF8F1),
              iconColor: Color(0xFF241508),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildStepper(),
                  const SizedBox(height: 32),

                  // --- Location Section ---
                  _buildSectionHeader("Location"),
                  const SizedBox(height: 16),
                  _buildDropdownInput("Country", "Nigeria"),
                  const SizedBox(height: 20),
                  _buildDropdownInput("State", "FCT"),
                  const SizedBox(height: 20),
                  _buildTextInput("City", "Your City", controller: _cityController),
                  const SizedBox(height: 20),
                  _buildTextInput("Address Line", "Street, house number etc", controller: _addressController),

                  const SizedBox(height: 40),

                  // --- Contacts Section ---
                  _buildSectionHeader("Contacts"),
                  const SizedBox(height: 16),
                  _buildTextInput("Business Email", "you@example.com", controller: _emailController),
                  const SizedBox(height: 20),
                  _buildPhoneInput(
                    "Business Phone Number",
                    "+234",
                    controller: _phoneController,
                  ),

                  const SizedBox(height: 40),

                  // --- Social handles Section ---
                  _buildSectionHeader("Social handles"),
                  const SizedBox(height: 16),
                  _buildTextInput("Instagram", "Your Instagram URL", controller: _instagramController),
                  const SizedBox(height: 20),
                  _buildTextInput("Facebook", "Your Facebook URL", controller: _facebookController),

                  const SizedBox(height: 40),

                  // --- Means Identification Section ---
                  _buildSectionHeader("Means Identification"),
                  const SizedBox(height: 16),
                  _buildFileUploadSection(),

                  const SizedBox(height: 40),

                  // --- Save Button ---
                  _buildSubmitButton(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper: Stepper UI
  Widget _buildStepper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _stepCircle("1", "Basic\nInfo", true),
        _stepCircle("2", "Business\nDetails", false),
        _stepCircle("3", "Account\non review", false),
      ],
    );
  }

  Widget _stepCircle(String num, String label, bool isActive) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF603814) : const Color(0xFFE9E9E9),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Text(
            num,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            height: 1.2,
            color: isActive ? const Color(0xFF603814) : const Color(0xFF777F84),
            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
          ),
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
      ),
    );
  }

  Widget _buildTextInput(String label, String hint, {TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF777F84), fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(
            fontFamily: 'Campton',
            fontSize: 16,
            color: Color(0xFF1E2021),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFCCCCCC)),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownInput(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF777F84), fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCCCCCC)),
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

  Widget _buildPhoneInput(String label, String code, {required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF777F84), fontSize: 14)),
        const SizedBox(height: 8),
       Container(
         height: 49,
         padding: const EdgeInsets.symmetric(horizontal: 20),
         decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(8),
           border: Border.all(color: const Color(0xFFCCCCCC)),
         ),
         alignment: Alignment.center,
         child: Row(
           children: [
             Text(
               code,
               style: const TextStyle(
                 fontSize: 16,
                 fontWeight: FontWeight.w600,
                 color: Color(0xFF241508),
               ),
             ),
             const SizedBox(width: 8),
             Expanded(
               child: TextFormField(
                 controller: controller,
                 keyboardType: TextInputType.phone,
                 style: const TextStyle(fontSize: 16, color: Color(0xFF1E2021)),
                 decoration: const InputDecoration(
                   border: InputBorder.none,
                   isDense: true,
                   contentPadding: EdgeInsets.zero,
                   hintText: 'Enter phone number',
                   hintStyle: TextStyle(color: Color(0xFFCCCCCC)),
                 ),
               ),
             ),
           ],
         ),
       ),
      ],
    );
  }

  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Upload Document", style: TextStyle(color: Color(0xFF777F84), fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: const Color(0xFF89858A), style: BorderStyle.solid), // IR indicates dashed-like border
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_upload_outlined, size: 24, color: Color(0xFF777F84)),
              const SizedBox(height: 12),
              const Text("Browse Document", style: TextStyle(fontSize: 16, color: Color(0xFF1E2021))),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text("High resolution image\nPDF, JPG, PNG formats", 
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Color(0xFF777F84))),
                  SizedBox(width: 20),
                  Text("200 x 200px\n20kb max", 
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Color(0xFF777F84))),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return InkWell(
      onTap: () {
        final draft = sellerDraftFromArgs(ModalRoute.of(context)?.settings.arguments)
          ..country = 'Nigeria'
          ..state = 'FCT'
          ..city = _cityController.text.trim()
          ..address = _addressController.text.trim()
          ..businessEmail = _emailController.text.trim()
          ..businessPhoneNumber = _phoneController.text.trim()
          ..instagram = _instagramController.text.trim()
          ..facebook = _facebookController.text.trim();

        Navigator.of(context).pushNamed(AppRoutes.businessDetails, arguments: draft.toJson());
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
              color: const Color(0xFFFDAF40).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: const Center(
          child: Text(
            'Save and Continue',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
