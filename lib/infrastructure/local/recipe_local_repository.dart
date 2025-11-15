import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dapur_pintar/domain/models/recipe.dart';

/// Repository class untuk mengelola penyimpanan dan pengambilan data resep secara lokal
/// Menggunakan SharedPreferences untuk menyimpan data di local storage device
/// 
/// Fitur:
/// - Simpan resep favorit ke local storage
/// - Ambil semua resep favorit dari local storage
/// - Hapus resep favorit
/// - Cek apakah resep sudah disimpan
/// - Update resep yang sudah ada
class RecipeLocalRepository {
  /// Key untuk menyimpan data resep di SharedPreferences
  /// Data disimpan sebagai JSON string dengan key ini
  static const String _recipesKey = 'saved_recipes';

  /// Method helper untuk mendapatkan instance SharedPreferences
  /// 
  /// Return: SharedPreferences instance untuk mengakses local storage
  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  /// Mengambil semua resep yang disimpan dari local storage
  /// Data disimpan sebagai JSON string, dikonversi kembali ke List<Recipe>
  /// 
  /// Return: List dari Recipe yang telah disimpan
  /// Jika tidak ada resep, return empty list []
  /// 
  /// Throw: Exception jika gagal load resep
  Future<List<Recipe>> getAllRecipes() async {
    try {
      final prefs = await _getPrefs();
      /// Ambil data JSON dari SharedPreferences dengan key 'saved_recipes'
      final recipesJson = prefs.getString(_recipesKey);
      /// Jika tidak ada data, return empty list
      if (recipesJson == null) return [];
      /// Decode JSON string menjadi List<dynamic>
      final List<dynamic> decoded = jsonDecode(recipesJson);
      /// Konversi setiap item menjadi Recipe object
      return decoded.map((e) => Recipe.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load recipes: $e');
    }
  }

  /// Simpan atau update resep ke local storage
  /// Jika resep dengan ID yang sama sudah ada, akan di-update
  /// Jika belum ada, akan ditambah ke list
  /// 
  /// Parameter:
  /// - recipe: Recipe object yang akan disimpan
  /// 
  /// Throw: Exception jika gagal menyimpan resep
  Future<void> saveRecipe(Recipe recipe) async {
    try {
      final prefs = await _getPrefs();
      /// Ambil semua resep yang sudah ada
      final recipes = await getAllRecipes();
      /// Cari index resep dengan ID yang sama
      final index = recipes.indexWhere((r) => r.id == recipe.id);

      if (index != -1) {
        /// Jika resep dengan ID sama sudah ada, update (replace) di list
        recipes[index] = recipe; 
      } else {
        /// Jika belum ada, tambahkan ke list
        recipes.add(recipe); 
      }

      /// Encode list resep ke JSON string
      final encoded = jsonEncode(recipes.map((r) => r.toJson()).toList());
      /// Simpan ke SharedPreferences
      await prefs.setString(_recipesKey, encoded);
    } catch (e) {
      throw Exception('Failed to save recipe: $e');
    }
  }

  /// Hapus resep dari local storage berdasarkan ID
  /// 
  /// Parameter:
  /// - id: ID resep yang akan dihapus
  /// 
  /// Throw: Exception jika gagal menghapus resep
  Future<void> removeRecipe(String id) async {
    try {
      final prefs = await _getPrefs();
      /// Ambil semua resep yang sudah ada
      final recipes = await getAllRecipes();
      /// Hapus resep dengan ID yang matching
      recipes.removeWhere((r) => r.id == id);
      /// Encode list resep yang sudah dihapus ke JSON string
      final encoded = jsonEncode(recipes.map((r) => r.toJson()).toList());
      /// Simpan kembali ke SharedPreferences (dengan resep yang sudah dihapus)
      await prefs.setString(_recipesKey, encoded);
    } catch (e) {
      throw Exception('Failed to remove recipe: $e');
    }
  }

  /// Cek apakah resep dengan ID tertentu sudah disimpan/tersedia
  /// 
  /// Parameter:
  /// - id: ID resep yang akan dicek
  /// 
  /// Return: true jika resep sudah disimpan, false jika belum
  /// 
  /// Throw: Exception jika gagal mengecek resep
  Future<bool> isRecipeSaved(String id) async {
    try {
      /// Ambil semua resep yang sudah ada
      final recipes = await getAllRecipes();
      /// Cek apakah ada resep dengan ID yang matching
      return recipes.any((r) => r.id == id);
    } catch (e) {
      throw Exception('Failed to check if recipe is saved: $e');
    }
  }

  /// Update resep yang sudah disimpan
  /// Hanya update jika resep dengan ID tersebut sudah ada
  /// Jika tidak ada, log print message
  /// 
  /// Parameter:
  /// - updatedRecipe: Recipe object yang sudah diupdate
  /// 
  /// Throw: Exception jika gagal update resep
  Future<void> updateRecipe(Recipe updatedRecipe) async {
    try {
      final prefs = await _getPrefs();
      /// Ambil semua resep yang sudah ada
      final recipes = await getAllRecipes();
      /// Cari index resep dengan ID yang sama
      final index = recipes.indexWhere((r) => r.id == updatedRecipe.id);

      if (index != -1) {
        /// Jika resep dengan ID sama ada, replace dengan recipe yang baru
        recipes[index] = updatedRecipe;
        /// Encode list resep ke JSON string
        final encoded = jsonEncode(recipes.map((r) => r.toJson()).toList());
        /// Simpan kembali ke SharedPreferences
        await prefs.setString(_recipesKey, encoded);
      } else {
        /// Jika tidak ada, log print message
        print('Recipe with id ${updatedRecipe.id} not found in favorites');
      }
    } catch (e) {
      throw Exception('Failed to update recipe: $e');
    }
  }
}
