import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dapur_pintar/domain/models/recipe.dart';
import 'package:dapur_pintar/application/providers/saved_recipes_provider.dart';
import 'package:dapur_pintar/application/providers/home_provider.dart'; 
import 'package:go_router/go_router.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final Recipe recipe;

  const RecipeDetailScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedState = ref.watch(savedRecipesNotifierProvider);
    final homeState = ref.watch(homeNotifierProvider);
    final updatedRecipe = homeState.recipes.firstWhere(
      (r) => r.id == recipe.id,
      orElse: () => recipe,
    );

    final isSaved = savedState.savedRecipes.any((r) => r.id == recipe.id);

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final isTablet = width > 600;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          updatedRecipe.title, 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: isTablet ? 24 : 18,
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 2,
        actions: [
          IconButton(
            tooltip: 'Edit Resep',
            onPressed: () => context.pushNamed('add-edit-recipe', extra: updatedRecipe),
            icon: const Icon(Icons.edit, color: Colors.white),
          ),
          IconButton(
            tooltip: isSaved ? 'Hapus dari favorit' : 'Tambah ke favorit',
            icon: Icon(
              isSaved ? Icons.star : Icons.star_border,
              color: isSaved ? Colors.orangeAccent : Colors.white,
            ),
            onPressed: () async {
              final notifier = ref.read(savedRecipesNotifierProvider.notifier);
              try {
                if (isSaved) {
                  await notifier.removeRecipe(updatedRecipe.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Resep dihapus dari favorit')),
                    );
                  }
                } else {
                  await notifier.saveRecipe(updatedRecipe);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Resep ditambahkan ke favorit')),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menambahkan ke favorit: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.05,
          vertical: width * 0.04,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    children: [
                      updatedRecipe.imageUrl.startsWith('assets/')
                          ? Image.asset(
                              updatedRecipe.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _errorImagePlaceholder(),
                            )
                          : Image.file(
                              File(updatedRecipe.imageUrl),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _errorImagePlaceholder(),
                            ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.25),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Text(
              updatedRecipe.title,
              style: TextStyle(
                fontSize: isTablet ? 28 : 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E7D32),
              ),
            ),

            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _infoChip(Icons.access_time, '${updatedRecipe.duration} menit'),
                _infoChip(Icons.flag, updatedRecipe.difficulty),
                _infoChip(Icons.category, updatedRecipe.category),
              ],
            ),

            const SizedBox(height: 24),

            _sectionHeader('Bahan-bahan'),
            const SizedBox(height: 12),
            _contentContainer(
              width,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: updatedRecipe.ingredients.map((ing) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6, right: 12),
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            ing,
                            style: TextStyle(
                              fontSize: width * 0.04,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            _sectionHeader('Langkah-langkah'),
            const SizedBox(height: 12),
            _contentContainer(
              width,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: updatedRecipe.steps.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2, right: 12),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: width * 0.04,
                              color: Colors.black87,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _errorImagePlaceholder() => Container(
        color: Colors.grey[300],
        child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey[600]),
      );

  Widget _infoChip(IconData icon, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF4CAF50).withOpacity(0.1),
              const Color(0xFF81C784).withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF4CAF50), size: 18),
            const SizedBox(width: 8),
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

  Widget _sectionHeader(String title) => Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      );

  Widget _contentContainer(double width, Widget child) => Container(
        width: double.infinity,
        padding: EdgeInsets.all(width * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      );
}