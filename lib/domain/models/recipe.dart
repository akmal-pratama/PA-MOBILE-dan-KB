/// Model class untuk merepresentasikan data resep dalam aplikasi
/// Setiap resep memiliki informasi dasar seperti judul, gambar, durasi, tingkat kesulitan, kategori, bahan, dan langkah-langkah
class Recipe {
  /// ID unik untuk setiap resep - digunakan sebagai primary key di database
  final String id;
  /// Judul/nama resep (contoh: "Nasi Goreng", "Soto Ayam")
  final String title;
  /// URL atau path ke gambar resep
  final String imageUrl;
  /// Durasi memasak dalam menit (contoh: 30, 45, 60)
  final int duration; // dalam menit
  /// Tingkat kesulitan resep - nilai: 'Mudah', 'Sedang', 'Sulit'
  final String difficulty; // 'Mudah', 'Sedang', 'Sulit'
  /// Kategori resep - nilai: 'Sarapan', 'Makan Siang', 'Makan Malam', 'Dessert'
  final String category; // 'Sarapan', 'Makan Siang', dll
  /// Daftar bahan-bahan yang diperlukan untuk memasak resep
  final List<String> ingredients;
  /// Daftar langkah-langkah memasak secara berurutan
  final List<String> steps;

  /// Constructor untuk membuat instance Recipe
  /// Semua parameter bersifat required (wajib diisi)
  Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.duration,
    required this.difficulty,
    required this.category,
    required this.ingredients,
    required this.steps,
  });

  /// Metode untuk encode Recipe ke JSON (Map<String, dynamic>)
  /// Digunakan untuk menyimpan data ke database atau API
  /// 
  /// Return: Map yang berisi semua property resep dalam format JSON-compatible
  Map<String, dynamic> toJson() {
    return {
      'id': id, // ID resep
      'title': title, // Judul resep
      'imageUrl': imageUrl, // URL/path gambar
      'duration': duration, // Durasi dalam menit
      'difficulty': difficulty, // Tingkat kesulitan
      'category': category, // Kategori resep
      'ingredients': ingredients, // List bahan
      'steps': steps, // List langkah-langkah
    };
  }

  /// Factory constructor untuk decode Recipe dari JSON
  /// Digunakan ketika mengambil data dari database atau API
  /// 
  /// Parameter:
  /// - json: Map yang berisi data resep dalam format JSON
  /// 
  /// Return: Instance Recipe yang baru dibuat dari data JSON
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      duration: json['duration'] as int,
      difficulty: json['difficulty'] as String,
      category: json['category'] as String,
      ingredients: List<String>.from(json['ingredients'] as List<dynamic>),
      steps: List<String>.from(json['steps'] as List<dynamic>),
    );
  }
}