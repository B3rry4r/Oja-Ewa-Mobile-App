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
  final Map<String, dynamic> answers;
  final bool isSubmitting;
  final StyleDnaProfile? profile;
  final String? error;

  StyleQuizState copyWith({
    int? currentStep,
    Map<String, dynamic>? answers,
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

  /// Answer a question - stores in the format the API expects
  void answerQuestion(String questionId, dynamic answer) {
    final currentState = state.value ?? const StyleQuizState();
    final newAnswers = Map<String, dynamic>.from(currentState.answers);
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
  /// POST /ai/buyer/style-quiz with { answers: { preferredStyle, favoriteColors[], ... } }
  Future<StyleDnaProfile?> submitQuiz(String userId) async {
    final currentState = state.value ?? const StyleQuizState();
    state = AsyncData(currentState.copyWith(isSubmitting: true, error: null));

    try {
      final repository = ref.read(aiRepositoryProvider);
      
      // Convert our answers to the API format
      final apiAnswers = _convertToApiFormat(currentState.answers);
      
      final profile = await repository.submitStyleQuiz(
        userId: userId,
        answers: apiAnswers,
      );

      state = AsyncData(currentState.copyWith(isSubmitting: false, profile: profile));
      return profile;
    } catch (e) {
      state = AsyncData(currentState.copyWith(
        isSubmitting: false,
        error: 'Failed to submit quiz. Please try again.',
      ));
      return null;
    }
  }

  /// Convert quiz answers to the API expected format
  Map<String, dynamic> _convertToApiFormat(Map<String, dynamic> answers) {
    return {
      'preferredStyle': answers['style_preference'] ?? 'modern',
      'favoriteColors': _toList(answers['color_preference']),
      'occasions': _toList(answers['occasion_focus']),
      'budgetRange': _mapBudget(answers['budget_range']),
      'culturalPreference': _toList(answers['tribe_interest']),
      'fitPreference': answers['fashion_goal'] ?? 'comfortable',
      'patternPreference': answers['fabric_preference'] ?? 'mixed',
    };
  }

  List<String> _toList(dynamic value) {
    if (value is List) return value.cast<String>();
    if (value is String) return [value];
    return [];
  }

  String _mapBudget(dynamic value) {
    if (value == null) return 'mid-range';
    final str = value.toString().toLowerCase();
    if (str.contains('under') || str.contains('20,000')) return 'budget';
    if (str.contains('200,000') || str.contains('above')) return 'luxury';
    if (str.contains('100,000')) return 'premium';
    return 'mid-range';
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

/// Style Quiz Questions - matching what the API expects
class StyleQuizQuestion {
  const StyleQuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    this.allowMultiple = false,
  });

  final String id;
  final String question;
  final List<String> options;
  final bool allowMultiple;
}

/// Style quiz questions that map to API format
final styleQuizQuestions = [
  const StyleQuizQuestion(
    id: 'style_preference',
    question: 'What style resonates with you most?',
    options: ['Traditional', 'Modern', 'Fusion', 'Minimalist', 'Bold & Vibrant'],
  ),
  const StyleQuizQuestion(
    id: 'color_preference',
    question: 'What colors do you gravitate towards?',
    options: ['Earth Tones', 'Bold & Bright', 'Pastels', 'Neutrals', 'Jewel Tones'],
    allowMultiple: true,
  ),
  const StyleQuizQuestion(
    id: 'occasion_focus',
    question: 'What occasions do you usually dress for?',
    options: ['Casual', 'Work', 'Traditional Events', 'Parties', 'All Occasions'],
    allowMultiple: true,
  ),
  const StyleQuizQuestion(
    id: 'tribe_interest',
    question: 'Which cultural styles interest you?',
    options: ['Yoruba', 'Igbo', 'Hausa', 'Edo', 'Modern African'],
    allowMultiple: true,
  ),
  const StyleQuizQuestion(
    id: 'fabric_preference',
    question: 'What patterns do you prefer?',
    options: ['Bold Prints', 'Subtle Patterns', 'Solid Colors', 'Mixed', 'Traditional Motifs'],
  ),
  const StyleQuizQuestion(
    id: 'fashion_goal',
    question: 'How do you like your clothes to fit?',
    options: ['Fitted', 'Relaxed', 'Oversized', 'Tailored', 'Comfortable'],
  ),
  const StyleQuizQuestion(
    id: 'budget_range',
    question: 'What\'s your typical budget for an outfit?',
    options: ['Under ₦20,000', '₦20,000 - ₦50,000', '₦50,000 - ₦100,000', '₦100,000 - ₦200,000', 'Above ₦200,000'],
  ),
];
