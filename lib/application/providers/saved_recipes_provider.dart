import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dapur_pintar/application/notifiers/saved_recipes_notifier.dart';
import 'package:dapur_pintar/infrastructure/local/recipe_local_repository.dart';

final recipeLocalRepositoryProvider = Provider((ref) => RecipeLocalRepository());

final savedRecipesNotifierProvider = 
    StateNotifierProvider<SavedRecipesNotifier, SavedRecipesState>((ref) {
  final repository = ref.watch(recipeLocalRepositoryProvider);
  return SavedRecipesNotifier(repository);
});