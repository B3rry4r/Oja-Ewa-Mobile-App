// faqs_screen.dart
import 'package:flutter/material.dart';

class FaqsScreen extends StatelessWidget {
  const FaqsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // FAQ Items
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    
                    // FAQ Item 1 (Expanded with answer)
                    _buildFaqItem(
                      question: 'How to I start Selling',
                      isExpanded: true,
                      answer: 'Lorem ipsum dolor sit amet consectetur. Proin donec tincidunt id cursus risus. Lobortis fringilla pulvinar lobortis egestas. At ornare fringilla turpis ut fermentum etiam. Molestie purus facilisis pulvinar aliquam auctor quisque. Felis amet ipsum.',
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // FAQ Item 2 (Collapsed)
                    _buildFaqItem(
                      question: 'How does showcasing my business on Oja Ewa help me grow',
                      isExpanded: false,
                      answer: '',
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // FAQ Item 3 (Collapsed)
                    _buildFaqItem(
                      question: 'How to I start Selling',
                      isExpanded: false,
                      answer: '',
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // FAQ Item 4 (Collapsed)
                    _buildFaqItem(
                      question: 'How to I start Selling',
                      isExpanded: false,
                      answer: '',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          _buildIconButton(Icons.arrow_back_ios_new_rounded),
          
          // Title
          const Text(
            'FAQS',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              fontFamily: 'Campton',
              color: Color(0xFF241508),
            ),
          ),
          
          // Close button
          _buildIconButton(Icons.close_rounded),
        ],
      ),
    );
  }

  Widget _buildFaqItem({
    required String question,
    required bool isExpanded,
    required String answer,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDEDEDE)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Question row
              Container(
                height: 72,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Question text
                    Expanded(
                      child: Text(
                        question,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Campton',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E2021),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // Expand/collapse button
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          // Toggle expansion state
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          size: 20,
                          color: const Color(0xFF1E2021),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Answer section (only shown when expanded)
              if (isExpanded && answer.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    answer,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF1E2021),
                      height: 1.5,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDEDEDE)),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 20,
        ),
        onPressed: () {},
        padding: EdgeInsets.zero,
      ),
    );
  }
}