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
  Future<AiProductDescription?> generateDescription({
    required String name,
    required String style,
    required String tribe,
    required String gender,
    required double price,
    String? materials,
    String? occasion,
    List<String>? colors,
  }) async {
    state = AsyncData(state.value!.copyWith(isLoading: true, error: null));

    try {
      final repository = ref.read(aiRepositoryProvider);
      final description = await repository.generateDescription(
        name: name,
        style: style,
        tribe: tribe,
        gender: gender,
        price: price,
        materials: materials,
        occasion: occasion,
        colors: colors,
      );

      state = AsyncData(state.value!.copyWith(isLoading: false, description: description));
      return description;
    } catch (e) {
      state = AsyncData(state.value!.copyWith(
        isLoading: false,
        error: 'Failed to generate description: ${e.toString()}',
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

/// Provider for batch description generation
final batchDescriptionProvider = FutureProvider.family<
    List<AiProductDescription>, List<ProductDescriptionRequest>>(
  (ref, products) async {
    final repository = ref.watch(aiRepositoryProvider);
    return repository.generateBatchDescriptions(products);
  },
);
