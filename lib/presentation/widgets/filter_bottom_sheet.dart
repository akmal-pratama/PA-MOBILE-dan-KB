import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dapur_pintar/application/notifiers/home_notifier.dart';
import 'package:dapur_pintar/application/providers/home_provider.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late TextEditingController _mustIncludeController;
  late TextEditingController _mustNotIncludeController;

  @override
  void initState() {
    super.initState();
    _mustIncludeController = TextEditingController();
    _mustNotIncludeController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final state = ref.read(homeNotifierProvider);
        _mustIncludeController.text = state.mustIncludeIngredient;
        _mustNotIncludeController.text = state.mustNotIncludeIngredient;
      }
    });
  }

  @override
  void dispose() {
    _mustIncludeController.dispose();
    _mustNotIncludeController.dispose();
    super.dispose();
  }

  // Helper method untuk toggle duration
  void _toggleDuration(int? value) {
    print('_toggleDuration called with value: $value'); // DEBUG
    final currentValue = ref.read(homeNotifierProvider).maxDuration;
    print('Current maxDuration: $currentValue'); // DEBUG
    if (currentValue == value) {
      // Jika sudah selected, reset ke null
      print('Resetting maxDuration to null'); // DEBUG
      ref.read(homeNotifierProvider.notifier).setMaxDuration(null);
    } else {
      // Jika belum selected, set value
      print('Setting maxDuration to $value'); // DEBUG
      ref.read(homeNotifierProvider.notifier).setMaxDuration(value);
    }
  }

  // Helper method untuk toggle difficulty
  void _toggleDifficulty(DifficultyFilter? value) {
    final currentValue = ref.read(homeNotifierProvider).difficulty;
    print('Current: $currentValue, New: $value'); // DEBUG
    if (currentValue == value) {
      print('Resetting to null'); // DEBUG
      // Jika sudah selected, reset ke null
      ref.read(homeNotifierProvider.notifier).setDifficulty(null);
    } else {
      print('Setting to $value'); // DEBUG
      // Jika belum selected, set value
      ref.read(homeNotifierProvider.notifier).setDifficulty(value);
    }
  }

  // Helper method untuk toggle category
  void _toggleCategory(CategoryFilter? value) {
    print('_toggleCategory called with value: $value'); // DEBUG
    final currentValue = ref.read(homeNotifierProvider).category;
    print('Current category: $currentValue'); // DEBUG
    if (currentValue == value) {
      // Jika sudah selected, reset ke null
      print('Resetting category to null'); // DEBUG
      ref.read(homeNotifierProvider.notifier).setCategory(null);
    } else {
      // Jika belum selected, set value
      print('Setting category to $value'); // DEBUG
      ref.read(homeNotifierProvider.notifier).setCategory(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeNotifierProvider);
    if (_mustIncludeController.text != state.mustIncludeIngredient) {
      _mustIncludeController.text = state.mustIncludeIngredient;
    }
    if (_mustNotIncludeController.text != state.mustNotIncludeIngredient) {
      _mustNotIncludeController.text = state.mustNotIncludeIngredient;
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHandleBar(),
              _buildHeader(context),
              Flexible(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        icon: Icons.access_time,
                        title: 'Waktu Memasak',
                        subtitle: 'Durasi maksimal',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildFilterChip(
                            label: '< 30 menit',
                            isSelected: state.maxDuration == 30,
                            icon: Icons.timer_outlined,
                            onTap: () => _toggleDuration(30),
                          ),
                          _buildFilterChip(
                            label: '> 30 menit',
                            isSelected: state.maxDuration == -1,
                            icon: Icons.timer,
                            onTap: () => _toggleDuration(-1),
                          ),
                          _buildFilterChip(
                            label: 'Semua',
                            isSelected: state.maxDuration == null,
                            icon: Icons.all_inclusive,
                            onTap: () => ref
                                .read(homeNotifierProvider.notifier)
                                .setMaxDuration(null),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      _buildSectionHeader(
                        icon: Icons.flag,
                        title: 'Tingkat Kesulitan',
                        subtitle: 'Pilih tingkat kesulitan',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildFilterChip(
                            label: 'Mudah',
                            isSelected: state.difficulty == DifficultyFilter.mudah,
                            icon: Icons.sentiment_satisfied,
                            color: Colors.green,
                            onTap: () => _toggleDifficulty(DifficultyFilter.mudah),
                          ),
                          _buildFilterChip(
                            label: 'Sedang',
                            isSelected: state.difficulty == DifficultyFilter.sedang,
                            icon: Icons.sentiment_neutral,
                            color: Colors.orange,
                            onTap: () => _toggleDifficulty(DifficultyFilter.sedang),
                          ),
                          _buildFilterChip(
                            label: 'Sulit',
                            isSelected: state.difficulty == DifficultyFilter.sulit,
                            icon: Icons.sentiment_very_dissatisfied,
                            color: Colors.red,
                            onTap: () => _toggleDifficulty(DifficultyFilter.sulit),
                          ),
                          _buildFilterChip(
                            label: 'Semua',
                            isSelected: state.difficulty == null,
                            icon: Icons.all_inclusive,
                            onTap: () => ref
                                .read(homeNotifierProvider.notifier)
                                .setDifficulty(null),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      _buildSectionHeader(
                        icon: Icons.category,
                        title: 'Kategori',
                        subtitle: 'Pilih kategori resep',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildFilterChip(
                            label: 'Sarapan',
                            isSelected: state.category == CategoryFilter.sarapan,
                            icon: Icons.wb_sunny,
                            color: Colors.amber,
                            onTap: () => _toggleCategory(CategoryFilter.sarapan),
                          ),
                          _buildFilterChip(
                            label: 'Makan Siang',
                            isSelected: state.category == CategoryFilter.makanSiang,
                            icon: Icons.lunch_dining,
                            color: Colors.orange,
                            onTap: () => _toggleCategory(CategoryFilter.makanSiang),
                          ),
                          _buildFilterChip(
                            label: 'Makan Malam',
                            isSelected: state.category == CategoryFilter.makanMalam,
                            icon: Icons.dinner_dining,
                            color: Colors.deepPurple,
                            onTap: () => _toggleCategory(CategoryFilter.makanMalam),
                          ),
                          _buildFilterChip(
                            label: 'Dessert',
                            isSelected: state.category == CategoryFilter.dessert,
                            icon: Icons.cake,
                            color: Colors.pink,
                            onTap: () => _toggleCategory(CategoryFilter.dessert),
                          ),
                          _buildFilterChip(
                            label: 'Semua',
                            isSelected: state.category == null,
                            icon: Icons.all_inclusive,
                            onTap: () => ref
                                .read(homeNotifierProvider.notifier)
                                .setCategory(null),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      _buildSectionHeader(
                        icon: Icons.restaurant,
                        title: 'Filter Bahan',
                        subtitle: 'Sesuaikan bahan yang diinginkan',
                      ),
                      const SizedBox(height: 12),
                      _buildIngredientField(
                        label: 'Harus Ada Bahan',
                        hint: 'Contoh: Ayam, Telur',
                        icon: Icons.add_circle_outline,
                        controller: _mustIncludeController,
                        onChanged: (value) => ref
                            .read(homeNotifierProvider.notifier)
                            .setMustIncludeIngredient(value),
                        color: Colors.green,
                      ),
                      const SizedBox(height: 16),
                      _buildIngredientField(
                        label: 'Tidak Boleh Ada Bahan',
                        hint: 'Contoh: Bawang Merah, Cabai',
                        icon: Icons.remove_circle_outline,
                        controller: _mustNotIncludeController,
                        onChanged: (value) => ref
                            .read(homeNotifierProvider.notifier)
                            .setMustNotIncludeIngredient(value),
                        color: Colors.red,
                      ),

                      const SizedBox(height: 24),
                      _buildResetButton(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandleBar() => Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _buildHeader(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF4CAF50).withOpacity(0.1),
              Colors.transparent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.tune, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Pencarian',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Sesuaikan pencarian sesuai kebutuhan',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close, color: Colors.grey[700]),
            ),
          ],
        ),
      );

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) =>
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF4CAF50), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
    Color? color,
  }) {
    final chipColor = color ?? const Color(0xFF4CAF50);

    return GestureDetector(
      onTap: () {
        print('FilterChip tapped: $label'); // DEBUG
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44, minWidth: 80),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [chipColor, chipColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: chipColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : chipColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required Function(String) onChanged,
    required Color color,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                prefixIcon: Icon(icon, color: color.withOpacity(0.7), size: 20),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: const TextStyle(fontSize: 14),
              onChanged: onChanged,
            ),
          ),
        ],
      );

  Widget _buildResetButton(BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Colors.redAccent, Colors.red],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              ref.read(homeNotifierProvider.notifier).resetFilters();
              Navigator.pop(context);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Reset Semua Filter',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}