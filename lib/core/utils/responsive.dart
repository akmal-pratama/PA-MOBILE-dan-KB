import 'package:flutter/material.dart';

/// Utility class untuk membuat UI yang responsive (menyesuaikan dengan berbagai ukuran layar)
/// Menyediakan method untuk mendeteksi tipe device dan menghitung padding/margin dinamis
/// 
/// Breakpoint:
/// - Mobile: < 768 px
/// - Tablet: 768 - 1200 px  
/// - Desktop: >= 1200 px
class ResponsiveUtil {
  /// Menghitung horizontal padding berdasarkan lebar layar
  /// Padding yang lebih besar untuk device yang lebih besar (untuk UI yang lebih baik)
  /// 
  /// Parameter:
  /// - context: BuildContext untuk mendapatkan informasi ukuran layar
  /// 
  /// Return: Nilai padding horizontal dalam pixel
  static double getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 48; // Desktop - padding besar untuk margin yang nyaman
    if (width >= 768) return 32;  // Tablet - padding sedang
    return 16;                    // Mobile - padding kecil untuk memaksimalkan ruang
  }

  /// Menghitung vertical padding untuk semua device
  /// Fixed value karena vertical padding biasanya konsisten di semua ukuran
  /// 
  /// Parameter:
  /// - context: BuildContext (parameter ini sebenarnya tidak digunakan tapi included untuk consistency)
  /// 
  /// Return: Nilai padding vertikal dalam pixel (16)
  static double getVerticalPadding(BuildContext context) {
    return 16;
  }

  /// Mengecek apakah device saat ini adalah mobile
  /// Mobile: lebar layar < 768 px
  /// 
  /// Parameter:
  /// - context: BuildContext untuk mendapatkan informasi ukuran layar
  /// 
  /// Return: true jika device adalah mobile, false sebaliknya
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  /// Mengecek apakah device saat ini adalah tablet
  /// Tablet: lebar layar >= 768 px dan < 1200 px
  /// 
  /// Parameter:
  /// - context: BuildContext untuk mendapatkan informasi ukuran layar
  /// 
  /// Return: true jika device adalah tablet, false sebaliknya
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1200;
  }

  /// Mengecek apakah device saat ini adalah desktop
  /// Desktop: lebar layar >= 1200 px
  /// 
  /// Parameter:
  /// - context: BuildContext untuk mendapatkan informasi ukuran layar
  /// 
  /// Return: true jika device adalah desktop, false sebaliknya
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }
}