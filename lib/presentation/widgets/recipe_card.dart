// Import library yang diperlukan
import 'package:flutter/material.dart'; // Widget Flutter dasar
import 'package:go_router/go_router.dart'; // Routing dengan GoRouter
import 'package:dapur_pintar/domain/models/recipe.dart'; // Model Recipe
import 'package:dapur_pintar/presentation/routes/app_router.dart'; // Router configuration
import 'package:dapur_pintar/core/utils/responsive.dart'; // Utility untuk responsive design
import 'dart:io'; // Untuk File operations

/// Widget untuk menampilkan card resep
/// Menampilkan gambar, judul, durasi, tingkat kesulitan, dan kategori resep
/// Dengan animasi scale saat diklik
class RecipeCard extends StatefulWidget {
  final Recipe recipe; // Data resep yang akan ditampilkan
  final VoidCallback? onTap; // Callback saat card diklik (opsional)

  const RecipeCard({
    Key? key,
    required this.recipe, // Resep yang wajib diisi
    this.onTap, // Callback opsional
  }) : super(key: key);

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

/// State class untuk RecipeCard
/// Menggunakan SingleTickerProviderStateMixin untuk animasi
class _RecipeCardState extends State<RecipeCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller; // Controller untuk animasi
  late Animation<double> _scaleAnimation; // Animasi scale (zoom in/out)

