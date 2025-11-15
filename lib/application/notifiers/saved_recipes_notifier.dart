import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dapur_pintar/domain/models/recipe.dart';
import 'package:dapur_pintar/infrastructure/local/recipe_local_repository.dart';

/// ============================================================================
/// STATE CLASS - Mendefinisikan state untuk saved recipes screen
/// ============================================================================

/// Class yang merepresentasikan state di saved recipes screen
/// Menyimpan list resep yang disimpan user dan status loading
class SavedRecipesState {
  /// List semua resep yang telah disimpan user sebagai favorit
  /// Disimpan di local storage menggunakan SharedPreferences
  final List<Recipe> savedRecipes;
  
  /// Flag untuk menandakan apakah sedang loading data
  /// Digunakan untuk menampilkan loading indicator di UI
  final bool isLoading;

  /// Constructor untuk membuat instance SavedRecipesState
  /// 
  /// Parameter:
  /// - savedRecipes: List resep yang disimpan (wajib diisi)
  /// - isLoading: Status loading (default: false)
  SavedRecipesState({
    required this.savedRecipes,
    this.isLoading = false,
  });

  /// Method copyWith untuk membuat copy dari state dengan beberapa field yang diubah
  /// Digunakan untuk immutable state management
  /// 
  /// Return: SavedRecipesState baru dengan field yang diupdate
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

/// ============================================================================
/// STATE NOTIFIER - Logic untuk mengelola saved recipes state
/// ============================================================================

/// StateNotifier untuk mengelola SavedRecipesState
/// Menangani semua operasi untuk saved/favorite recipes
class SavedRecipesNotifier extends StateNotifier<SavedRecipesState> {
  /// Reference ke repository local untuk akses SharedPreferences
  /// Digunakan untuk CRUD operations terhadap resep favorit
  final RecipeLocalRepository _repository;

  /// Constructor untuk SavedRecipesNotifier
  /// 
  /// Parameter:
  /// - repository: RecipeLocalRepository untuk akses data local
  /// 
  /// Process:
  /// 1. Inisialisasi state awal dengan empty list
  /// 2. Secara otomatis load saved recipes dari local storage
  SavedRecipesNotifier(this._repository)
      : super(SavedRecipesState(savedRecipes: [])) {
    /// Load saved recipes dari local storage saat aplikasi mulai
    loadSavedRecipes();
  }

  /// Load semua resep favorit dari local storage
  /// Dipanggil saat aplikasi pertama kali dimulai dan setelah CRUD operations
  /// 
  /// Process:
  /// 1. Set state isLoading menjadi true
  /// 2. Query resep dari repository
  /// 3. Update state dengan list resep yang diambil
  /// 4. Set isLoading menjadi false
  /// 5. Jika error, print error message dan set isLoading false
  Future<void> loadSavedRecipes() async {
    /// Set loading flag menjadi true
    state = state.copyWith(isLoading: true);
    try {
      /// Query semua resep favorit dari local storage
      final recipes = await _repository.getAllRecipes();
      /// Update state dengan resep yang diambil dan set isLoading false
      state = state.copyWith(savedRecipes: recipes, isLoading: false);
    } catch (e) {
      /// Jika error, print error dan set isLoading false
      print('Error loading saved recipes: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// Simpan resep ke local storage (menambahkan ke favorit)
  /// Setelah disimpan, reload list resep favorit dari local storage
  /// 
  /// Parameter:
  /// - recipe: Recipe object yang akan disimpan ke favorit
  /// 
  /// Process:
  /// 1. Simpan recipe ke repository (local storage)
  /// 2. Reload list resep favorit
  /// 3. Jika error, print error message
  Future<void> saveRecipe(Recipe recipe) async {
    try {
      /// Simpan recipe ke local storage (SharedPreferences)
      await _repository.saveRecipe(recipe);
      /// Reload list resep favorit untuk update state
      await loadSavedRecipes();
    } catch (e) {
      /// Jika error, print error message
      print('Error saving recipe: $e');
    }
  }

  /// Hapus resep dari local storage (menghapus dari favorit)
  /// Setelah dihapus, reload list resep favorit dari local storage
  /// 
  /// Parameter:
  /// - id: ID resep yang akan dihapus dari favorit
  /// 
  /// Process:
  /// 1. Hapus recipe dari repository (local storage)
  /// 2. Reload list resep favorit
  /// 3. Jika error, print error message
  Future<void> removeRecipe(String id) async {
    try {
      /// Hapus recipe dari local storage (SharedPreferences) berdasarkan ID
      await _repository.removeRecipe(id);
      /// Reload list resep favorit untuk update state
      await loadSavedRecipes();
    } catch (e) {
      /// Jika error, print error message
      print('Error removing recipe: $e');
    }
  }

  /// Update resep yang sudah disimpan di local storage
  /// Hanya mengupdate resep yang ID-nya cocok, tidak menambah resep baru
  /// 
  /// Parameter:
  /// - updatedRecipe: Recipe object dengan data yang sudah diupdate
  /// 
  /// Process:
  /// 1. Update recipe di repository (local storage)
  /// 2. Update list state dengan resep yang diupdate
  /// 3. Jika error, print error message
  Future<void> updateRecipe(Recipe updatedRecipe) async {
    try {
      /// Update recipe di local storage (SharedPreferences)
      await _repository.updateRecipe(updatedRecipe);
      /// Update list state dengan recipe yang sudah diupdate
      /// Mencari recipe dengan ID yang sama dan replace dengan yang baru
      final updatedList = state.savedRecipes.map((recipe) {
        return recipe.id == updatedRecipe.id ? updatedRecipe : recipe;
      }).toList();
      /// Update state dengan list yang sudah diupdate
      state = state.copyWith(savedRecipes: updatedList);
    } catch (e) {
      /// Jika error, print error message
      print('Error updating saved recipe: $e');
    }
  }

  /// Cek apakah resep dengan ID tertentu sudah disimpan di favorit
  /// 
  /// Parameter:
  /// - id: ID resep yang akan dicek
  /// 
  /// Return: true jika resep sudah disimpan, false jika belum
  /// 
  /// Throw: Exception dari repository jika ada error
  Future<bool> isRecipeSaved(String id) async {
    try {
      /// Query repository untuk cek apakah recipe dengan ID ini sudah disimpan
      return await _repository.isRecipeSaved(id);
    } catch (e) {
      /// Jika error, print dan return false
      print('Error checking if recipe is saved: $e');
      return false;
    }
  }
}
