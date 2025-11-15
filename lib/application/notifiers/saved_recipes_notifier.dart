import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dapur_pintar/domain/models/recipe.dart';
import 'package:dapur_pintar/infrastructure/local/recipe_local_repository.dart';

/// --- STATE CLASS ---
class SavedRecipesState {
  final List<Recipe> savedRecipes;
  final bool isLoading;

  SavedRecipesState({
    required this.savedRecipes,
    this.isLoading = false,
  });

  SavedRecipesState copyWith({
    List<Recipe>? savedRecipes,
    bool? isLoading,
  }) {
    return SavedRecipesState(
      savedRecipes: savedRecipes ?? this.savedRecipes,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// --- STATE NOTIFIER ---
class SavedRecipesNotifier extends StateNotifier<SavedRecipesState> {
  final RecipeLocalRepository _repository;

  SavedRecipesNotifier(this._repository)
      : super(SavedRecipesState(savedRecipes: [])) {
    loadSavedRecipes();
  }

  Future<void> loadSavedRecipes() async {
    state = state.copyWith(isLoading: true);
    try {
      final recipes = await _repository.getAllRecipes();
      state = state.copyWith(savedRecipes: recipes, isLoading: false);
    } catch (e) {
      print('Error loading saved recipes: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> saveRecipe(Recipe recipe) async {
    try {
      await _repository.saveRecipe(recipe);
      await loadSavedRecipes();
    } catch (e) {
      print('Error saving recipe: $e');
    }
  }

  Future<void> removeRecipe(String id) async {
    try {
      await _repository.removeRecipe(id);
      await loadSavedRecipes();
    } catch (e) {
      print('Error removing recipe: $e');
    }
  }

  Future<void> updateRecipe(Recipe updatedRecipe) async {
    try {
      await _repository.updateRecipe(updatedRecipe);
      final updatedList = state.savedRecipes.map((recipe) {
        return recipe.id == updatedRecipe.id ? updatedRecipe : recipe;
      }).toList();
      state = state.copyWith(savedRecipes: updatedList);
    } catch (e) {
      print('Error updating saved recipe: $e');
    }
  }

  Future<bool> isRecipeSaved(String id) async {
    try {
      return await _repository.isRecipeSaved(id);
    } catch (e) {
      print('Error checking if recipe is saved: $e');
      return false;
    }
  }
}
