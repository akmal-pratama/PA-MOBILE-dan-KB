// Import library Flutter untuk widget dasar
import 'package:flutter/material.dart';

/// Widget untuk menampilkan state kosong (empty state)
/// Digunakan ketika tidak ada data yang ditampilkan, misalnya tidak ada resep favorit
/// 
/// Parameter:
/// - message: Pesan yang ditampilkan kepada user
class EmptyState extends StatelessWidget {
  final String message; // Pesan yang akan ditampilkan

  const EmptyState({Key? key, required this.message}) : super(key: key);
  
  /// Method build yang membangun UI dari widget ini
  @override
  Widget build(BuildContext context) {
    return Center(
      // Center widget untuk memposisikan konten di tengah layar
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Align konten ke tengah vertikal
        children: [
          // Icon bookmark untuk visual indicator state kosong
          Icon(
            Icons.bookmark_border, // Icon bookmark kosong
            size: 64, // Ukuran icon besar
            color: Colors.grey, // Warna abu-abu
          ),
          SizedBox(height: 16), // Spacing antara icon dan text
          // Text untuk menampilkan pesan kepada user
          Text(
            message, // Pesan yang ditampilkan
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey), // Style text dengan warna abu-abu
            textAlign: TextAlign.center, // Align text ke tengah
          ),
        ],
      ),
    );
  }
}