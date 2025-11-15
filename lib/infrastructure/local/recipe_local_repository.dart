import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dapur_pintar/domain/models/recipe.dart';

class RecipeLocalRepository {
  static const String _recipesKey = 'saved_recipes';

  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }
  Future<List<Recipe>> getAllRecipes() async {
    try {
      final prefs = await _getPrefs();
      final recipesJson = prefs.getString(_recipesKey);
      if (recipesJson == null) return [];
      final List<dynamic> decoded = jsonDecode(recipesJson);
      return decoded.map((e) => Recipe.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load recipes: $e');
    }
  }
  Future<void> saveRecipe(Recipe recipe) async {
    try {
      final prefs = await _getPrefs();
      final recipes = await getAllRecipes();
      final index = recipes.indexWhere((r) => r.id == recipe.id);

      if (index != -1) {
        recipes[index] = recipe; 
      } else {
        recipes.add(recipe); 
      }

      final encoded = jsonEncode(recipes.map((r) => r.toJson()).toList());
      await prefs.setString(_recipesKey, encoded);
    } catch (e) {
      throw Exception('Failed to save recipe: $e');
    }
  }

  Future<void> removeRecipe(String id) async {
    try {
      final prefs = await _getPrefs();
      final recipes = await getAllRecipes();
      recipes.removeWhere((r) => r.id == id);
      final encoded = jsonEncode(recipes.map((r) => r.toJson()).toList());
      await prefs.setString(_recipesKey, encoded);
    } catch (e) {
      throw Exception('Failed to remove recipe: $e');
    }
  }
  Future<bool> isRecipeSaved(String id) async {
    try {
      final recipes = await getAllRecipes();
      return recipes.any((r) => r.id == id);
    } catch (e) {
      throw Exception('Failed to check if recipe is saved: $e');
    }
  }
  Future<void> updateRecipe(Recipe updatedRecipe) async {
  try {
    final prefs = await _getPrefs();
    final recipes = await getAllRecipes();
    final index = recipes.indexWhere((r) => r.id == updatedRecipe.id);

    if (index != -1) {
      recipes[index] = updatedRecipe;
      final encoded = jsonEncode(recipes.map((r) => r.toJson()).toList());
      await prefs.setString(_recipesKey, encoded);
    } else {
      print('Recipe with id ${updatedRecipe.id} not found in favorites');
    }
  } catch (e) {
    throw Exception('Failed to update recipe: $e');
  }
}

}
