import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dapur_pintar/presentation/screens/home_screen.dart';
import 'package:dapur_pintar/presentation/screens/scan_screen.dart';
import 'package:dapur_pintar/presentation/screens/saved_recipes_screen.dart';
import 'package:dapur_pintar/presentation/screens/recipe_detail_screen.dart';
import 'package:dapur_pintar/presentation/screens/add_edit_recipe_screen.dart';
import 'package:dapur_pintar/domain/models/recipe.dart';

/// Class yang mengatur routing (navigasi antar screen) untuk seluruh aplikasi
/// Menggunakan GoRouter untuk navigasi yang powerful dan modern
class AppRouter {
  /// Path route untuk home screen (layar utama)
  static const String home = '/home';
  /// Path route untuk scan screen (layar pindai bahan)
  static const String scan = '/scan';
  /// Path route untuk saved recipes screen (layar resep favorit)
  static const String saved = '/saved';
  /// Path route untuk recipe detail screen (layar detail resep)
  static const String recipeDetail = '/detail';
  /// Path route untuk add/edit recipe screen (layar tambah/edit resep)
  static const String addEditRecipe = '/add-edit-recipe';

  /// Static router instance untuk GoRouter
  /// Diinisialisasi sekali dan digunakan di seluruh aplikasi
  static final GoRouter router = GoRouter(
    /// Path awal saat aplikasi pertama kali dibuka
    initialLocation: home,
    /// Daftar routes yang tersedia di aplikasi
    routes: [
      /// Route untuk home screen
      GoRoute(
        path: home, // Path: /home
        name: 'home', // Nama route untuk referensi
        pageBuilder: (context, state) => const MaterialPage(child: HomeScreen()),
      ),
      /// Route untuk scan screen
      GoRoute(
        path: scan, // Path: /scan
        name: 'scan', // Nama route untuk referensi
        pageBuilder: (context, state) => const MaterialPage(child: ScanScreen()),
      ),
      /// Route untuk saved recipes screen
      GoRoute(
        path: saved, // Path: /saved
        name: 'saved', // Nama route untuk referensi
        pageBuilder: (context, state) =>
            const MaterialPage(child: SavedRecipesScreen()),
      ),
      /// Route untuk recipe detail screen
      /// Menerima Recipe object sebagai extra parameter
      GoRoute(
        path: recipeDetail, // Path: /detail
        name: 'recipe-detail', // Nama route untuk referensi
        pageBuilder: (context, state) {
          /// Extract Recipe object dari parameter extra
          final Recipe? recipe = state.extra as Recipe?;
          if (recipe == null) {
            /// Jika recipe tidak ditemukan, tampilkan error screen
            return const MaterialPage(
              child: Scaffold(
                body: Center(child: Text('Recipe not found')),
              ),
            );
          }
          /// Tampilkan recipe detail dengan recipe yang diperoleh
          return MaterialPage(child: RecipeDetailScreen(recipe: recipe));
        },
      ),
      /// Route untuk add/edit recipe screen
      /// Menerima Recipe object sebagai extra parameter (null jika mode tambah)
      GoRoute(
        path: addEditRecipe, // Path: /add-edit-recipe
        name: 'add-edit-recipe', // Nama route untuk referensi
        pageBuilder: (context, state) {
          /// Extract Recipe object dari parameter extra (null jika menambah baru)
          final Recipe? recipe = state.extra as Recipe?;
          /// Tampilkan add/edit screen dengan recipe (null untuk mode tambah)
          return MaterialPage(child: AddEditRecipeScreen(recipe: recipe));
        },
      ),
    ],
  );
}
