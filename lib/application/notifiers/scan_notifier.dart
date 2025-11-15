import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
class ScanState {
  final bool isProcessing;
  final List<String>? detectedIngredients;
  final String? error;
  final List<XFile> capturedImages;

  ScanState({
    this.isProcessing = false,
    this.detectedIngredients,
    this.error,
    this.capturedImages = const [],
  });

  ScanState copyWith({
    bool? isProcessing,
    List<String>? detectedIngredients,
    String? error,
    List<XFile>? capturedImages,
  }) {
    return ScanState(
    
      isProcessing: isProcessing ?? this.isProcessing,
      detectedIngredients: detectedIngredients ?? this.detectedIngredients,
      error: error,
      capturedImages: capturedImages ?? this.capturedImages,
    );
  }
}
class ScanNotifier extends StateNotifier<ScanState> {
  ScanNotifier() : super(ScanState());
  final ImagePicker _picker = ImagePicker();

  static const String BASE_URL =
      'https://GalaxionZero-raw-indonesian-food-detection.hf.space';
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
      );

      if (image != null) {
        final updatedImages = List<XFile>.from(state.capturedImages)..add(image);
        state = state.copyWith(capturedImages: updatedImages);
      }
    } catch (e) {
      state = state.copyWith(error: 'Gagal memilih gambar: ${e.toString()}');
    }
  }
  Future<String?> _classifySingleImage(File imageFile) async {
    try {
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      var callUrl = Uri.parse('$BASE_URL/gradio_api/call/predict');
      var requestBody = json.encode({
        "data": [
          {
            "path": "data:image/jpeg;base64,$base64Image",
            "url": "data:image/jpeg;base64,$base64Image",
            "size": imageBytes.length,
            "orig_name": "image.jpg",
            "mime_type": "image/jpeg"
          }
        ]
      });

      var callResponse = await http.post(
        callUrl,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      ).timeout(Duration(seconds: 30));

      if (callResponse.statusCode != 200) {
        throw Exception('Call failed: ${callResponse.statusCode}');
      }
      var callResult = json.decode(callResponse.body);
      String eventId = callResult['event_id'];
      var resultUrl = Uri.parse('$BASE_URL/gradio_api/call/predict/$eventId');
      var request = http.Request('GET', resultUrl);
      var streamedResponse = await request.send().timeout(Duration(seconds: 60));

      if (streamedResponse.statusCode != 200) {
        throw Exception('Stream failed: ${streamedResponse.statusCode}');
      }
      await for (var chunk in streamedResponse.stream.transform(utf8.decoder)) {
        var lines = chunk.split('\n');
        for (var line in lines) {
          if (!line.startsWith('data: ') || line.length < 10) continue;

          var jsonStr = line.substring(6).trim();
          if (jsonStr.isEmpty) continue;

          try {
            var data = json.decode(jsonStr);

            if (data is List && data.isNotEmpty) {
              var firstItem = data[0];

              if (firstItem is Map && firstItem.containsKey('confidences')) {
                var confidences = firstItem['confidences'] as List;
                double maxConfidence = 0.0;
                String topLabel = '';

                for (var item in confidences) {
                  double confidence = (item['confidence'] as num).toDouble();
                  if (confidence > maxConfidence) {
                    maxConfidence = confidence;
                    topLabel = item['label'];
                  }
                }

                return topLabel; 
              }
            }
          } catch (e) {
            continue;
          }
        }
      }

      throw Exception('No result found in stream');
    } catch (e) {
      print('Classification error: $e');
      return null;
    }
  }
  Future<void> processImages() async {
    if (state.capturedImages.isEmpty) return;

    state = state.copyWith(isProcessing: true, error: null);

    try {
      List<String> detectedIngredients = [];
      for (var xfile in state.capturedImages) {
        final imageFile = File(xfile.path);
        final prediction = await _classifySingleImage(imageFile);

        if (prediction != null && prediction.isNotEmpty) {
          detectedIngredients.add(prediction);
        }
      }

      if (detectedIngredients.isEmpty) {
        throw Exception('No ingredients detected');
      }
      detectedIngredients = detectedIngredients.toSet().toList();

      state = state.copyWith(
        isProcessing: false,
        detectedIngredients: detectedIngredients,
        capturedImages: [],
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Failed to process images: $e',
      );
    }
  }

  void resetDetection() {
 state = ScanState();
}

  void removeImage(int index) {
    if (index < 0 || index >= state.capturedImages.length) return;
    final updatedImages = List<XFile>.from(state.capturedImages)
      ..removeAt(index);
    state = state.copyWith(capturedImages: updatedImages);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
