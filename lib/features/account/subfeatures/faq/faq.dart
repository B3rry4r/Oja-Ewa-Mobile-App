// faqs_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/ui/ui_error_message.dart';

import 'presentation/controllers/faq_controller.dart';

class FaqsScreen extends ConsumerStatefulWidget {
  const FaqsScreen({super.key});

  @override
  ConsumerState<FaqsScreen> createState() => _FaqsScreenState();
}

class _FaqsScreenState extends ConsumerState<FaqsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text;
    final faqs = ref.watch(faqSearchProvider(query));

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                    faqs.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, st) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          AppSnackbars.showError(context, UiErrorMessage.from(e));
                        });
                        return const SizedBox.shrink();
                      },
                      data: (items) {
                        if (items.isEmpty) {
                          return _buildAskAiFallback(context);
                        }

                        return Column(
                          children: [
                            const SizedBox(height: 16),
                            for (final item in items) ...[
                              _FaqAccordion(question: item.question, answer: item.answer),
                              const SizedBox(height: 8),
                            ],
                            const SizedBox(height: 16),
                            // Always show Ask AI option at the bottom
                            _buildAskAiButton(context),
                            const SizedBox(height: 24),
                          ],
                        );
                      },
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIconButton(Icons.arrow_back_ios_new_rounded, () => Navigator.of(context).maybePop()),
          const Text(
            'FAQS',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              fontFamily: 'Campton',
              color: Color(0xFF241508),
            ),
          ),
          _buildIconButton(Icons.close_rounded, () => Navigator.of(context).maybePop()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 49,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDEDEDE)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, color: Color(0xFF777F84)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search FAQs',
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () => setState(() => _searchController.clear()),
            ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDEDEDE)),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  /// Fallback when no FAQs found - suggest asking AI
  Widget _buildAskAiFallback(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFDAF40).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology,
              size: 40,
              color: Color(0xFFFDAF40),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No matching FAQs found',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: Color(0xFF241508),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try asking our Cultural AI Assistant instead!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Campton',
              color: const Color(0xFF241508).withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.aiChat),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFDAF40),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.chat, size: 20),
            label: const Text(
              'Ask AI Assistant',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Ask AI button shown at bottom of FAQ list
  Widget _buildAskAiButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.aiChat),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFDAF40).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFDAF40).withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFDAF40),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Can\'t find what you\'re looking for?',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF241508),
                    ),
                  ),
                  Text(
                    'Ask our AI Assistant for help',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Campton',
                      color: const Color(0xFF241508).withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFFFDAF40),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqAccordion extends StatefulWidget {
  const _FaqAccordion({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  State<_FaqAccordion> createState() => _FaqAccordionState();
}

class _FaqAccordionState extends State<_FaqAccordion> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDEDEDE)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.question,
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
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    child: Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                      color: const Color(0xFF1E2021),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_expanded && widget.answer.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.answer,
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
  }
}
