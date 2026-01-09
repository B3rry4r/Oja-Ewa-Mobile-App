import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Using Scaffold to manage the main layout
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppHeader(
                  backgroundColor: Color(0xFFFFF8F1),
                  iconColor: Color(0xFF241508),
                ),
                const SizedBox(height: 16),
                const _HeroImageSection(),
                const SizedBox(height: 16),
                const _PaginationDots(),
                const SizedBox(height: 24),
                const _ProductTitleSection(),
                const SizedBox(height: 24),
                const _SizeSelectionSection(),
                const SizedBox(height: 24),
                const _ProcessingTimeSection(),
                const SizedBox(height: 16),
                const _PackageOptionsSection(),
                const SizedBox(height: 24),
                _ExpandableSectionHeader(title: "Description", onTap: () {}),
                const Divider(color: Color(0xFFDEDEDE)),
                const _ReviewsSection(),
                const Divider(color: Color(0xFFDEDEDE)),
                _ExpandableSectionHeader(title: "Return Policy", onTap: () {}),
                const Divider(color: Color(0xFFDEDEDE)),
                _ExpandableSectionHeader(title: "About Seller", onTap: () {}),
                const SizedBox(height: 32),
                const _RecommendationsSection(),
                const SizedBox(height: 40),
                const _StickyBottomActionPanel(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 1. Header Section
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// 2. Hero Image Section
// ---------------------------------------------------------------------------

class _HeroImageSection extends StatelessWidget {
  const _HeroImageSection();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200], // Placeholder color
          image: const DecorationImage(
            image: NetworkImage("https://placehold.co/343x300/png?text=Product+Image"), // Placeholder
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _PaginationDots extends StatelessWidget {
  const _PaginationDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDot(isActive: true),
        const SizedBox(width: 8),
        _buildDot(isActive: false),
        const SizedBox(width: 8),
        _buildDot(isActive: false),
      ],
    );
  }

  Widget _buildDot({required bool isActive}) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFDAF40) : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFFDAF40),
          width: 1,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Product Title & Info
// ---------------------------------------------------------------------------

class _ProductTitleSection extends StatelessWidget {
  const _ProductTitleSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Agbada in Voue",
              style: TextStyle(
                fontFamily: 'Campton',
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xFF241508),
              ),
            ),
            _IconContainer(icon: Icons.ios_share, onTap: () {}),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          "by Jenny Stitches",
          style: TextStyle(
            fontFamily: 'Campton',
            fontWeight: FontWeight.w400, // Book
            fontSize: 12,
            color: Color(0xFF595F63),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Size Selection
// ---------------------------------------------------------------------------

class _SizeSelectionSection extends StatelessWidget {
  const _SizeSelectionSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Size",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF1E2021)),
            ),
            Text(
              "View Size Chart",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF777F84),
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _SizeChip(label: "XS"),
            const SizedBox(width: 8),
            _SizeChip(label: "S", isSelected: true),
            const SizedBox(width: 8),
            _SizeChip(label: "M"),
            const SizedBox(width: 8),
            _SizeChip(label: "L"),
            const SizedBox(width: 8),
            _SizeChip(label: "XL"),
          ],
        ),
      ],
    );
  }
}

class _SizeChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _SizeChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFA15E22) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? null : Border.all(color: const Color(0xFFCCCCCC)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: isSelected ? const Color(0xFFFBFBFB) : const Color(0xFF1E2021),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. Processing Time & Packages
// ---------------------------------------------------------------------------

class _ProcessingTimeSection extends StatelessWidget {
  const _ProcessingTimeSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Processing Time",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E2021)),
        ),
        const SizedBox(height: 8),
        const Text(
          "Select your package type",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF777F84)),
        ),
      ],
    );
  }
}

