import 'package:flutter/foundation.dart';
import 'package:tflite_v2/tflite_v2.dart';

class Recognition {
  final String label;
  final double confidence;
  final int index;

  Recognition({
    required this.label,
    required this.confidence,
    required this.index,
  });

  @override
  String toString() => '$label (${(confidence * 100).toStringAsFixed(1)}%)';
}

class FoodScannerService {
  bool _isModelLoaded = false;

  Future<void> initModel() async {
    try {
      String? res = await Tflite.loadModel(
        model: "assets/models/food_model.tflite",
        labels: "assets/models/labels.txt",
        numThreads: 1, // recommended for mobile to avoid overheating
        isAsset: true,
        useGpuDelegate: false,
      );
      _isModelLoaded = res != null;
      debugPrint('FoodScanner model loaded: $res');
    } catch (e) {
      debugPrint('Failed to load FoodScanner model: $e');
    }
  }

  Future<List<Recognition>> scanImage(String imagePath) async {
    if (!_isModelLoaded) {
      await initModel();
    }
    if (!_isModelLoaded) return [];

    try {
      var recognitions = await Tflite.runModelOnImage(
        path: imagePath,
        imageMean: 127.5,
        imageStd: 127.5,
        numResults: 3,
        threshold: 0.1,
        asynch: true,
      );

      if (recognitions == null) return [];

      return recognitions.map((res) {
        return Recognition(
          label: res['label'] ?? 'Unknown',
          confidence: (res['confidence'] as num).toDouble(),
          index: res['index'] as int,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error during food scanning: $e');
      return [];
    }
  }

  Future<void> dispose() async {
    await Tflite.close();
  }
}
