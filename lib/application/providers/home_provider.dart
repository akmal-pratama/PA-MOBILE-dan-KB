import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dapur_pintar/application/notifiers/home_notifier.dart';

/// Provider untuk HomeNotifier dan HomeState
/// Ini adalah provider utama untuk state management di home screen
/// Mengelola state seperti search query, filters (difficulty, category, duration), dan scanned ingredients
/// 
/// Penggunaan:
/// ```dart
/// final state = ref.watch(homeNotifierProvider);
/// final notifier = ref.read(homeNotifierProvider.notifier);
/// ```
final homeNotifierProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  /// Membuat instance baru dari HomeNotifier
  /// HomeNotifier akan handle semua logic untuk state management di home screen
  return HomeNotifier();
});