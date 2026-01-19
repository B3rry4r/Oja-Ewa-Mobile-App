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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 50,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Style Profile Created!',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w600,
                color: Color(0xFF241508),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              state.profile?.styleProfile ?? 'Your personalized style profile is ready.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Campton',
                color: const Color(0xFF241508).withOpacity(0.7),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed(AppRoutes.personalizedRecommendations);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFDAF40),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'See My Recommendations',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Back to Home',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  color: Color(0xFF777F84),
                ),
              ),
            ),
          ],
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
      backgroundColor: const Color(0xFFFFFBF5),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              backgroundColor: const Color(0xFFFFFBF5),
              iconColor: const Color(0xFF241508),
              title: const Text(
                'Discover Your Style',
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF241508),
                ),
              ),
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
                          color: Color(0xFF777F84),
                        ),
                      ),
                      Text(
                        '${((currentStep + 1) / totalSteps * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Campton',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFDAF40),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (currentStep + 1) / totalSteps,
                      backgroundColor: const Color(0xFFEEEEEE),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFDAF40)),
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
                  // Update state when page changes
                  if (index != currentStep) {
                    if (index > currentStep) {
                      ref.read(styleQuizControllerProvider.notifier).nextStep();
                    } else {
                      ref.read(styleQuizControllerProvider.notifier).previousStep();
                    }
                  }
                },
                itemBuilder: (context, index) {
                  return _buildQuestionPage(styleQuizQuestions[index], stateAsync.value ?? const StyleQuizState());
                },
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ref.read(styleQuizControllerProvider.notifier).previousStep();
                          _goToPage(currentStep - 1);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF241508),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFFCCCCCC)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Previous',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Campton',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: currentStep == 0 ? 1 : 1,
                    child: ElevatedButton(
                      onPressed: state.isSubmitting
                          ? null
                          : () {
                              final question = styleQuizQuestions[currentStep];
                              if (state.answers[question.id] == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select an option'),
                                    backgroundColor: Color(0xFFE57373),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFDAF40),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        disabledBackgroundColor: const Color(0xFFCCCCCC),
                      ),
                      child: state.isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              currentStep < totalSteps - 1 ? 'Next' : 'Complete',
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'Campton',
                                fontWeight: FontWeight.w600,
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
              fontSize: 24,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: Color(0xFF241508),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          if (question.allowMultiple)
            Text(
              'Select all that apply',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Campton',
                color: const Color(0xFF241508).withOpacity(0.6),
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
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFDAF40).withOpacity(0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFFDAF40) : const Color(0xFFEEEEEE),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? const Color(0xFFFDAF40) : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? const Color(0xFFFDAF40) : const Color(0xFFCCCCCC),
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 16,
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
                            color: const Color(0xFF241508),
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