class _PackageOptionsSection extends StatelessWidget {
  const _PackageOptionsSection();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          _PackageCard(
            title: "Normal",
            duration: "10 days",
            price: "N20,000",
            backgroundColor: const Color(0xFFF5E0CE),
            borderColor: const Color(0xFF603814),
            isSelected: true,
          ),
          const SizedBox(width: 16),
          _PackageCard(
            title: "Quick Quick",
            duration: "10 days",
            price: "N20,000",
            backgroundColor: const Color(0xFFFFF8F1), // Matches BG but has border
            borderColor: const Color(0xFFCCCCCC), // Default border
            isSelected: false,
          ),
        ],
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final String title;
  final String duration;
  final String price;
  final Color backgroundColor;
  final Color borderColor;
  final bool isSelected;

  const _PackageCard({
    required this.title,
    required this.duration,
    required this.price,
    required this.backgroundColor,
    required this.borderColor,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168,
      height: 122,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: isSelected ? 1 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Icon placeholder
              Icon(Icons.access_time, size: 20, color: isSelected ? Colors.black : Colors.black54),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
            ],
          ),
          Text(duration, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF603814),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                )
              else
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF777F84), // Inactive gray
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                )
            ],
          )
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 6. Expandable Sections & Reviews
// ---------------------------------------------------------------------------

class _ExpandableSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _ExpandableSectionHeader({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E2021)),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1E2021)),
          ],
        ),
      ),
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Reviews (4)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Text("4.0", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Icon(Icons.star, size: 12, color: Color(0xFFFFDB80)),
                    ],
                  )
                ],
              ),
              const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1E2021)),
            ],
          ),
        ),
        // Review Item
        Container(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text("Lennox Len", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
                      const SizedBox(width: 8),
                      const Text("Aug 19, 2023", style: TextStyle(fontSize: 10, color: Color(0xFFB1B1B1))),
                    ],
                  ),
                  // Rating stars placeholder
                  Row(
                    children: List.generate(5, (index) => const Icon(Icons.star, size: 10, color: Color(0xFFFFDB80))),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text("So good", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              const Text(
                "Good customer service, I was at the Spa some times back, the receptionist is ok and their agents are so goos aat what they do. Will use them again",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.3),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.grey),
                  onPressed: () {},
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 7. Recommendations (You May Also Like)
// ---------------------------------------------------------------------------

class _RecommendationsSection extends StatelessWidget {
  const _RecommendationsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("You may also like", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              _ProductCard(
                title: "Agbada in Voue",
                price: "N20,000",
                imageUrl: "https://placehold.co/168x152/png?text=Item+1",
              ),
              const SizedBox(width: 16),
              _ProductCard(
                title: "Agbada in Voue",
                price: "From N20,000",
                oldPrice: "#25,000",
                imageUrl: "https://placehold.co/168x152/png?text=Item+2",
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String? oldPrice;
  final String imageUrl;

  const _ProductCard({
    required this.title,
    required this.price,
    this.oldPrice,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 168,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 168,
                  height: 152,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_border, size: 14, color: Colors.black),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
          const SizedBox(height: 4),
          Text(price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          if (oldPrice != null)
            Text(
              oldPrice!,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFFB1B1B1),
                decoration: TextDecoration.lineThrough,
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 8. Bottom Sticky Footer
// ---------------------------------------------------------------------------

class _StickyBottomActionPanel extends StatelessWidget {
  const _StickyBottomActionPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF5), // Slightly different cream from scaffold
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quantity Selector
          Row(
            children: [
              _QuantityButton(icon: Icons.remove, onTap: () {}),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("1", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              _QuantityButton(icon: Icons.add, onTap: () {}),
            ],
          ),
          const SizedBox(height: 16),
          // Price and Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("N20,000", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text("#25,000", style: TextStyle(fontSize: 10, decoration: TextDecoration.lineThrough, color: Color(0xFFB1B1B1))),
                ],
              ),
              // Add to Bag Button
              Container(
                width: 179,
                height: 57,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDAF40),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFDAF40).withOpacity(0.2),
                      offset: const Offset(0, 8),
                      blurRadius: 16,
                    )
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(8),
                    child: const Center(
                      child: Text(
                        "Add to Bag",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFFFBF5), // Off-white text
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: const Color(0xFF1E2021)),
      ),
    );
  }
}