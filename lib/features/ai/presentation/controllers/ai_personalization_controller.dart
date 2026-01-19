import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/ai_repository.dart';
import '../../domain/ai_models.dart';

/// State for Style DNA Quiz
class StyleQuizState {
  const StyleQuizState({
    this.currentStep = 0,
    this.answers = const {},
    this.isSubmitting = false,
    this.profile,
    this.error,
  });

  final int currentStep;
  final Map<String, String> answers;
  final bool isSubmitting;
  final StyleDnaProfile? profile;
  final String? error;

  StyleQuizState copyWith({
    int? currentStep,
    Map<String, String>? answers,
    bool? isSubmitting,
    StyleDnaProfile? profile,
    String? error,
  }) {
    return StyleQuizState(
      currentStep: currentStep ?? this.currentStep,
      answers: answers ?? this.answers,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      profile: profile ?? this.profile,
      error: error,
    );
  }
}

/// Controller for Style DNA Quiz
class StyleQuizController extends AsyncNotifier<StyleQuizState> {
  @override
  FutureOr<StyleQuizState> build() {
    return const StyleQuizState();
  }

  /// Answer a question
  void answerQuestion(String questionId, String answer) {
    final currentState = state.value ?? const StyleQuizState();
    final newAnswers = Map<String, String>.from(currentState.answers);
    newAnswers[questionId] = answer;
    state = AsyncData(currentState.copyWith(answers: newAnswers));
  }

  /// Go to next step
  void nextStep() {
    final currentState = state.value ?? const StyleQuizState();
    state = AsyncData(currentState.copyWith(currentStep: currentState.currentStep + 1));
  }

  /// Go to previous step
  void previousStep() {
    final currentState = state.value ?? const StyleQuizState();
    if (currentState.currentStep > 0) {
      state = AsyncData(currentState.copyWith(currentStep: currentState.currentStep - 1));
    }
  }

  /// Submit the quiz
  Future<StyleDnaProfile?> submitQuiz(String userId) async {
    final currentState = state.value ?? const StyleQuizState();
    state = AsyncData(currentState.copyWith(isSubmitting: true, error: null));

    try {
      final repository = ref.read(aiRepositoryProvider);
      final answers = currentState.answers.entries
          .map((e) => StyleQuizAnswer(questionId: e.key, answer: e.value))
          .toList();

      final profile = await repository.submitStyleQuiz(
        userId: userId,
        answers: answers,
      );

      state = AsyncData(currentState.copyWith(isSubmitting: false, profile: profile));
      return profile;
    } catch (e) {
      state = AsyncData(currentState.copyWith(
        isSubmitting: false,
        error: 'Failed to submit quiz: ${e.toString()}',
      ));
      return null;
    }
  }

  /// Reset the quiz
  void reset() {
    state = const AsyncData(StyleQuizState());
  }
}

/// Provider for Style Quiz Controller
final styleQuizControllerProvider =
    AsyncNotifierProvider<StyleQuizController, StyleQuizState>(StyleQuizController.new);

/// Provider for user's style profile
final styleProfileProvider = FutureProvider.family<StyleDnaProfile?, String>(
  (ref, userId) async {
    final repository = ref.watch(aiRepositoryProvider);
    return repository.getStyleProfile(userId);
  },
);

/// Provider for personalized recommendations
final personalizedRecommendationsProvider =
    FutureProvider.family<List<PersonalizedRecommendation>, String>(
  (ref, userId) async {
    final repository = ref.watch(aiRepositoryProvider);
    return repository.getRecommendations(userId: userId, limit: 20);
  },
);

/// Provider for personal trends
final personalTrendsProvider = FutureProvider.family<TrendData, String>(
  (ref, userId) async {
    final repository = ref.watch(aiRepositoryProvider);
    return repository.getPersonalTrends(userId);
  },
);

/// Style Quiz Questions
class StyleQuizQuestion {
  const StyleQuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    this.imageOptions,
    this.allowMultiple = false,
  });

  final String id;
  final String question;
  final List<String> options;
  final List<String>? imageOptions;
  final bool allowMultiple;
}

/// Default style quiz questions
final styleQuizQuestions = [
  const StyleQuizQuestion(
    id: 'style_preference',
    question: 'What style resonates with you most?',
    options: ['Traditional', 'Modern', 'Fusion', 'Minimalist', 'Bold & Vibrant'],
  ),
  const StyleQuizQuestion(
    id: 'tribe_interest',
    question: 'Which cultural styles interest you?',
    options: ['Yoruba', 'Igbo', 'Hausa', 'Edo', 'All Nigerian Cultures'],
    allowMultiple: true,
  ),
  const StyleQuizQuestion(
    id: 'occasion_focus',
    question: 'What occasions do you usually dress for?',
    options: ['Everyday Casual', 'Work/Office', 'Weddings & Events', 'Religious Gatherings', 'All Occasions'],
    allowMultiple: true,
  ),
  const StyleQuizQuestion(
    id: 'color_preference',
    question: 'What colors do you gravitate towards?',
    options: ['Earth Tones', 'Bold & Bright', 'Pastels', 'Neutrals', 'Jewel Tones'],
    allowMultiple: true,
  ),
  const StyleQuizQuestion(
    id: 'fabric_preference',
    question: 'What fabrics do you prefer?',
    options: ['Ankara/African Print', 'Aso-Oke', 'Lace', 'Cotton', 'Silk & Satin'],
    allowMultiple: true,
  ),
  const StyleQuizQuestion(
    id: 'fashion_goal',
    question: 'What\'s your fashion goal?',
    options: ['Express My Heritage', 'Stand Out', 'Comfort First', 'Professional Look', 'Sustainable Fashion'],
  ),
  const StyleQuizQuestion(
    id: 'budget_range',
    question: 'What\'s your typical budget for an outfit?',
    options: ['Under ₦20,000', '₦20,000 - ₦50,000', '₦50,000 - ₦100,000', '₦100,000 - ₦200,000', 'Above ₦200,000'],
  ),
];
