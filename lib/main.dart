/// Import library Flutter untuk UI dasar
import 'package:flutter/material.dart';
/// Import Riverpod untuk state management
import 'package:flutter_riverpod/flutter_riverpod.dart';
/// Import router configuration untuk navigasi antar screen
import 'presentation/routes/app_router.dart';
/// Import Firebase Core untuk inisialisasi Firebase
import 'package:firebase_core/firebase_core.dart'; 
/// Import konfigurasi Firebase untuk berbagai platform (iOS, Android, Web, etc)
import 'firebase_options.dart';

/// Fungsi main: entry point aplikasi Flutter
/// Merupakan fungsi pertama yang dipanggil saat aplikasi dimulai
/// Dengan async karena perlu menginisialisasi Firebase sebelum menjalankan aplikasi
void main() async {
  /// Ensure Flutter Binding sudah diinisialisasi untuk menggunakan plugin/services
  WidgetsFlutterBinding.ensureInitialized(); 
  /// Inisialisasi Firebase dengan konfigurasi platform yang sesuai
  /// DefaultFirebaseOptions.currentPlatform secara otomatis memilih config berdasarkan platform
  await Firebase.initializeApp( 
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

/// Root widget aplikasi - StatelessWidget karena tidak memiliki state lokal
/// Semua state dikelola melalui Riverpod provider
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      /// Sembunyikan debug banner di bagian kanan atas
      debugShowCheckedModeBanner: false,
      /// Judul aplikasi yang ditampilkan di system taskbar/recent apps
      title: 'Dapur Pintar',
      /// Konfigurasi tema visual aplikasi
      theme: ThemeData(
        /// Warna primary untuk aplikasi (Orange)
        primarySwatch: Colors.orange,
        /// Gunakan Material Design 3 untuk tampilan modern dan konsisten
        useMaterial3: true,
      ),
      /// Konfigurasi routing menggunakan GoRouter untuk navigasi antar screen
      routerConfig: AppRouter.router,
    );
  }
}