/// File untuk state management home screen menggunakan Riverpod StateNotifier
/// Mengelola semua state dan logic yang berkaitan dengan home screen

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dapur_pintar/domain/models/recipe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// ============================================================================
/// ENUM DEFINITIONS - Mendefinisikan opsi filter yang tersedia
/// ============================================================================

/// Enum untuk tingkat kesulitan filter resep
/// mudah: Resep mudah (durasi <= 20 menit, tahapan sederhana)
/// sedang: Resep sedang (durasi 20-40 menit, tahapan sedang)
/// sulit: Resep sulit (durasi > 40 menit, tahapan kompleks)
enum DifficultyFilter { mudah, sedang, sulit }

/// Enum untuk kategori filter resep
/// sarapan: Menu sarapan/breakfast
/// makanSiang: Menu makan siang/lunch
/// makanMalam: Menu makan malam/dinner
/// dessert: Menu dessert/penutup
enum CategoryFilter { sarapan, makanSiang, makanMalam, dessert }

/// ============================================================================
/// STATE CLASS - Mendefinisikan semua state yang dikelola di home screen
/// ============================================================================

/// Class yang merepresentasikan state/kondisi di home screen
/// Menyimpan semua filter dan data yang diperlukan untuk menampilkan list resep
class HomeState {
  /// Query pencarian berdasarkan judul/nama resep
  /// User mengetik untuk mencari resep dengan kata kunci tertentu
  final String searchQuery;
  
  /// Durasi maksimal memasak dalam menit
  /// Nilai khusus: -1 untuk "> 30 menit", null untuk tidak ada filter
  final int? maxDuration;
  
  /// Filter tingkat kesulitan yang dipilih
  /// null jika tidak ada filter kesulitan yang aktif
  final DifficultyFilter? difficulty;
  
  /// Filter kategori yang dipilih
  /// null jika tidak ada filter kategori yang aktif
  final CategoryFilter? category;
  
  /// Filter bahan yang harus ada dalam resep
  /// Resep hanya ditampilkan jika mengandung bahan ini
  final String mustIncludeIngredient;
  
  /// Filter bahan yang tidak boleh ada dalam resep
  /// Resep tidak ditampilkan jika mengandung bahan ini
  final String mustNotIncludeIngredient;
  
  /// List bahan yang terdeteksi dari fitur scan kamera
  /// Digunakan untuk mencari resep yang menggunakan bahan-bahan ini
  final List<String> scannedIngredients;
  
  /// List seluruh resep yang tersedia dari Firestore
  /// Digunakan sebagai data source untuk filter dan display
  final List<Recipe> recipes;

  /// Constructor untuk membuat instance HomeState
  /// Semua parameter memiliki default value kecuali jika dideklarasikan required
  const HomeState({
    this.searchQuery = '', // Default: search query kosong
    this.maxDuration, // Default: null (tidak ada filter durasi)
    this.difficulty, // Default: null (tidak ada filter kesulitan)
    this.category, // Default: null (tidak ada filter kategori)
    this.mustIncludeIngredient = '', // Default: tidak ada filter bahan yang harus ada
    this.mustNotIncludeIngredient = '', // Default: tidak ada filter bahan yang harus jauhi
    this.scannedIngredients = const [], // Default: list kosong
    this.recipes = const [], // Default: list kosong
  });

