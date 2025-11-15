// Import library yang diperlukan
import 'package:flutter/material.dart'; // Widget Flutter dasar
import 'package:flutter_riverpod/flutter_riverpod.dart'; // State management dengan Riverpod
import 'package:dapur_pintar/application/notifiers/home_notifier.dart'; // Notifier untuk state home
import 'package:dapur_pintar/application/providers/home_provider.dart'; // Provider untuk home

/// Widget untuk menampilkan bottom sheet filter pencarian resep
/// Menggunakan ConsumerStatefulWidget untuk mengakses Riverpod state
class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

/// State class untuk FilterBottomSheet
class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  // Controller untuk input field "Harus Ada Bahan"
  late TextEditingController _mustIncludeController;
  // Controller untuk input field "Tidak Boleh Ada Bahan"
  late TextEditingController _mustNotIncludeController;

  /// Method yang dipanggil saat widget pertama kali dibuat
  /// Menginisialisasi controller dan mengisi nilai dari state
  @override
  void initState() {
    super.initState();
    // Inisialisasi controller untuk text field
    _mustIncludeController = TextEditingController();
    _mustNotIncludeController = TextEditingController();
    // Mengisi nilai controller dari state setelah widget selesai di-build
    // Menggunakan addPostFrameCallback untuk memastikan ref sudah siap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Membaca state saat ini dari provider
        final state = ref.read(homeNotifierProvider);
        // Mengisi text field dengan nilai dari state
        _mustIncludeController.text = state.mustIncludeIngredient;
        _mustNotIncludeController.text = state.mustNotIncludeIngredient;
      }
    });
  }

  /// Method yang dipanggil saat widget dihapus dari tree
  /// Membersihkan resource yang digunakan (controller)
  @override
  void dispose() {
    // Membebaskan memory yang digunakan oleh controller
    _mustIncludeController.dispose();
    _mustNotIncludeController.dispose();
    super.dispose();
  }

  /// Helper method untuk toggle (on/off) filter durasi maksimal
  /// Jika filter sudah aktif dengan nilai yang sama, akan di-reset (dibuat null)
  /// Jika belum aktif atau nilai berbeda, akan di-set dengan nilai baru
  /// 
  /// Parameter:
  /// - value: Nilai durasi yang ingin di-set (30 untuk "< 30 menit", -1 untuk "> 30 menit", null untuk reset)
  void _toggleDuration(int? value) {
    print('_toggleDuration called with value: $value'); // DEBUG: Log untuk debugging
    // Membaca nilai durasi maksimal saat ini dari state
    final currentValue = ref.read(homeNotifierProvider).maxDuration;
    print('Current maxDuration: $currentValue'); // DEBUG: Log nilai saat ini
    
    if (currentValue == value) {
      // Jika filter sudah aktif dengan nilai yang sama, reset ke null (nonaktifkan filter)
      print('Resetting maxDuration to null'); // DEBUG
      ref.read(homeNotifierProvider.notifier).setMaxDuration(null);
    } else {
      // Jika filter belum aktif atau nilai berbeda, aktifkan dengan nilai baru
      print('Setting maxDuration to $value'); // DEBUG
      ref.read(homeNotifierProvider.notifier).setMaxDuration(value);
    }
  }

  /// Helper method untuk toggle (on/off) filter tingkat kesulitan
  /// Jika filter sudah aktif dengan nilai yang sama, akan di-reset (dibuat null)
  /// Jika belum aktif atau nilai berbeda, akan di-set dengan nilai baru
  /// 
  /// Parameter:
  /// - value: Nilai tingkat kesulitan yang ingin di-set (mudah, sedang, sulit, atau null untuk reset)
  void _toggleDifficulty(DifficultyFilter? value) {
    // Membaca nilai tingkat kesulitan saat ini dari state
    final currentValue = ref.read(homeNotifierProvider).difficulty;
    print('Current: $currentValue, New: $value'); // DEBUG: Log untuk debugging
    
    if (currentValue == value) {
      // Jika filter sudah aktif dengan nilai yang sama, reset ke null (nonaktifkan filter)
      print('Resetting to null'); // DEBUG
      ref.read(homeNotifierProvider.notifier).setDifficulty(null);
    } else {
      // Jika filter belum aktif atau nilai berbeda, aktifkan dengan nilai baru
      print('Setting to $value'); // DEBUG
      ref.read(homeNotifierProvider.notifier).setDifficulty(value);
    }
  }

  /// Helper method untuk toggle (on/off) filter kategori resep
  /// Jika filter sudah aktif dengan nilai yang sama, akan di-reset (dibuat null)
  /// Jika belum aktif atau nilai berbeda, akan di-set dengan nilai baru
  /// 
  /// Parameter:
  /// - value: Nilai kategori yang ingin di-set (sarapan, makanSiang, makanMalam, dessert, atau null untuk reset)
  void _toggleCategory(CategoryFilter? value) {
    print('_toggleCategory called with value: $value'); // DEBUG: Log untuk debugging
    // Membaca nilai kategori saat ini dari state
    final currentValue = ref.read(homeNotifierProvider).category;
    print('Current category: $currentValue'); // DEBUG: Log nilai saat ini
    
    if (currentValue == value) {
      // Jika filter sudah aktif dengan nilai yang sama, reset ke null (nonaktifkan filter)
      print('Resetting category to null'); // DEBUG
      ref.read(homeNotifierProvider.notifier).setCategory(null);
    } else {
      // Jika filter belum aktif atau nilai berbeda, aktifkan dengan nilai baru
      print('Setting category to $value'); // DEBUG
      ref.read(homeNotifierProvider.notifier).setCategory(value);
    }
  }

  /// Method build yang membangun UI dari widget ini
  /// Dipanggil setiap kali state berubah untuk rebuild widget
  @override
  Widget build(BuildContext context) {
    // Menggunakan ref.watch untuk mendengarkan perubahan state secara real-time
    final state = ref.watch(homeNotifierProvider);
    
    // Sinkronisasi nilai controller dengan state (jika state berubah dari luar)
    if (_mustIncludeController.text != state.mustIncludeIngredient) {
      _mustIncludeController.text = state.mustIncludeIngredient;
    }
    if (_mustNotIncludeController.text != state.mustNotIncludeIngredient) {
      _mustNotIncludeController.text = state.mustNotIncludeIngredient;
    }

    // Container utama untuk bottom sheet dengan background putih dan border radius di atas
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white, // Background putih
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)), // Border radius hanya di bagian atas
      ),
      child: Padding(
        // Padding bottom disesuaikan dengan keyboard jika muncul
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
          // SafeArea untuk menghindari notch/status bar
          child: Column(
            mainAxisSize: MainAxisSize.min, // Column hanya mengambil space yang diperlukan
            children: [
              _buildHandleBar(), // Bar untuk drag handle di bagian atas
              _buildHeader(context), // Header dengan judul dan tombol close
              Flexible(
                // Flexible untuk membuat scrollable area
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(), // Physics untuk scroll yang lebih smooth
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8), // Padding untuk konten
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align konten ke kiri
                    children: [
                      // Section header untuk filter waktu memasak
                      _buildSectionHeader(
                        icon: Icons.access_time, // Icon jam
                        title: 'Waktu Memasak', // Judul section
                        subtitle: 'Durasi maksimal', // Subtitle penjelasan
                      ),
                      const SizedBox(height: 12), // Spacing antara header dan chips
                      // Wrap widget untuk menampilkan chips dalam baris yang bisa wrap
                      Wrap(
                        spacing: 12, // Jarak horizontal antar chips
                        runSpacing: 12, // Jarak vertikal antar baris chips
                        children: [
                          // Chip untuk filter "< 30 menit"
                          _buildFilterChip(
                            label: '< 30 menit', // Label yang ditampilkan
                            isSelected: state.maxDuration == 30, // Cek apakah filter ini aktif (nilai 30)
                            icon: Icons.timer_outlined, // Icon untuk chip
                            onTap: () => _toggleDuration(30), // Callback saat chip diklik
                          ),
                          // Chip untuk filter "> 30 menit"
                          _buildFilterChip(
                            label: '> 30 menit', // Label yang ditampilkan
                            isSelected: state.maxDuration == -1, // Cek apakah filter ini aktif (nilai -1 sebagai penanda > 30)
                            icon: Icons.timer, // Icon untuk chip
                            onTap: () => _toggleDuration(-1), // Callback saat chip diklik (menggunakan -1 sebagai penanda)
                          ),
                          // Chip untuk menampilkan semua resep (reset filter)
                          _buildFilterChip(
                            label: 'Semua', // Label yang ditampilkan
                            isSelected: state.maxDuration == null, // Cek apakah tidak ada filter aktif (null)
                            icon: Icons.all_inclusive, // Icon untuk chip
                            onTap: () => ref
                                .read(homeNotifierProvider.notifier)
                                .setMaxDuration(null), // Reset filter durasi ke null
                          ),
                        ],
                      ),

                      const SizedBox(height: 24), // Spacing antara section
                      // Section header untuk filter tingkat kesulitan
                      _buildSectionHeader(
                        icon: Icons.flag, // Icon bendera
                        title: 'Tingkat Kesulitan', // Judul section
                        subtitle: 'Pilih tingkat kesulitan', // Subtitle penjelasan
                      ),
                      const SizedBox(height: 12), // Spacing antara header dan chips
                      // Wrap widget untuk menampilkan chips dalam baris yang bisa wrap
                      Wrap(
                        spacing: 12, // Jarak horizontal antar chips
                        runSpacing: 12, // Jarak vertikal antar baris chips
                        children: [
                          // Chip untuk filter "Mudah"
                          _buildFilterChip(
                            label: 'Mudah', // Label yang ditampilkan
                            isSelected: state.difficulty == DifficultyFilter.mudah, // Cek apakah filter ini aktif
                            icon: Icons.sentiment_satisfied, // Icon emoji senang (hijau)
                            color: Colors.green, // Warna hijau untuk tingkat mudah
                            onTap: () => _toggleDifficulty(DifficultyFilter.mudah), // Callback saat chip diklik
                          ),
                          // Chip untuk filter "Sedang"
                          _buildFilterChip(
                            label: 'Sedang', // Label yang ditampilkan
                            isSelected: state.difficulty == DifficultyFilter.sedang, // Cek apakah filter ini aktif
                            icon: Icons.sentiment_neutral, // Icon emoji netral (orange)
                            color: Colors.orange, // Warna orange untuk tingkat sedang
                            onTap: () => _toggleDifficulty(DifficultyFilter.sedang), // Callback saat chip diklik
                          ),
                          // Chip untuk filter "Sulit"
                          _buildFilterChip(
                            label: 'Sulit', // Label yang ditampilkan
                            isSelected: state.difficulty == DifficultyFilter.sulit, // Cek apakah filter ini aktif
                            icon: Icons.sentiment_very_dissatisfied, // Icon emoji sedih (merah)
                            color: Colors.red, // Warna merah untuk tingkat sulit
                            onTap: () => _toggleDifficulty(DifficultyFilter.sulit), // Callback saat chip diklik
                          ),
                          // Chip untuk menampilkan semua resep (reset filter)
                          _buildFilterChip(
                            label: 'Semua', // Label yang ditampilkan
                            isSelected: state.difficulty == null, // Cek apakah tidak ada filter aktif (null)
                            icon: Icons.all_inclusive, // Icon infinity
                            onTap: () => ref
                                .read(homeNotifierProvider.notifier)
                                .setDifficulty(null), // Reset filter kesulitan ke null
                          ),
                        ],
                      ),

                      const SizedBox(height: 24), // Spacing antara section
                      // Section header untuk filter kategori resep
                      _buildSectionHeader(
                        icon: Icons.category, // Icon kategori
                        title: 'Kategori', // Judul section
                        subtitle: 'Pilih kategori resep', // Subtitle penjelasan
                      ),
                      const SizedBox(height: 12), // Spacing antara header dan chips
                      // Wrap widget untuk menampilkan chips dalam baris yang bisa wrap
                      Wrap(
                        spacing: 12, // Jarak horizontal antar chips
                        runSpacing: 12, // Jarak vertikal antar baris chips
                        children: [
                          // Chip untuk filter "Sarapan"
                          _buildFilterChip(
                            label: 'Sarapan', // Label yang ditampilkan
                            isSelected: state.category == CategoryFilter.sarapan, // Cek apakah filter ini aktif
                            icon: Icons.wb_sunny, // Icon matahari
                            color: Colors.amber, // Warna amber untuk sarapan
                            onTap: () => _toggleCategory(CategoryFilter.sarapan), // Callback saat chip diklik
                          ),
                          // Chip untuk filter "Makan Siang"
                          _buildFilterChip(
                            label: 'Makan Siang', // Label yang ditampilkan
                            isSelected: state.category == CategoryFilter.makanSiang, // Cek apakah filter ini aktif
                            icon: Icons.lunch_dining, // Icon makan siang
                            color: Colors.orange, // Warna orange untuk makan siang
                            onTap: () => _toggleCategory(CategoryFilter.makanSiang), // Callback saat chip diklik
                          ),
                          // Chip untuk filter "Makan Malam"
                          _buildFilterChip(
                            label: 'Makan Malam', // Label yang ditampilkan
                            isSelected: state.category == CategoryFilter.makanMalam, // Cek apakah filter ini aktif
                            icon: Icons.dinner_dining, // Icon makan malam
                            color: Colors.deepPurple, // Warna ungu untuk makan malam
                            onTap: () => _toggleCategory(CategoryFilter.makanMalam), // Callback saat chip diklik
                          ),
                          // Chip untuk filter "Dessert"
                          _buildFilterChip(
                            label: 'Dessert', // Label yang ditampilkan
                            isSelected: state.category == CategoryFilter.dessert, // Cek apakah filter ini aktif
                            icon: Icons.cake, // Icon kue
                            color: Colors.pink, // Warna pink untuk dessert
                            onTap: () => _toggleCategory(CategoryFilter.dessert), // Callback saat chip diklik
                          ),
                          // Chip untuk menampilkan semua resep (reset filter)
                          _buildFilterChip(
                            label: 'Semua', // Label yang ditampilkan
                            isSelected: state.category == null, // Cek apakah tidak ada filter aktif (null)
                            icon: Icons.all_inclusive, // Icon infinity
                            onTap: () => ref
                                .read(homeNotifierProvider.notifier)
                                .setCategory(null), // Reset filter kategori ke null
                          ),
                        ],
                      ),

                      const SizedBox(height: 24), // Spacing antara section
                      // Section header untuk filter bahan
                      _buildSectionHeader(
                        icon: Icons.restaurant, // Icon restoran
                        title: 'Filter Bahan', // Judul section
                        subtitle: 'Sesuaikan bahan yang diinginkan', // Subtitle penjelasan
                      ),
                      const SizedBox(height: 12), // Spacing antara header dan field
                      // Text field untuk input bahan yang harus ada
                      _buildIngredientField(
                        label: 'Harus Ada Bahan', // Label field
                        hint: 'Contoh: Ayam, Telur', // Placeholder text
                        icon: Icons.add_circle_outline, // Icon plus (hijau)
                        controller: _mustIncludeController, // Controller untuk text field
                        onChanged: (value) => ref
                            .read(homeNotifierProvider.notifier)
                            .setMustIncludeIngredient(value), // Update state saat text berubah
                        color: Colors.green, // Warna hijau untuk "harus ada"
                      ),
                      const SizedBox(height: 16), // Spacing antar field
                      // Text field untuk input bahan yang tidak boleh ada
                      _buildIngredientField(
                        label: 'Tidak Boleh Ada Bahan', // Label field
                        hint: 'Contoh: Bawang Merah, Cabai', // Placeholder text
                        icon: Icons.remove_circle_outline, // Icon minus (merah)
                        controller: _mustNotIncludeController, // Controller untuk text field
                        onChanged: (value) => ref
                            .read(homeNotifierProvider.notifier)
                            .setMustNotIncludeIngredient(value), // Update state saat text berubah
                        color: Colors.red, // Warna merah untuk "tidak boleh ada"
                      ),

                      const SizedBox(height: 24), // Spacing sebelum tombol reset
                      _buildResetButton(context), // Tombol untuk reset semua filter
                      const SizedBox(height: 24), // Spacing di bawah tombol reset
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

  /// Widget untuk membuat handle bar (bar kecil di atas) untuk drag indicator
  /// Memberikan visual cue bahwa bottom sheet bisa di-drag
  Widget _buildHandleBar() => Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8), // Margin atas dan bawah
        width: 40, // Lebar bar
        height: 4, // Tinggi bar
        decoration: BoxDecoration(
          color: Colors.grey[300], // Warna abu-abu terang
          borderRadius: BorderRadius.circular(2), // Border radius untuk ujung bulat
        ),
      );

  /// Widget untuk membuat header bottom sheet dengan judul dan tombol close
  /// Menampilkan icon filter, judul, subtitle, dan tombol untuk menutup bottom sheet
  Widget _buildHeader(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), // Padding untuk konten header
        decoration: BoxDecoration(
          // Gradient background dari hijau transparan ke transparan
          gradient: LinearGradient(
            colors: [
              const Color(0xFF4CAF50).withOpacity(0.1), // Hijau dengan opacity 10%
              Colors.transparent, // Transparan di bawah
            ],
            begin: Alignment.topCenter, // Mulai dari atas
            end: Alignment.bottomCenter, // Berakhir di bawah
          ),
        ),
        child: Row(
          children: [
            // Container untuk icon filter dengan gradient background
            Container(
              padding: const EdgeInsets.all(10), // Padding untuk icon
              decoration: BoxDecoration(
                // Gradient hijau untuk background icon
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)], // Dari hijau gelap ke hijau terang
                  begin: Alignment.topLeft, // Mulai dari kiri atas
                  end: Alignment.bottomRight, // Berakhir di kanan bawah
                ),
                borderRadius: BorderRadius.circular(12), // Border radius bulat
                boxShadow: [
                  // Shadow untuk efek depth
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.3), // Shadow hijau dengan opacity 30%
                    blurRadius: 8, // Blur radius
                    offset: const Offset(0, 4), // Offset ke bawah
                  ),
                ],
              ),
              child: const Icon(Icons.tune, color: Colors.white, size: 24), // Icon filter putih
            ),
            const SizedBox(width: 16), // Spacing antara icon dan text
            // Column untuk judul dan subtitle
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align text ke kiri
                children: [
                  Text(
                    'Filter Pencarian', // Judul header
                    style: TextStyle(
                      fontSize: 22, // Ukuran font besar
                      fontWeight: FontWeight.bold, // Font tebal
                      color: Color(0xFF2E7D32), // Warna hijau gelap
                      letterSpacing: 0.5, // Spacing antar huruf
                    ),
                  ),
                  SizedBox(height: 4), // Spacing kecil antara judul dan subtitle
                  Text(
                    'Sesuaikan pencarian sesuai kebutuhan', // Subtitle penjelasan
                    style: TextStyle(
                      fontSize: 13, // Ukuran font kecil
                      color: Colors.grey, // Warna abu-abu
                    ),
                  ),
                ],
              ),
            ),
            // IconButton untuk menutup bottom sheet
            IconButton(
              onPressed: () => Navigator.pop(context), // Pop bottom sheet saat diklik
              icon: Icon(Icons.close, color: Colors.grey[700]), // Icon close abu-abu
            ),
          ],
        ),
      );

  /// Widget untuk membuat header section dengan icon, judul, dan subtitle
  /// Digunakan untuk setiap section filter (waktu, kesulitan, kategori, dll)
  /// 
  /// Parameter:
  /// - icon: Icon yang ditampilkan di sebelah kiri
  /// - title: Judul section (teks besar)
  /// - subtitle: Subtitle penjelasan (teks kecil)
  Widget _buildSectionHeader({
    required IconData icon, // Icon untuk section
    required String title, // Judul section
    required String subtitle, // Subtitle penjelasan
  }) =>
      Row(
        children: [
          // Container untuk icon dengan background hijau transparan
          Container(
            padding: const EdgeInsets.all(8), // Padding untuk icon
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1), // Background hijau transparan
              borderRadius: BorderRadius.circular(10), // Border radius bulat
            ),
            child: Icon(icon, color: const Color(0xFF4CAF50), size: 20), // Icon hijau
          ),
          const SizedBox(width: 12), // Spacing antara icon dan text
          // Column untuk judul dan subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align text ke kiri
              children: [
                Text(
                  title, // Judul section
                  style: const TextStyle(
                    fontSize: 16, // Ukuran font sedang
                    fontWeight: FontWeight.bold, // Font tebal
                    color: Color(0xFF2E7D32), // Warna hijau gelap
                  ),
                ),
                Text(
                  subtitle, // Subtitle penjelasan
                  style: TextStyle(
                    fontSize: 12, // Ukuran font kecil
                    color: Colors.grey[600], // Warna abu-abu
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  /// Widget untuk membuat filter chip (tombol filter yang bisa diklik)
  /// Menampilkan icon, label, dan berubah style saat dipilih
  /// 
  /// Parameter:
  /// - label: Teks yang ditampilkan pada chip
  /// - isSelected: Boolean untuk menentukan apakah chip sedang dipilih
  /// - onTap: Callback function yang dipanggil saat chip diklik
  /// - icon: Icon yang ditampilkan di sebelah kiri label
  /// - color: Warna chip (opsional, default hijau)
  Widget _buildFilterChip({
    required String label, // Label teks pada chip
    required bool isSelected, // Status apakah chip dipilih atau tidak
    required VoidCallback onTap, // Callback saat chip diklik
    required IconData icon, // Icon untuk chip
    Color? color, // Warna chip (opsional)
  }) {
    // Menggunakan warna yang diberikan atau default hijau
    final chipColor = color ?? const Color(0xFF4CAF50);

    // GestureDetector untuk menangani tap event
    return GestureDetector(
      onTap: () {
        print('FilterChip tapped: $label'); // DEBUG: Log untuk debugging
        onTap(); // Memanggil callback yang diberikan
      },
      behavior: HitTestBehavior.opaque, // Memastikan seluruh area bisa diklik
      child: Container(
        constraints: const BoxConstraints(minHeight: 44, minWidth: 80), // Ukuran minimum chip
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Padding untuk konten
        decoration: BoxDecoration(
          // Gradient background jika dipilih, null jika tidak
          gradient: isSelected
              ? LinearGradient(
                  colors: [chipColor, chipColor.withOpacity(0.8)], // Gradient dari warna solid ke transparan
                  begin: Alignment.topLeft, // Mulai dari kiri atas
                  end: Alignment.bottomRight, // Berakhir di kanan bawah
                )
              : null,
          // Background abu-abu jika tidak dipilih
          color: isSelected ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(20), // Border radius bulat
          border: Border.all(
            color: isSelected ? chipColor : Colors.grey[300]!, // Border warna sesuai status
            width: isSelected ? 2 : 1, // Border lebih tebal jika dipilih
          ),
          // Shadow hanya muncul jika chip dipilih
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: chipColor.withOpacity(0.3), // Shadow dengan warna chip
                    blurRadius: 8, // Blur radius
                    offset: const Offset(0, 4), // Offset ke bawah untuk efek depth
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Row hanya mengambil space yang diperlukan
          children: [
            // Icon dengan warna putih jika dipilih, warna chip jika tidak
            Icon(icon, size: 18, color: isSelected ? Colors.white : chipColor),
            const SizedBox(width: 8), // Spacing antara icon dan text
            // Text label dengan warna putih jika dipilih, abu-abu gelap jika tidak
            Text(
              label, // Label teks
              style: TextStyle(
                fontSize: 14, // Ukuran font
                fontWeight: FontWeight.w600, // Font semi-bold
                color: isSelected ? Colors.white : Colors.grey[800], // Warna text sesuai status
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget untuk membuat text field input bahan
  /// Menampilkan label, icon, dan text field dengan styling yang konsisten
  /// 
  /// Parameter:
  /// - label: Label yang ditampilkan di atas field
  /// - hint: Placeholder text di dalam field
  /// - icon: Icon yang ditampilkan di label dan prefix field
  /// - controller: TextEditingController untuk mengontrol nilai field
  /// - onChanged: Callback yang dipanggil saat text berubah
  /// - color: Warna tema untuk field (hijau untuk "harus ada", merah untuk "tidak boleh ada")
  Widget _buildIngredientField({
    required String label, // Label di atas field
    required String hint, // Placeholder text
    required IconData icon, // Icon untuk label dan prefix
    required TextEditingController controller, // Controller untuk text field
    required Function(String) onChanged, // Callback saat text berubah
    required Color color, // Warna tema field
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align konten ke kiri
        children: [
          // Row untuk label dengan icon
          Row(
            children: [
              Icon(icon, size: 16, color: color), // Icon dengan warna tema
              const SizedBox(width: 6), // Spacing kecil
              Text(
                label, // Label text
                style: TextStyle(
                  fontSize: 14, // Ukuran font
                  fontWeight: FontWeight.w600, // Font semi-bold
                  color: Colors.grey[800], // Warna abu-abu gelap
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // Spacing antara label dan field
          // Container untuk text field dengan border dan shadow
          Container(
            decoration: BoxDecoration(
              color: Colors.white, // Background putih
              borderRadius: BorderRadius.circular(16), // Border radius bulat
              border: Border.all(color: color.withOpacity(0.3), width: 1.5), // Border dengan warna tema
              boxShadow: [
                // Shadow untuk efek depth
                BoxShadow(
                  color: color.withOpacity(0.1), // Shadow dengan warna tema
                  blurRadius: 8, // Blur radius
                  offset: const Offset(0, 2), // Offset ke bawah
                ),
              ],
            ),
            child: TextField(
              controller: controller, // Controller untuk mengontrol nilai
              decoration: InputDecoration(
                hintText: hint, // Placeholder text
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14), // Style untuk placeholder
                prefixIcon: Icon(icon, color: color.withOpacity(0.7), size: 20), // Icon prefix dengan warna tema
                border: InputBorder.none, // Tidak ada border default (menggunakan border container)
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Padding untuk text
              ),
              style: const TextStyle(fontSize: 14), // Style untuk text input
              onChanged: onChanged, // Callback saat text berubah
            ),
          ),
        ],
      );

  /// Widget untuk membuat tombol reset semua filter
  /// Tombol dengan gradient merah yang akan mereset semua filter dan menutup bottom sheet
  Widget _buildResetButton(BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), // Border radius bulat
          // Gradient merah dari merah terang ke merah gelap
          gradient: const LinearGradient(
            colors: [Colors.redAccent, Colors.red], // Dari merah terang ke merah
            begin: Alignment.topLeft, // Mulai dari kiri atas
            end: Alignment.bottomRight, // Berakhir di kanan bawah
          ),
          boxShadow: [
            // Shadow merah untuk efek depth
            BoxShadow(
              color: Colors.red.withOpacity(0.3), // Shadow merah dengan opacity 30%
              blurRadius: 12, // Blur radius
              offset: const Offset(0, 6), // Offset ke bawah
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent, // Material transparan untuk InkWell
          child: InkWell(
            borderRadius: BorderRadius.circular(16), // Border radius untuk ripple effect
            onTap: () {
              // Reset semua filter ke nilai default
              ref.read(homeNotifierProvider.notifier).resetFilters();
              // Menutup bottom sheet setelah reset
              Navigator.pop(context);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16), // Padding vertikal
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center konten
                children: [
                  Icon(Icons.refresh, color: Colors.white), // Icon refresh putih
                  SizedBox(width: 8), // Spacing antara icon dan text
                  Text(
                    'Reset Semua Filter', // Text tombol
                    style: TextStyle(
                      color: Colors.white, // Warna putih
                      fontWeight: FontWeight.bold, // Font tebal
                      fontSize: 16, // Ukuran font
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}