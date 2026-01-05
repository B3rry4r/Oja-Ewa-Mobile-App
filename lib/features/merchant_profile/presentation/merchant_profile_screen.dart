import 'package:flutter/material.dart';

class MerchantProfileScreen extends StatelessWidget {
  const MerchantProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1), // Cream background
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 1. Fixed Header (Back button, Actions)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _IconBtn(
                      icon: Icons.arrow_back,
                      onTap: () {},
                    ),
                    Row(
                      children: [
                        _IconBtn(
                          icon: Icons.search,
                          onTap: () {},
                        ),
                        const SizedBox(width: 8),
                        _IconBtn(
                          icon: Icons.more_horiz,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 2. Profile Info Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    const Text(
                      "Jenny Stitches",
                      style: TextStyle(
                        fontFamily: 'Campton',
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF241508),
                        height: 1.2,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stats Card
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA15E22), // Brown color from IR
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _StatItem(label: "Selling since", value: "3 years ago"),
                          _VerticalDivider(),
                          _StatItem(label: "Location", value: "Lagos, NG"),
                          _VerticalDivider(),
                          _StatItem(label: "Last seen", value: "3 hours ago"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Description
                    const Text(
                      "Fashion design | Asoebi | Ready to wear | 24/7 Delivery",
                      style: TextStyle(
                        fontFamily: 'Campton',
                        fontSize: 14,
                        color: Color(0xFF595F63),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            label: "Follow",
                            isPrimary: false,
                            icon: Icons.add,
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            label: "Message",
                            isPrimary: true, // Assuming emphasis
                            icon: Icons.chat_bubble_outline,
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 3. Tabs (Products, Reviews, About)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    _TabItem(label: "Products", count: "24", isActive: true),
                    const SizedBox(width: 24),
                    _TabItem(label: "Reviews", count: "102", isActive: false),
                    const SizedBox(width: 24),
                    _TabItem(label: "About", isActive: false),
                  ],
                ),
              ),
            ),
            
            // Divider
            const SliverToBoxAdapter(
              child: Divider(color: Color(0xFFDEDEDE), height: 1),
            ),

            // 4. Product Grid
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72, // Tweak for card height
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return const _ProductCard();
                  },
                  childCount: 6, // Mock count
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper Widgets
// ---------------------------------------------------------------------------

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDEDEDE)),
        color: Colors.transparent,
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF1E2021), size: 20),
        padding: EdgeInsets.zero,
        onPressed: onTap,
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFFFFE0C2), // Lighter brown/cream for secondary text on dark bg
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      color: Colors.white.withOpacity(0.2),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.isPrimary,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF241508) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF241508),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isPrimary ? Colors.white : const Color(0xFF241508),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isPrimary ? Colors.white : const Color(0xFF241508),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final String? count;
  final bool isActive;

  const _TabItem({required this.label, this.count, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? const Color(0xFF241508) : const Color(0xFF777F84),
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 4),
              Text(
                count!,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isActive ? const Color(0xFF241508) : const Color(0xFF777F84),
                  // Render superscript-like visual if needed, but standard align is fine
                ),
              ),
            ]
          ],
        ),
        const SizedBox(height: 8),
        // Active Indicator
        if (isActive)
          Container(
            height: 2,
            width: 24, // Fixed small width or allow flex
            color: const Color(0xFFFDAF40), // Orange accent
          ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image container with Favorite Icon
        Expanded(
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200], // Placeholder
                  image: const DecorationImage(
                    image: NetworkImage("https://placehold.co/168x180/png?text=Product"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_border, size: 16, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Ankara Peplum Top",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF1E2021),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "N 15,000",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF241508),
          ),
        ),
      ],
    );
  }
}