  /// Method copyWith untuk membuat copy dari state dengan beberapa field yang diubah
  /// Digunakan untuk immutable state management
  /// Menggunakan _undefined sentinel untuk membedakan null value dengan "tidak diubah"
  /// 
  /// Return: HomeState baru dengan field yang diupdate
  HomeState copyWith({
    String? searchQuery,
    Object? maxDuration = _undefined, // Gunakan sentinel untuk nullable fields
    Object? difficulty = _undefined,
    Object? category = _undefined,
    String? mustIncludeIngredient,
    String? mustNotIncludeIngredient,
    List<String>? scannedIngredients,
    List<Recipe>? recipes,
  }) {
    return HomeState(
      searchQuery: searchQuery ?? this.searchQuery,
      // Cek apakah value adalah sentinel, jika ya gunakan value saat ini, jika tidak gunakan value baru
      maxDuration: maxDuration == _undefined ? this.maxDuration : maxDuration as int?,
      difficulty: difficulty == _undefined ? this.difficulty : difficulty as DifficultyFilter?,
      category: category == _undefined ? this.category : category as CategoryFilter?,
      mustIncludeIngredient: mustIncludeIngredient ?? this.mustIncludeIngredient,
      mustNotIncludeIngredient: mustNotIncludeIngredient ?? this.mustNotIncludeIngredient,
      scannedIngredients: scannedIngredients ?? this.scannedIngredients,
      recipes: recipes ?? this.recipes,
    );
  }
  
  /// Sentinel object untuk membedakan null value dengan "tidak diubah" di copyWith
  static const Object _undefined = Object();
}

/// ============================================================================
/// NOTIFIER CLASS - Logic untuk mengelola state di home screen
/// ============================================================================

/// StateNotifier untuk mengelola HomeState
/// Extends StateNotifier<HomeState> artinya memanage HomeState dan bisa notify listeners saat state berubah
class HomeNotifier extends StateNotifier<HomeState> {
  /// Reference ke Firestore collection 'recipes'
  /// Digunakan untuk melakukan CRUD operations (Create, Read, Update, Delete) terhadap resep
  final CollectionReference _recipesCollection =
      FirebaseFirestore.instance.collection('recipes');

  /// Constructor untuk HomeNotifier
  /// Menginisialisasi dengan state awal (empty HomeState)
  /// Dan secara otomatis load resep dari Firestore
  HomeNotifier() : super(const HomeState()) {
    loadRecipes(); // Load resep dari Firestore saat aplikasi dimulai
  }

  // ============================================================================
  // SETTERS - Method untuk mengubah state
  // ============================================================================
  
  /// Set query pencarian
  /// User mengetik di search bar untuk mencari resep
  /// 
  /// Parameter:
  /// - query: String yang diketik user untuk mencari
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Set filter durasi maksimal memasak
  /// 
  /// Parameter:
  /// - duration: Durasi maksimal dalam menit (null untuk reset filter)
  void setMaxDuration(int? duration) {
    state = state.copyWith(maxDuration: duration);
  }

  /// Set filter tingkat kesulitan
  /// 
  /// Parameter:
  /// - filter: Difficulty yang dipilih (null untuk reset filter)
  void setDifficulty(DifficultyFilter? filter) {
    state = state.copyWith(difficulty: filter);
  }

  /// Set filter kategori
  /// 
  /// Parameter:
  /// - filter: Kategori yang dipilih (null untuk reset filter)
  void setCategory(CategoryFilter? filter) {
    state = state.copyWith(category: filter);
  }

  /// Set filter bahan yang harus ada dalam resep
  /// Hanya menampilkan resep yang mengandung bahan ini
  /// 
  /// Parameter:
  /// - ingredient: Nama bahan yang harus ada (kosong untuk reset filter)
  void setMustIncludeIngredient(String ingredient) {
    state = state.copyWith(mustIncludeIngredient: ingredient);
  }

  /// Set filter bahan yang tidak boleh ada dalam resep
  /// Tidak menampilkan resep yang mengandung bahan ini
  /// 
  /// Parameter:
  /// - ingredient: Nama bahan yang harus dijauhi (kosong untuk reset filter)
  void setMustNotIncludeIngredient(String ingredient) {
    state = state.copyWith(mustNotIncludeIngredient: ingredient);
  }

  /// Set bahan-bahan yang terdeteksi dari fitur scan kamera
  /// Digunakan untuk mencari resep yang menggunakan bahan-bahan ini
  /// 
  /// Parameter:
  /// - ingredients: List bahan yang terdeteksi dari kamera
  void setScannedIngredients(List<String> ingredients) {
    state = state.copyWith(scannedIngredients: ingredients);
  }

