class Recipe {
  final String id;
  final String title;
  final String imageUrl;
  final int duration; // dalam menit
  final String difficulty; // 'Mudah', 'Sedang', 'Sulit'
  final String category; // 'Sarapan', 'Makan Siang', dll
  final List<String> ingredients;
  final List<String> steps;

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

  // Metode untuk encode ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'duration': duration,
      'difficulty': difficulty,
      'category': category,
      'ingredients': ingredients,
      'steps': steps,
    };
  }

  // Factory untuk decode dari JSON
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