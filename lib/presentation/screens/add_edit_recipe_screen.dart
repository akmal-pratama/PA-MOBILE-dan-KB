import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dapur_pintar/domain/models/recipe.dart';
import 'package:dapur_pintar/application/providers/home_provider.dart';
import 'package:dapur_pintar/application/providers/saved_recipes_provider.dart'; 

class AddEditRecipeScreen extends ConsumerStatefulWidget {
  final Recipe? recipe;

  const AddEditRecipeScreen({Key? key, this.recipe}) : super(key: key);

  @override
  ConsumerState<AddEditRecipeScreen> createState() =>
      _AddEditRecipeScreenState();
}

class _AddEditRecipeScreenState extends ConsumerState<AddEditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _durationController;
  late TextEditingController _ingredientsController;
  late TextEditingController _stepsController;
  late String _selectedDifficulty;
  late String _selectedCategory;

  final ImagePicker _picker = ImagePicker();
  String? _selectedImagePath;

  bool get _isEditing => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    final recipe = widget.recipe;

    _titleController = TextEditingController(text: recipe?.title ?? '');
    _durationController =
        TextEditingController(text: recipe?.duration.toString() ?? '');
    _ingredientsController =
        TextEditingController(text: recipe?.ingredients.join(', ') ?? '');
    _stepsController =
        TextEditingController(text: recipe?.steps.join('\n') ?? '');
    _selectedImagePath = recipe?.imageUrl;
    
    _selectedDifficulty = recipe?.difficulty ?? 'Mudah';
    _selectedCategory = recipe?.category ?? 'Makan Malam';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _ingredientsController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
      );

      if (image != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
        final savedImage =
            await File(image.path).copy('${appDir.path}/$fileName');

        setState(() {
          _selectedImagePath = savedImage.path;
        });
      }
    } catch (e) {
      _showSnackBar('Gagal memilih gambar: ${e.toString()}', isError: true);
    }
  }

  Future<void> _deleteRecipe() async {
    if (!_isEditing) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Resep'),
        content: const Text('Apakah Anda yakin ingin menghapus resep ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      final notifier = ref.read(homeNotifierProvider.notifier);
      await notifier.deleteRecipe(widget.recipe!.id);
      if (context.mounted) context.goNamed('home');
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImagePath == null || _selectedImagePath!.isEmpty) {
      _showSnackBar('Pilih gambar terlebih dahulu');
      return;
    }

    final ingredients = _ingredientsController.text
        .split(',')
        .map((e) => e.trim())
        .toList();
    final steps =
        _stepsController.text.split('\n').map((e) => e.trim()).toList();
    final duration = int.tryParse(_durationController.text) ?? 0;

    final newRecipe = Recipe(
      id: widget.recipe?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      imageUrl: _selectedImagePath!,
      duration: duration,
      difficulty: _selectedDifficulty,
      category: _selectedCategory,
      ingredients: ingredients,
      steps: steps,
    );

    final homeNotifier = ref.read(homeNotifierProvider.notifier);
    final savedNotifier = ref.read(savedRecipesNotifierProvider.notifier);

    if (_isEditing) {
      await homeNotifier.updateRecipe(newRecipe);
      await savedNotifier.updateRecipe(newRecipe);
    } else {
      await homeNotifier.addRecipe(newRecipe);
      // --- HAPUS BARIS INI UNTUK TIDAK LANGSUNG SIMPAN KE FAVORIT ---
      // await savedNotifier.saveRecipe(newRecipe);
    }

    // --- HAPUS BARIS INI JUGA JIKA TIDAK DIPERLUKAN ---
    // await savedNotifier.loadSavedRecipes();
    // ref.invalidate(savedRecipesNotifierProvider);

    _showSnackBar(_isEditing 
      ? 'Resep berhasil diperbarui!' 
      : 'Resep berhasil ditambahkan!');

    if (context.mounted) context.pop();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Resep' : 'Tambah Resep',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white), 
        ),
        backgroundColor: const Color(0xFF4CAF50),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: 'Hapus Resep',
              onPressed: _deleteRecipe,
              icon: const Icon(Icons.delete, color: Colors.white),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                  _titleController, 'Judul Resep', 'Judul tidak boleh kosong'),
              const SizedBox(height: 12),
              _buildImagePicker(width),
              _buildDurationField(),
              
              _buildDropdownField(
                label: 'Tingkat Kesulitan',
                value: _selectedDifficulty,
                items: ['Mudah', 'Sedang', 'Sulit'], 
                onChanged: (newValue) {
                  setState(() {
                    _selectedDifficulty = newValue!;
                  });
                },
              ),
              _buildDropdownField(
                label: 'Kategori',
                value: _selectedCategory,
                items: ['Sarapan', 'Makan Siang', 'Makan Malam', 'Dessert'],
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
              _buildTextField(_ingredientsController,
                  'Bahan (pisahkan dengan koma)', 'Bahan wajib diisi',
                  maxLines: 3),
              _buildTextField(_stepsController, 'Langkah-langkah (pisahkan dengan Enter)',
                  'Langkah wajib diisi',
                  maxLines: 5),
              const SizedBox(height: 24),
              _buildSubmitButton(width),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gambar Resep',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (_selectedImagePath != null && _selectedImagePath!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.file(File(_selectedImagePath!),
                height: 200, width: double.infinity, fit: BoxFit.cover),
          )
        else
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Center(
              child: Icon(Icons.add_photo_alternate,
                  color: Colors.grey, size: 60),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Galeri'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Kamera'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      String validatorText,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        maxLines: maxLines,
        validator: (v) => v == null || v.isEmpty ? validatorText : null,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        validator: (v) => v == null || v.isEmpty ? '$label wajib diisi' : null,
      ),
    );
  }

  Widget _buildDurationField() {
    return _buildTextField(
      _durationController,
      'Durasi (menit)',
      'Durasi wajib diisi',
    );
  }

  Widget _buildSubmitButton(double width) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
        ),
      ),
      child: FilledButton.icon(
        onPressed: _submit,
        icon: const Icon(Icons.check, color: Colors.white),
        label: Text(
          _isEditing ? 'Simpan Perubahan' : 'Tambah Resep',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding:
              EdgeInsets.symmetric(horizontal: width * 0.1, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}