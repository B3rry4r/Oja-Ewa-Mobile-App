import 'package:flutter/material.dart';

import '../../../../../app/router/app_router.dart';

class BusinessCategoryScreen extends StatefulWidget {
  const BusinessCategoryScreen({super.key});

  @override
  State<BusinessCategoryScreen> createState() => _BusinessCategoryScreenState();
}

class _BusinessCategoryScreenState extends State<BusinessCategoryScreen> {
  // Local state to track selection
  String selectedCategory = "Beauty";

  // Data mapping based on IR content
  final List<Map<String, String>> categories = [
    {
      "name": "Beauty",
      "desc": "Soaps & Creams, Fitness Coach, Dieticians, Spa, Salons"
    },
    {
      "name": "Brands",
      "desc": "Shoes & bags, Jewelries, Accessories, Gifts"
    },
    {
      "name": "Schools",
      "desc": "Fashion, Beauty, Catering, Music"
    },
    {
      "name": "Music",
      "desc": "Djs, Producers, Artists"
    },
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
              const SizedBox(height: 32),
              
              // Screen Title
              const Text(
                "Choose a business category",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F1011),
                  fontFamily: 'Campton',
                ),
              ),
              const SizedBox(height: 24),

              // Responsive Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 168 / 160, // Aspect ratio from IR sizes
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return _buildCategoryCard(
                      cat["name"]!, 
                      cat["desc"]!, 
                      isSelected: selectedCategory == cat["name"],
                    );
                  },
                ),
              ),

              // Primary Action Button
              _buildSaveButton(context),
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
        _buildIconBox(Icons.arrow_back_ios_new),
        _buildIconBox(Icons.close),
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

  Widget _buildCategoryCard(String name, String desc, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = name),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF603814) : const Color(0xFFFFF8F1),
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? null : Border.all(color: const Color(0xFFCCCCCC)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: isSelected ? Colors.white : const Color(0xFF1E2021),
                fontFamily: 'Campton',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              desc,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: isSelected ? Colors.white.withOpacity(0.9) : const Color(0xFF777F84),
                fontFamily: 'Campton',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRoutes.businessSellerRegistration,
          arguments: selectedCategory,
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
      width: double.infinity,
      height: 57,
      decoration: BoxDecoration(
        color: const Color(0xFFFDAF40), // Orange from IR
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
            color: Color(0xFFFFFBF5),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Campton',
          ),
        ),
      ),
    ),
   );
  }
}