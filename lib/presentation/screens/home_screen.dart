import 'package:dapur_pintar/application/providers/saved_recipes_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dapur_pintar/application/providers/home_provider.dart';
import 'package:dapur_pintar/application/notifiers/home_notifier.dart';
import 'package:dapur_pintar/application/providers/scan_provider.dart';
import 'package:dapur_pintar/presentation/widgets/recipe_card.dart';
import 'package:dapur_pintar/presentation/widgets/filter_bottom_sheet.dart';
import 'package:dapur_pintar/presentation/routes/app_router.dart';
import 'package:dapur_pintar/presentation/screens/saved_recipes_screen.dart';
import 'package:dapur_pintar/presentation/screens/scan_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dapur_pintar/domain/models/recipe.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeContent(),
      const SavedRecipesScreen(),
      const ScanScreen(),
    ];
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      ref.read(savedRecipesNotifierProvider.notifier).loadSavedRecipes();
    }
    if (index == 2) {
      ref.read(scanNotifierProvider.notifier).resetDetection();
    }
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        context.go(AppRouter.home);
        break;
      case 1:
        context.go(AppRouter.saved);
        break;
      case 2:
        context.go(AppRouter.scan);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/logo2.png',
          ),
        ),
        title: const Text(
          'Dapur Pintar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_rounded, color: Colors.white),
            tooltip: "Filter Resep",
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (context) => const FilterBottomSheet(),
              );
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Container(
          key: ValueKey<int>(_selectedIndex),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE8F5E8), Color(0xFFF1F8E9)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: _screens[_selectedIndex],
        ),
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0x334CAF50),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.star_outline),
              selectedIcon: Icon(Icons.star),
              label: 'Favorit',
            ),
            NavigationDestination(
              icon: Icon(Icons.camera_alt_outlined),
              selectedIcon: Icon(Icons.camera_alt),
              label: 'Pindai',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRouter.addEditRecipe, extra: null),
        backgroundColor: const Color(0xFF4CAF50),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Tambah Resep',
          style: TextStyle(
            fontSize: isTablet ? 18 : 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeNotifierProvider);
    final width = MediaQuery.of(context).size.width;

    // STRATEGI HYBRID: Query Firestore dengan filter minimal (1-2 field saja)
    Query query = FirebaseFirestore.instance.collection('recipes');

    // Filter 1: Difficulty (jika ada)
    if (state.difficulty != null) {
      final difficultyString = switch (state.difficulty!) {
        DifficultyFilter.mudah => 'Mudah',
        DifficultyFilter.sedang => 'Sedang',
        DifficultyFilter.sulit => 'Sulit',
      };
      query = query.where('difficulty', isEqualTo: difficultyString);
    }

    // Filter 2: Category (jika ada)
    if (state.category != null) {
      final categoryString = switch (state.category!) {
        CategoryFilter.sarapan => 'Sarapan',
        CategoryFilter.makanSiang => 'Makan Siang',
        CategoryFilter.makanMalam => 'Makan Malam',
        CategoryFilter.dessert => 'Dessert',
      };
      query = query.where('category', isEqualTo: categoryString);
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari resep favoritmu...',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: width * 0.04,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.search, color: Color(0xFF4CAF50)),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(fontSize: width * 0.04),
              onChanged: (value) =>
                  ref.read(homeNotifierProvider.notifier).setSearchQuery(value),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF9800).withOpacity(0.1),
                  const Color(0xFFFF9800).withOpacity(0.05),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFF9800).withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF9800).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.restaurant_menu,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Resep',
                  style: TextStyle(
                    fontSize: width * 0.05,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (state.scannedIngredients.isNotEmpty)
            _buildScannedIngredients(ref, state.scannedIngredients, width),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF4CAF50)));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState(width);
                }

                // Konversi Firestore docs ke Recipe objects
                List<Recipe> recipes = [];
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final fullData = {
                    ...data,
                    'id': doc.id,
                  };
                  recipes.add(Recipe.fromJson(fullData));
                }

                // ===== CLIENT-SIDE FILTERING =====
                // Filter sisanya di client side untuk menghindari banyak index
                final filteredRecipes = recipes.where((recipe) {
                  // Filter: Search Query (title)
                  if (state.searchQuery.isNotEmpty) {
                    if (!recipe.title
                        .toLowerCase()
                        .contains(state.searchQuery.toLowerCase())) {
                      return false;
                    }
                  }

                  // Filter: Max Duration (Durasi Maksimal Memasak)
                  if (state.maxDuration != null) {
                    if (state.maxDuration == -1) {
                      // Kasus khusus: -1 berarti "> 30 menit"
                      // Jika durasi resep <= 30 menit, filter out (tidak tampilkan)
                      if (recipe.duration <= 30) {
                        return false;
                      }
                    } else {
                      // Kasus normal: filter resep dengan durasi > maxDuration
                      // Jika durasi resep > maxDuration, filter out (tidak tampilkan)
                      if (recipe.duration > state.maxDuration!) {
                        return false;
                      }
                    }
                  }

                  // Filter: Must Include Ingredient
                  if (state.mustIncludeIngredient.isNotEmpty) {
                    bool hasIngredient = recipe.ingredients.any((ing) => ing
                        .toLowerCase()
                        .contains(state.mustIncludeIngredient.toLowerCase()));
                    if (!hasIngredient) return false;
                  }

                  // Filter: Must NOT Include Ingredient
                  if (state.mustNotIncludeIngredient.isNotEmpty) {
                    bool hasExcludedIngredient = recipe.ingredients.any((ing) =>
                        ing.toLowerCase().contains(
                            state.mustNotIncludeIngredient.toLowerCase()));
                    if (hasExcludedIngredient) return false;
                  }

                  // Filter: Scanned Ingredients (at least one match)
                  if (state.scannedIngredients.isNotEmpty) {
                    bool hasAnyScannedIngredient =
                        state.scannedIngredients.any((scanned) =>
                            recipe.ingredients.any((ing) => ing
                                .toLowerCase()
                                .contains(scanned.toLowerCase())));
                    if (!hasAnyScannedIngredient) return false;
                  }

                  return true;
                }).toList();

                if (filteredRecipes.isEmpty) {
                  return _buildEmptyState(width);
                }

                return ResponsiveGrid(
                  recipeList: filteredRecipes,
                  onRecipeTap: (recipe) {
                    context.push(AppRouter.recipeDetail, extra: recipe);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(double width) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.no_food,
                size: width * 0.2, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            'Tidak ada resep yang ditemukan',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: width * 0.045,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba cari dengan kata kunci lain',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: width * 0.035,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildScannedIngredients(
    WidgetRef ref, List<String> ingredients, double width) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mencari resep dengan bahan:',
              style: TextStyle(
                fontSize: width * 0.04,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E7D32),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                ref
                    .read(homeNotifierProvider.notifier)
                    .setScannedIngredients([]);
              },
              child: const Text('Hapus'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: ingredients
              .map(
                (ing) => Chip(
                  label: Text(ing),
                  backgroundColor: const Color(0xFFE8F5E9),
                  labelStyle: const TextStyle(color: Color(0xFF2E7D32)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                ),
              )
              .toList(),
        ),
      ],
    ),
  );
}