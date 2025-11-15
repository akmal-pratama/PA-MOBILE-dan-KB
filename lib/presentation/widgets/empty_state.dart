// Import library Flutter untuk widget dasar
import 'package:flutter/material.dart';

/// Widget untuk menampilkan state kosong (empty state)
/// Digunakan ketika tidak ada data yang ditampilkan
/// 
/// Contoh penggunaan:
/// - Tidak ada resep favorit
/// - Tidak ada hasil pencarian
/// - List kosong
/// 
/// Menampilkan icon dan pesan untuk memberikan feedback kepada user
class EmptyState extends StatelessWidget {
  /// Pesan yang akan ditampilkan kepada user
  /// Contoh: 'Anda belum menambahkan resep favorit apapun.'
  final String message;

  const EmptyState({Key? key, required this.message}) : super(key: key);
  
  /// Method build yang membangun UI dari widget ini
  /// Menampilkan icon bookmark dan text pesan di tengah layar
  @override
  Widget build(BuildContext context) {
    return Center(
      // Center widget untuk memposisikan konten di tengah layar baik vertikal maupun horizontal
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Align konten ke tengah vertikal
        children: [
          // Icon bookmark untuk visual indicator state kosong
          Icon(
            Icons.bookmark_border, // Icon bookmark kosong/outline
            size: 64, // Ukuran icon besar
            color: Colors.grey, // Warna abu-abu untuk tidak terlalu menonjol
          ),
          SizedBox(height: 16), // Spacing antara icon dan text
          // Text untuk menampilkan pesan kepada user
          Text(
            message, // Pesan yang ditampilkan (parameter dari constructor)
            /// Style text dengan warna abu-abu menggunakan titleMedium theme
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center, // Align text ke tengah
          ),
        ],
      ),
    );
  }
}