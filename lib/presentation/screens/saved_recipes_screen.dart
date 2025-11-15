import 'dart:io';
import 'package:dapur_pintar/domain/models/recipe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dapur_pintar/application/providers/saved_recipes_provider.dart';
import 'package:dapur_pintar/presentation/widgets/empty_state.dart';
import 'package:dapur_pintar/presentation/routes/app_router.dart';
import 'package:dapur_pintar/presentation/screens/home_screen.dart';
import 'package:dapur_pintar/presentation/screens/scan_screen.dart';

import 'package:dapur_pintar/application/providers/scan_provider.dart'; 

class SavedRecipesScreen extends ConsumerStatefulWidget {
  const SavedRecipesScreen({super.key});

  @override
  ConsumerState<SavedRecipesScreen> createState() => _SavedRecipesScreenState(); 
}

class _SavedRecipesScreenState extends ConsumerState<SavedRecipesScreen> {
  int _selectedIndex = 1;

  static final List<Widget> _screens = <Widget>[
    const HomeContent(),
    const SavedContent(),
    const ScanScreen(),
  ];

  void _onItemTapped(int index) {
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
    return Scaffold(
      backgroundColor: Colors.grey[50],

      appBar: AppBar(
        title: const Text(
          'Resep Favorit',
          style: TextStyle(fontWeight: FontWeight.bold,
          color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: const Color(0xFF4CAF50),
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_selectedIndex],
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
    );
  }
}

class SavedContent extends ConsumerStatefulWidget {
  const SavedContent({super.key});

  @override
  ConsumerState<SavedContent> createState() => _SavedContentState();
}

class _SavedContentState extends ConsumerState<SavedContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(savedRecipesNotifierProvider.notifier).loadSavedRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final savedState = ref.watch(savedRecipesNotifierProvider);
    final savedRecipes = savedState.savedRecipes;
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final isTablet = width > 600;

    if (savedRecipes.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E8), Color(0xFFF1F8E9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          child: EmptyState(
            message: 'Anda belum menambahkan resep favorit apapun.',
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE8F5E8), Color(0xFFF1F8E9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: 12),
        child: savedState.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF4CAF50),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF9800).withOpacity(0.15),
                          const Color(0xFFFF9800).withOpacity(0.05),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFF9800).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF9800)
                                    .withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.star,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Daftar Resep Favorit',
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
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.05,
                        vertical: width * 0.04,
                      ),
                      itemCount: savedRecipes.length,
                      itemBuilder: (context, index) {
                        final recipe = savedRecipes[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: _recipeCard(context, ref, recipe, isTablet, width),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _recipeCard(BuildContext context, WidgetRef ref, Recipe recipe,
      bool isTablet, double width) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          context.push(AppRouter.recipeDetail, extra: recipe);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _recipeImage(recipe),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _recipeTitle(recipe, isTablet),
                  const SizedBox(height: 8),
                  _infoChips(recipe),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        tooltip: 'Hapus dari favorit',
                        icon:
                            const Icon(Icons.star, color: Colors.orangeAccent),
                        onPressed: () async {
                          final notifier =
                              ref.read(savedRecipesNotifierProvider.notifier);
                          try {
                            await notifier.removeRecipe(recipe.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Resep dihapus dari favorit')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Gagal menghapus dari favorit: $e')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _recipeImage(Recipe recipe) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: recipe.imageUrl.startsWith('assets/')
              ? Image.asset(
                  recipe.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _errorImagePlaceholder(),
                )
              : Image.file(
                  File(recipe.imageUrl),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _errorImagePlaceholder(),
                ),
        ),
      );

  Widget _recipeTitle(Recipe recipe, bool isTablet) => Text(
        recipe.title,
        style: TextStyle(
          fontSize: isTablet ? 24 : 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2E7D32),
        ),
      );

  Widget _infoChips(Recipe recipe) => Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          _infoChip(Icons.access_time, '${recipe.duration} menit'),
          _infoChip(Icons.flag, recipe.difficulty),
          _infoChip(Icons.category, recipe.category),
        ],
      );

  Widget _errorImagePlaceholder() => Container(
        color: Colors.grey[300],
        child: Icon(Icons.image_not_supported,
            size: 60, color: Colors.grey[600]),
      );

  Widget _infoChip(IconData icon, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF4CAF50), size: 18),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
}