  /// Method yang dipanggil saat widget pertama kali dibuat
  /// Menginisialisasi animation controller dan scale animation
  @override
  void initState() {
    super.initState();
    // Inisialisasi animation controller dengan durasi 150ms
    _controller = AnimationController(
      vsync: this, // Menggunakan widget ini sebagai vsync
      duration: const Duration(milliseconds: 150), // Durasi animasi 150ms
    );
    // Membuat animasi scale dari 1.0 (normal) ke 0.95 (sedikit mengecil)
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut), // Curve animasi smooth
    );
  }

  /// Method yang dipanggil saat widget dihapus dari tree
  /// Membersihkan animation controller
  @override
  void dispose() {
    _controller.dispose(); // Membebaskan memory animation controller
    super.dispose();
  }

  /// Widget untuk menampilkan placeholder jika gambar gagal dimuat
  /// Menampilkan icon "image not supported" dengan background abu-abu
  Widget _errorImagePlaceholder() {
    return Container(
      color: Colors.grey[300], // Background abu-abu terang
      child: Icon(
        Icons.image_not_supported, // Icon untuk gambar tidak tersedia
        size: 50, // Ukuran icon
        color: Colors.grey[600], // Warna abu-abu gelap
      ),
    );
  }

  /// Widget untuk membuat badge informasi (durasi, kesulitan, dll)
  /// Menampilkan icon dan text dengan background berwarna
  /// 
  /// Parameter:
  /// - icon: Icon yang ditampilkan
  /// - text: Teks yang ditampilkan
  /// - backgroundColor: Warna background badge
  Widget _buildInfoBadge(IconData icon, String text, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // Padding untuk badge
      decoration: BoxDecoration(
        color: backgroundColor, // Background color badge
        borderRadius: BorderRadius.circular(20), // Border radius bulat
        boxShadow: [
          // Shadow untuk efek depth
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Shadow dengan opacity 20%
            blurRadius: 4, // Blur radius
            offset: const Offset(0, 2), // Offset ke bawah
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Row hanya mengambil space yang diperlukan
        children: [
          Icon(icon, size: 14, color: const Color(0xFF2E7D32)), // Icon hijau gelap
          const SizedBox(width: 4), // Spacing kecil antara icon dan text
          Text(
            text, // Text badge
            style: const TextStyle(
              fontSize: 12, // Ukuran font kecil
              fontWeight: FontWeight.w600, // Font semi-bold
              color: Color(0xFF2E7D32), // Warna hijau gelap
            ),
          ),
        ],
      ),
    );
  }

  /// Method build yang membangun UI card resep
  /// Menggunakan AnimatedBuilder untuk animasi scale saat diklik
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation, // Animasi yang digunakan
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value, // Scale berdasarkan nilai animasi
          child: Container(
            margin: const EdgeInsets.only(bottom: 16), // Margin bawah untuk spacing antar card
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), // Border radius bulat
              boxShadow: [
                // Shadow utama untuk efek depth
                BoxShadow(
                  color: Colors.black.withOpacity(0.08), // Shadow dengan opacity 8%
                  blurRadius: 20, // Blur radius besar
                  offset: const Offset(0, 8), // Offset ke bawah
                ),
                // Shadow sekunder untuk detail
                BoxShadow(
                  color: Colors.black.withOpacity(0.04), // Shadow dengan opacity 4%
                  blurRadius: 6, // Blur radius kecil
                  offset: const Offset(0, 2), // Offset ke bawah sedikit
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent, // Material transparan untuk InkWell
              child: InkWell(
                // Callback saat card diklik
                onTap: widget.onTap ??
                    () {
                      // Default: navigasi ke detail resep
                      context.push(AppRouter.recipeDetail, extra: widget.recipe);
                    },
                // Animasi saat tap down (mulai tekan)
                onTapDown: (_) => _controller.forward(), // Scale down
                // Animasi saat tap up (lepas tekan)
                onTapUp: (_) => _controller.reverse(), // Scale up kembali
                // Animasi saat tap cancel (batal tekan)
                onTapCancel: _controller.reverse, // Scale up kembali
                borderRadius: BorderRadius.circular(20), // Border radius untuk ripple effect
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Stack(
                          children: [
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: widget.recipe.imageUrl.startsWith('assets/')
                                  ? Image.asset(
                                      widget.recipe.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          _errorImagePlaceholder(),
                                    )
                                  : Image.file(
                                      File(widget.recipe.imageUrl),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          _errorImagePlaceholder(),
                                    ),
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.3),
                                    ],
                                    stops: const [0.6, 1.0],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 12,
                              left: 12,
                              right: 12,
                              /// Row untuk menampilkan badge info (durasi dan difficulty)
                              child: Row(
                                children: [
                                  /// Badge untuk menampilkan durasi memasak
                                  _buildInfoBadge(
                                    Icons.access_time, /// Icon jam
                                    '${widget.recipe.duration} min', /// Durasi dalam menit
                                    Colors.white.withOpacity(0.9), /// Background putih semi-transparan
                                  ),
                                  const SizedBox(width: 8), /// Spacing antara badge
                                  /// Badge untuk menampilkan tingkat kesulitan
                                  _buildInfoBadge(
                                    Icons.flag, /// Icon flag
                                    widget.recipe.difficulty, /// Tingkat kesulitan (Mudah/Sedang/Sulit)
                                    Colors.white.withOpacity(0.9), /// Background putih semi-transparan
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      /// Padding yang berisi informasi teks resep (judul dan kategori)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Judul resep dengan max 2 lines dan ellipsis jika terlalu panjang
                            Text(
                              widget.recipe.title, /// Judul resep dari parameter
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32), /// Warna hijau gelap
                                height: 1.3,
                              ),
                              maxLines: 2, /// Max 2 baris teks
                              overflow: TextOverflow.ellipsis, /// Jika overflow, tampilkan ellipsis (...)
                            ),
                            const SizedBox(height: 8),
                            /// Kategori resep (Sarapan, Makan Siang, dll)
                            Text(
                              widget.recipe.category, /// Kategori resep dari parameter
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Widget untuk menampilkan grid/list resep yang responsive
/// Menampilkan ListView untuk mobile dan GridView untuk tablet/desktop
/// Secara otomatis menyesuaikan layout berdasarkan ukuran layar
/// 
/// Parameter:
/// - recipeList: List resep yang akan ditampilkan
/// - onRecipeTap: Callback saat resep diklik (opsional)
class ResponsiveGrid extends StatelessWidget {
  /// List resep yang akan ditampilkan dalam grid/list
  final List<Recipe> recipeList;
  /// Callback function yang dipanggil saat salah satu resep diklik
  /// Parameter: Recipe yang diklik
  final Function(Recipe)? onRecipeTap;

  const ResponsiveGrid({
    Key? key,
    required this.recipeList, // List resep wajib diisi
    this.onRecipeTap, // Callback opsional
  }) : super(key: key);

  /// Method build yang membangun UI berdasarkan ukuran layar
  /// Menggunakan ResponsiveUtil untuk mendeteksi device type
  @override
  Widget build(BuildContext context) {
    // Cek apakah device saat ini adalah mobile (width < 768)
    if (ResponsiveUtil.isMobile(context)) {
      // Untuk mobile, gunakan ListView (satu kolom, scrollable vertikal)
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Padding untuk list
        itemCount: recipeList.length, // Jumlah item dalam list
        itemBuilder: (context, index) => RecipeCard(
          recipe: recipeList[index], // Resep pada index tertentu
          onTap: onRecipeTap != null
              ? () => onRecipeTap!(recipeList[index]) // Jika callback ada, panggil dengan resep
              : null, // Jika tidak ada callback, gunakan default (navigate ke detail)
        ),
      );
    } else {
      // Untuk tablet/desktop, gunakan GridView (multiple columns)
      return GridView.builder(
        padding: const EdgeInsets.all(16), // Padding untuk grid
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          /// 2 kolom untuk tablet (768-1200px), 3 kolom untuk desktop (>1200px)
          crossAxisCount: ResponsiveUtil.isTablet(context) ? 2 : 3,
          /// Ratio tinggi:lebar card (0.75 = card lebih tinggi dari lebar)
          childAspectRatio: 0.75,
          /// Spacing horizontal antar card (20px)
          crossAxisSpacing: 20,
          /// Spacing vertikal antar card (20px)
          mainAxisSpacing: 20,
        ),
        itemCount: recipeList.length, // Jumlah item dalam grid
        itemBuilder: (context, index) => RecipeCard(
          recipe: recipeList[index], // Resep pada index tertentu
          onTap: onRecipeTap != null
              ? () => onRecipeTap!(recipeList[index]) // Jika callback ada, panggil dengan resep
              : null, // Jika tidak ada callback, gunakan default (navigate ke detail)
        ),
      );
    }
  }
}
