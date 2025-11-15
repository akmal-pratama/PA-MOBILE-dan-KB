import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dapur_pintar/presentation/screens/home_screen.dart';
import 'package:dapur_pintar/presentation/screens/scan_screen.dart';
import 'package:dapur_pintar/presentation/screens/saved_recipes_screen.dart';
import 'package:dapur_pintar/presentation/screens/recipe_detail_screen.dart';
import 'package:dapur_pintar/presentation/screens/add_edit_recipe_screen.dart';
import 'package:dapur_pintar/domain/models/recipe.dart';

class AppRouter {
  static const String home = '/home';
  static const String scan = '/scan';
  static const String saved = '/saved';
  static const String recipeDetail = '/detail';
  static const String addEditRecipe = '/add-edit-recipe';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        pageBuilder: (context, state) => const MaterialPage(child: HomeScreen()),
      ),
      GoRoute(
        path: scan,
        name: 'scan',
        pageBuilder: (context, state) => const MaterialPage(child: ScanScreen()),
      ),
      GoRoute(
        path: saved,
        name: 'saved',
        pageBuilder: (context, state) =>
            const MaterialPage(child: SavedRecipesScreen()),
      ),
      GoRoute(
        path: recipeDetail,
        name: 'recipe-detail',
        pageBuilder: (context, state) {
          final Recipe? recipe = state.extra as Recipe?;
          if (recipe == null) {
            return const MaterialPage(
              child: Scaffold(
                body: Center(child: Text('Recipe not found')),
              ),
            );
          }
          return MaterialPage(child: RecipeDetailScreen(recipe: recipe));
        },
      ),
      GoRoute(
        path: addEditRecipe,
        name: 'add-edit-recipe',
        pageBuilder: (context, state) {
          final Recipe? recipe = state.extra as Recipe?;
          return MaterialPage(child: AddEditRecipeScreen(recipe: recipe));
        },
      ),
    ],
  );
}
