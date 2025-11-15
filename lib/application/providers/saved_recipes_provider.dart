import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dapur_pintar/application/notifiers/saved_recipes_notifier.dart';
import 'package:dapur_pintar/infrastructure/local/recipe_local_repository.dart';

/// Provider untuk RecipeLocalRepository
/// Menyediakan instance dari repository untuk akses data local (SharedPreferences)
/// Diperlukan oleh SavedRecipesNotifier untuk CRUD operations
/// 
/// Penggunaan:
/// ```dart
/// final repository = ref.watch(recipeLocalRepositoryProvider);
/// ```
final recipeLocalRepositoryProvider = Provider((ref) => RecipeLocalRepository());

/// Provider untuk SavedRecipesNotifier dan SavedRecipesState
/// Mengelola state untuk fitur resep yang disimpan/favorit user
/// State mencakup: savedRecipes (list resep favorit), isLoading (status loading)
/// 
/// Provider ini bergantung pada recipeLocalRepositoryProvider untuk akses data
/// 
/// Penggunaan:
/// ```dart
/// final state = ref.watch(savedRecipesNotifierProvider);
/// final notifier = ref.read(savedRecipesNotifierProvider.notifier);
/// ```
final savedRecipesNotifierProvider = 
    StateNotifierProvider<SavedRecipesNotifier, SavedRecipesState>((ref) {
  /// Mendapatkan instance repository dari provider
  final repository = ref.watch(recipeLocalRepositoryProvider);
  /// Membuat instance baru dari SavedRecipesNotifier dengan repository
  /// SavedRecipesNotifier akan handle semua logic untuk saved recipes management
  return SavedRecipesNotifier(repository);
});