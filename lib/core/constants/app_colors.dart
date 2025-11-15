import 'package:flutter/material.dart';

/// Class yang menyimpan definisi warna-warna yang digunakan di seluruh aplikasi
/// Menggunakan centralized color management untuk konsistensi visual
/// Semua property adalah static const untuk performa optimal dan immutable
class AppColors {
  /// Warna utama (primary) aplikasi - Orange
  /// Digunakan untuk: AppBar, FloatingActionButton, tombol penting, highlight
  static const primary = Color(0xFFFF9800); // Orange

  /// Warna sekunder aplikasi - Grey
  /// Digunakan untuk: secondary buttons, text secondary, borders
  static const secondary = Color(0xFF9E9E9E); // Grey

  /// Warna background aplikasi - Light Grey
  /// Digunakan untuk: scaffold background, area kosong
  static const background = Color(0xFFFAFAFA); // Light Grey 

  /// Warna teks utama (text primary) - Dark Grey
  /// Digunakan untuk: body text, judul, teks penting
  static const textPrimary = Color(0xFF212121); // Dark Grey

  /// Warna teks sekunder - Medium Grey
  /// Digunakan untuk: subtitle, text hint, deskripsi, teks kurang penting
  static const textSecondary = Color(0xFF757575); // Medium Grey

  /// Warna untuk status sukses - Green
  /// Digunakan untuk: success snackbar, check icon, positive messages
  static const success = Color(0xFF4CAF50); // Green

  /// Warna untuk status error - Red
  /// Digunakan untuk: error snackbar, error icon, warning messages
  static const error = Color(0xFFF44336); // Red
}