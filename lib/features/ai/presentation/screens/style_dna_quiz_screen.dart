import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/widgets/app_header.dart';
import '../../../account/presentation/controllers/profile_controller.dart';
import '../controllers/ai_personalization_controller.dart';

/// Style DNA Quiz Screen
/// 
/// A multi-step quiz that helps understand user's fashion preferences
/// and creates a personalized style profile.
class StyleDnaQuizScreen extends ConsumerStatefulWidget {
  const StyleDnaQuizScreen({super.key});

  @override
  ConsumerState<StyleDnaQuizScreen> createState() => _StyleDnaQuizScreenState();
}

class _StyleDnaQuizScreenState extends ConsumerState<StyleDnaQuizScreen> {
  final _pageController = PageController();

  // App consistent colors
  static const _backgroundColor = Color(0xFFFFFBF5);
  static const _cardColor = Color(0xFFF5E0CE);
  static const _primaryColor = Color(0xFFFDAF40);
  static const _textDark = Color(0xFF241508);
  static const _textSecondary = Color(0xFF777F84);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _submitQuiz() async {
    final user = ref.read(userProfileProvider).value;
    if (user == null) return;

    final profile = await ref
        .read(styleQuizControllerProvider.notifier)
        .submitQuiz(user.id.toString());

    if (profile != null && mounted) {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    final stateAsync = ref.read(styleQuizControllerProvider);
    final state = stateAsync.value ?? const StyleQuizState();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: _backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 40,
                  color: Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Style Profile Created!',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.profile?.styleProfile ?? 'Your personalized style profile is ready.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  color: _textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed(AppRoutes.personalizedRecommendations);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'See My Recommendations',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Campton',
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Campton',
                      color: _textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(styleQuizControllerProvider);
    final state = stateAsync.value ?? const StyleQuizState();
    final currentStep = state.currentStep;
    final totalSteps = styleQuizQuestions.length;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              backgroundColor: _backgroundColor,
              iconColor: _textDark,
              title: const Text(
                'Discover Your Style',
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
              showActions: false,
            ),

            // Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${currentStep + 1} of $totalSteps',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Campton',
                          fontWeight: FontWeight.w500,
                          color: _textSecondary,
                        ),
                      ),
                      Text(
                        '${((currentStep + 1) / totalSteps * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Campton',
                          fontWeight: FontWeight.w600,
                          color: _primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (currentStep + 1) / totalSteps,
                      backgroundColor: _cardColor,
                      valueColor: const AlwaysStoppedAnimation<Color>(_primaryColor),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Questions PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: totalSteps,
                onPageChanged: (index) {
                  if (index != currentStep) {
                    if (index > currentStep) {
                      ref.read(styleQuizControllerProvider.notifier).nextStep();
                    } else {
                      ref.read(styleQuizControllerProvider.notifier).previousStep();
                    }
                  }
                },
                itemBuilder: (context, index) {
                  return _buildQuestionPage(
                    styleQuizQuestions[index], 
                    stateAsync.value ?? const StyleQuizState(),
                  );
                },
              ),
            ),

            // Navigation Buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (currentStep > 0)
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          ref.read(styleQuizControllerProvider.notifier).previousStep();
                          _goToPage(currentStep - 1);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFCCCCCC)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Previous',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Campton',
                              fontWeight: FontWeight.w600,
                              color: _textDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: state.isSubmitting
                          ? null
                          : () {
                              final question = styleQuizQuestions[currentStep];
                              if (state.answers[question.id] == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Please select an option',
                                      style: TextStyle(fontFamily: 'Campton'),
                                    ),
                                    backgroundColor: _primaryColor,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                                return;
                              }

                              if (currentStep < totalSteps - 1) {
                                ref.read(styleQuizControllerProvider.notifier).nextStep();
                                _goToPage(currentStep + 1);
                              } else {
                                _submitQuiz();
                              }
                            },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: state.isSubmitting 
                              ? const Color(0xFFCCCCCC) 
                              : _primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: state.isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                currentStep < totalSteps - 1 ? 'Next' : 'Complete',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Campton',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionPage(StyleQuizQuestion question, StyleQuizState state) {
    final selectedAnswer = state.answers[question.id];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 22,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: _textDark,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          if (question.allowMultiple)
            const Text(
              'Select all that apply',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Campton',
                color: _textSecondary,
              ),
            ),
          const SizedBox(height: 24),

          // Options
          ...question.options.map((option) {
            final isSelected = selectedAnswer == option;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  ref.read(styleQuizControllerProvider.notifier)
                      .answerQuestion(question.id, option);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? _primaryColor.withOpacity(0.1) : _cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? _primaryColor : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? _primaryColor : Colors.white,
                          border: Border.all(
                            color: isSelected ? _primaryColor : const Color(0xFFCCCCCC),
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Campton',
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: _textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
