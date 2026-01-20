import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/ai_repository.dart';
import '../../domain/ai_models.dart';

/// State for Cultural AI Chat
class AiChatState {
  const AiChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  final List<AiChatMessage> messages;
  final bool isLoading;
  final String? error;

  AiChatState copyWith({
    List<AiChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Controller for Cultural Context AI Chat
class AiChatController extends AsyncNotifier<AiChatState> {
  @override
  FutureOr<AiChatState> build() {
    return const AiChatState();
  }

  /// Initialize chat with user ID and load history
  Future<void> initialize(String userId) async {
    state = AsyncData(state.value!.copyWith(isLoading: true, error: null));

    try {
      final repository = ref.read(aiRepositoryProvider);
      final history = await repository.getChatHistory(userId);
      state = AsyncData(state.value!.copyWith(messages: history, isLoading: false));
    } catch (e) {
      // If no history, start fresh
      state = AsyncData(state.value!.copyWith(messages: [], isLoading: false));
    }
  }

  /// Send a message to the AI assistant
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message immediately
    final userMessage = AiChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final currentMessages = state.value?.messages ?? [];
    state = AsyncData(state.value!.copyWith(
      messages: [...currentMessages, userMessage],
      isLoading: true,
      error: null,
    ));

    try {
      final repository = ref.read(aiRepositoryProvider);
      final response = await repository.sendMessage(
        message: message,
      );

      final updatedMessages = [...currentMessages, userMessage, response];
      state = AsyncData(AiChatState(
        messages: updatedMessages,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      state = AsyncData(state.value!.copyWith(
        isLoading: false,
        error: 'Failed to get response: ${e.toString()}',
      ));
    }
  }

  /// Send a suggested question
  Future<void> sendSuggestion(String suggestion) async {
    await sendMessage(suggestion);
  }

  /// Clear chat history
  void clearChat() {
    state = const AsyncData(AiChatState());
  }
}

/// Provider for AI Chat Controller
final aiChatControllerProvider =
    AsyncNotifierProvider<AiChatController, AiChatState>(AiChatController.new);

/// Default suggested questions for new users
final defaultChatSuggestions = [
  'What traditional Nigerian outfit should I wear to a wedding?',
  'Tell me about Yoruba fashion styles',
  'What colors are trending for Ankara designs?',
  'How do I style an Agbada for a formal event?',
  'What is the significance of Aso-Oke?',
];
