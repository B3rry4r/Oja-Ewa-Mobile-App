import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/ai_repository.dart';
import '../../domain/ai_models.dart';

/// State for AI Product Description generation
class AiDescriptionState {
  const AiDescriptionState({
    this.isLoading = false,
    this.description,
    this.error,
  });

  final bool isLoading;
  final AiProductDescription? description;
  final String? error;

  AiDescriptionState copyWith({
    bool? isLoading,
    AiProductDescription? description,
    String? error,
  }) {
    return AiDescriptionState(
      isLoading: isLoading ?? this.isLoading,
      description: description ?? this.description,
      error: error,
    );
  }
}

/// Controller for Smart Product Description generation
class AiDescriptionController extends AsyncNotifier<AiDescriptionState> {
  @override
  FutureOr<AiDescriptionState> build() {
    return const AiDescriptionState();
  }

  /// Generate AI description for a product
  /// Uses POST /ai/seller/products/generate-description
  Future<AiProductDescription?> generateDescription({
    required String name,
    required String category,
    String? fabric,
    String? style,
    String? occasion,
  }) async {
    state = AsyncData(state.value!.copyWith(isLoading: true, error: null));

    try {
      final repository = ref.read(aiRepositoryProvider);
      final description = await repository.generateDescription(
        name: name,
        category: category,
        fabric: fabric,
        style: style,
        occasion: occasion,
      );

      state = AsyncData(state.value!.copyWith(isLoading: false, description: description));
      return description;
    } catch (e) {
      state = AsyncData(state.value!.copyWith(
        isLoading: false,
        error: 'Failed to generate description. Please try again.',
      ));
      return null;
    }
  }

  /// Clear the current description
  void clear() {
    state = const AsyncData(AiDescriptionState());
  }
}

/// Provider for AI Description Controller
final aiDescriptionControllerProvider =
    AsyncNotifierProvider<AiDescriptionController, AiDescriptionState>(
        AiDescriptionController.new);