  /// Reset semua filter ke nilai awal (kosong)
  /// Digunakan ketika user ingin membersihkan semua filter dan melihat semua resep
  void resetFilters() {
    state = state.copyWith(
      searchQuery: '', // Reset search query ke kosong
      maxDuration: null, // Reset durasi filter ke null
      difficulty: null, // Reset difficulty filter ke null
      category: null, // Reset category filter ke null
      mustIncludeIngredient: '', // Reset must include ingredient ke kosong
      mustNotIncludeIngredient: '', // Reset must not include ingredient ke kosong
      scannedIngredients: [], // Reset scanned ingredients ke empty list
    );
  }

  // ============================================================================
  // CRUD OPERATIONS - Create, Read, Update, Delete resep
  // ============================================================================
  
  /// Menambah resep baru ke Firestore
  /// 
  /// Parameter:
  /// - recipe: Recipe object yang akan ditambahkan
  /// 
  /// Process:
  /// 1. Convert Recipe ke JSON
  /// 2. Tambahkan ke Firestore collection 'recipes'
  /// 3. Reload semua resep dari Firestore untuk update state
  Future<void> addRecipe(Recipe recipe) async {
    /// Tambahkan recipe ke Firestore dan dapatkan document ID
    await _recipesCollection.add(recipe.toJson());
    /// Reload semua resep dari Firestore untuk update state lokal
    await loadRecipes();
  }

  /// Update resep yang sudah ada di Firestore
  /// 
  /// Parameter:
  /// - recipe: Recipe object dengan data yang sudah diupdate
  /// 
  /// Process:
  /// 1. Update document di Firestore dengan ID dari recipe
  /// 2. Convert Recipe ke JSON
  /// 3. Reload semua resep dari Firestore untuk update state
  Future<void> updateRecipe(Recipe recipe) async {
    /// Update document di Firestore dengan ID recipe
    await _recipesCollection.doc(recipe.id).update(recipe.toJson());
    /// Reload semua resep dari Firestore untuk update state lokal
    await loadRecipes();
  }

  /// Menghapus resep dari Firestore
  /// 
  /// Parameter:
  /// - id: ID resep yang akan dihapus
  /// 
  /// Process:
  /// 1. Hapus document dari Firestore dengan ID
  /// 2. Reload semua resep dari Firestore untuk update state
  Future<void> deleteRecipe(String id) async {
    /// Hapus document dari Firestore dengan ID
    await _recipesCollection.doc(id).delete();
    /// Reload semua resep dari Firestore untuk update state lokal
    await loadRecipes();
  }

  // ============================================================================
  // LOAD RECIPES - Mengambil data resep dari Firestore
  // ============================================================================
  
  /// Load semua resep dari Firestore dan update state
  /// Dipanggil saat aplikasi pertama kali dimulai dan setelah CRUD operations
  /// 
  /// Process:
  /// 1. Query collection 'recipes' dari Firestore
  /// 2. Convert setiap document ke Recipe object
  /// 3. Update state dengan list resep baru
  /// 4. Jika error, print error message
  Future<void> loadRecipes() async {
    try {
      /// Query semua documents dari collection 'recipes'
      final snapshot = await _recipesCollection.get();
      /// Convert setiap Firestore document menjadi Recipe object
      final recipes = snapshot.docs.map((doc) {
        /// Ambil data dari Firestore document
        final data = doc.data() as Map<String, dynamic>;
        /// Tambahkan ID document ke data (untuk primary key)
        return Recipe.fromJson(data..['id'] = doc.id);
      }).toList();
      /// Update state dengan list resep baru
      state = state.copyWith(recipes: recipes);
    } catch (e) {
      /// Jika terjadi error, print error message untuk debugging
      print('Error loading recipes: $e');
    }
  }
}

// --- PROVIDER ---
// Provider ini sudah diubah di file providers/home_provider.dart