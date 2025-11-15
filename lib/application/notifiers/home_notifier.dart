// lib/application/providers/home_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dapur_pintar/domain/models/recipe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// --- ENUM DEFINITIONS ---
enum DifficultyFilter { mudah, sedang, sulit }
enum CategoryFilter { sarapan, makanSiang, makanMalam, dessert }

/// --- STATE CLASS ---
class HomeState {
  final String searchQuery;
  final int? maxDuration;
  final DifficultyFilter? difficulty;
  final CategoryFilter? category;
  final String mustIncludeIngredient;
  final String mustNotIncludeIngredient;
  final List<String> scannedIngredients;
  final List<Recipe> recipes; // Tambahkan field ini untuk menyimpan list resep

  const HomeState({
    this.searchQuery = '',
    this.maxDuration,
    this.difficulty,
    this.category,
    this.mustIncludeIngredient = '',
    this.mustNotIncludeIngredient = '',
    this.scannedIngredients = const [],
    this.recipes = const [], // Default kosong
  });

  /// CopyWith with optional null-replacement handling
  HomeState copyWith({
    String? searchQuery,
    Object? maxDuration = _undefined,
    Object? difficulty = _undefined,
    Object? category = _undefined,
    String? mustIncludeIngredient,
    String? mustNotIncludeIngredient,
    List<String>? scannedIngredients,
    List<Recipe>? recipes, // Tambahkan parameter ini
  }) {
    return HomeState(
      searchQuery: searchQuery ?? this.searchQuery,
      maxDuration: maxDuration == _undefined ? this.maxDuration : maxDuration as int?,
      difficulty: difficulty == _undefined ? this.difficulty : difficulty as DifficultyFilter?,
      category: category == _undefined ? this.category : category as CategoryFilter?,
      mustIncludeIngredient: mustIncludeIngredient ?? this.mustIncludeIngredient,
      mustNotIncludeIngredient: mustNotIncludeIngredient ?? this.mustNotIncludeIngredient,
      scannedIngredients: scannedIngredients ?? this.scannedIngredients,
      recipes: recipes ?? this.recipes, // Tambahkan ini
    );
  }
  
  static const Object _undefined = Object();
}

/// --- NOTIFIER CLASS (Modifikasi) ---
class HomeNotifier extends StateNotifier<HomeState> {
  // REFERENSI COLLECTION FIREBASE
  final CollectionReference _recipesCollection =
      FirebaseFirestore.instance.collection('recipes');

  HomeNotifier() : super(const HomeState()) {
    loadRecipes(); // Panggil loadRecipes di constructor
  }

  // === SETTERS ===
  
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setMaxDuration(int? duration) {
    state = state.copyWith(maxDuration: duration);
  }

  void setDifficulty(DifficultyFilter? filter) {
    state = state.copyWith(difficulty: filter);
  }

  void setCategory(CategoryFilter? filter) {
    state = state.copyWith(category: filter);
  }

  void setMustIncludeIngredient(String ingredient) {
    state = state.copyWith(mustIncludeIngredient: ingredient);
  }

  void setMustNotIncludeIngredient(String ingredient) {
    state = state.copyWith(mustNotIncludeIngredient: ingredient);
  }

  // --- TAMBAHKAN SETTER BARU INI ---
  void setScannedIngredients(List<String> ingredients) {
    state = state.copyWith(scannedIngredients: ingredients);
  }
  // --- END ---

  void resetFilters() {
    state = state.copyWith(
      searchQuery: '',
      maxDuration: null,
      difficulty: null,
      category: null,
      mustIncludeIngredient: '',
      mustNotIncludeIngredient: '',
      scannedIngredients: [],
    );
  }

  // === CRUD ===
  
  Future<void> addRecipe(Recipe recipe) async {
    await _recipesCollection.add(recipe.toJson());
    await loadRecipes(); // Reload setelah add
  }

  Future<void> updateRecipe(Recipe recipe) async {
    await _recipesCollection.doc(recipe.id).update(recipe.toJson());
    await loadRecipes(); // Reload setelah update
  }

  Future<void> deleteRecipe(String id) async {
    await _recipesCollection.doc(id).delete();
    await loadRecipes(); // Reload setelah delete
  }

  // === LOAD RECIPES ===
  Future<void> loadRecipes() async {
    try {
      final snapshot = await _recipesCollection.get();
      final recipes = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Recipe.fromJson(data..['id'] = doc.id); // Asumsikan Recipe.fromJson ada
      }).toList();
      state = state.copyWith(recipes: recipes);
    } catch (e) {
      // Handle error, misalnya log atau snackbar
      print('Error loading recipes: $e');
    }
  }
}

// --- PROVIDER ---
// Provider ini sudah diubah di file providers/home_provider.dart