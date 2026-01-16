import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';

class ShopOrderDetailsScreen extends StatelessWidget {
  const ShopOrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeader(
              backgroundColor: Color(0xFFFFF8F1),
              iconColor: Color(0xFF241508),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order ID Heading
                    const Text(
                      "#hg5675894h",
                      style: TextStyle(
                        fontSize: 33,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF241508),
                        fontFamily: 'Campton',
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Details List
                    _buildDetailTile("Order Date", "Jan 6 2023"),
                    _buildDetailTile("Product", "Agbada in Style"),
                    _buildDetailTile("Quantity", "2"),
                    _buildDetailTile("Size", "XL"),
                    _buildDetailTile("Processing Time", "5 days / N20,000"),
                    
                    const SizedBox(height: 40),
                    
                    // Action Buttons
                    _buildActionButtons(),
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

  Widget _buildDetailTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Color(0xFF777F84),
              fontFamily: 'Campton',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF3C4042),
              fontFamily: 'Campton',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildButton("Accept Order", const Color(0xFFFDAF40), Colors.white),
        const SizedBox(height: 12),
        _buildButton("Decline", Colors.transparent, const Color(0xFFC95353), isBordered: true),
      ],
    );
  }

  Widget _buildButton(String text, Color bgColor, Color textColor, {bool isBordered = false}) {
    return Container(
      width: double.infinity,
      height: 57,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: isBordered ? Border.all(color: textColor) : null,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Campton',
          ),
        ),
      ),
    );
  }
}