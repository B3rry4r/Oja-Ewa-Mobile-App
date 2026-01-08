import 'package:flutter/material.dart';

class DeleteShopScreen extends StatefulWidget {
  const DeleteShopScreen({super.key});

  @override
  State<DeleteShopScreen> createState() => _DeleteShopScreenState();
}

class _DeleteShopScreenState extends State<DeleteShopScreen> {
  // Local state to track selected reason
  String? selectedReason;

  final List<String> reasons = [
    "Not making money",
    "Switching to another platform",
    "Technical issues",
    "Too expensive",
    "Other"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1), // Background from IR
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 28),
              _buildHeader(),
              const SizedBox(height: 36),
              
              // Title: Why are you leaving
              const Text(
                "Why are you leaving",
                style: TextStyle(
                  fontSize: 33,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF241508),
                  fontFamily: 'Campton',
                ),
              ),
              const SizedBox(height: 32),

              // Reasons List
              Expanded(
                child: ListView.builder(
                  itemCount: reasons.length,
                  itemBuilder: (context, index) {
                    return _buildReasonRow(reasons[index]);
                  },
                ),
              ),

              // Action Button
              _buildDeleteButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildIconBox(Icons.arrow_back_ios_new), // Back Button
        Row(
          children: [
            _buildIconBox(Icons.notifications_none),
            const SizedBox(width: 8),
            _buildIconBox(Icons.person_outline),
          ],
        ),
      ],
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

  Widget _buildReasonRow(String reason) {
    final bool isSelected = selectedReason == reason;
    
    return GestureDetector(
      onTap: () => setState(() => selectedReason = reason),
      child: Container(
        height: 40,
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            // Custom Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFDAF40) : const Color(0xFF777F84),
                  width: 2,
                ),
                color: isSelected ? const Color(0xFFFDAF40) : Colors.transparent,
              ),
              child: isSelected 
                ? const Icon(Icons.check, size: 16, color: Colors.white) 
                : null,
            ),
            const SizedBox(width: 12),
            // Reason Text
            Text(
              reason,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF1E2021),
                fontFamily: 'Campton',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Container(
      width: double.infinity,
      height: 57,
      decoration: BoxDecoration(
        color: const Color(0xFFFDAF40), // Primary Orange from IR
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFDAF40).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8), // Shadow from IR
          )
        ],
      ),
      child: Center(
        child: Text(
          "Continue to delete",
          style: TextStyle(
            color: const Color(0xFFFFFBF5), // White text from IR
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Campton',
          ),
        ),
      ),
    );
  }
}