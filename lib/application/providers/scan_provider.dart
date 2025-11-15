import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dapur_pintar/application/notifiers/scan_notifier.dart';

/// Provider untuk ScanNotifier dan ScanState
/// Mengelola state untuk fitur pemindaian/deteksi bahan dari gambar
/// State mencakup: isProcessing (sedang memproses), detectedIngredients (bahan terdeteksi), error, capturedImages
/// 
/// Penggunaan:
/// ```dart
/// final state = ref.watch(scanNotifierProvider);
/// final notifier = ref.read(scanNotifierProvider.notifier);
/// ```
final scanNotifierProvider = StateNotifierProvider<ScanNotifier, ScanState>((ref) {
  /// Membuat instance baru dari ScanNotifier
  /// ScanNotifier akan handle semua logic untuk image detection dan ingredient scanning
  return ScanNotifier();
});