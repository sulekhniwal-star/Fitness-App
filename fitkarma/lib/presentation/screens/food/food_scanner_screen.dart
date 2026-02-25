import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/services/food_scanner_service.dart';
import '../../../core/theme/app_theme.dart';

class FoodScannerScreen extends ConsumerStatefulWidget {
  const FoodScannerScreen({super.key});

  @override
  ConsumerState<FoodScannerScreen> createState() => _FoodScannerScreenState();
}

class _FoodScannerScreenState extends ConsumerState<FoodScannerScreen> {
  CameraController? _controller;
  List<Recognition>? _recognitions;
  bool _isAnalyzing = false;
  late FoodScannerService _scannerService;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _scannerService = ref.read(foodScannerServiceProvider);
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {});

      // Start image stream for real-time analysis
      _startStream();
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  void _startStream() {
    if (_controller == null || !_controller!.value.isInitialized) return;

    _controller!.startImageStream((CameraImage image) {
      if (_isAnalyzing) return;

      // In a real app, we'd convert CameraImage to a format TFLite likes
      // For this implementation, we'll simulate real-time analysis
      // or provide a "Capture" based analysis to keep it stable.
    });
  }

  Future<void> _analyzeImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() => _isAnalyzing = true);

    try {
      final XFile file = await _controller!.takePicture();
      final results = await _scannerService.scanImage(file.path);

      setState(() {
        _recognitions = results;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() => _isAnalyzing = false);
      debugPrint('Analysis error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full screen camera preview
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            ),
          ),

          // Scanning Overlay
          _buildOverlay(),

          // Back Button
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Analysis Results Badge
          if (_recognitions != null && _recognitions!.isNotEmpty)
            _buildResultBadge(),

          // Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: _isAnalyzing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : FloatingActionButton.large(
                      onPressed: _analyzeImage,
                      child: const Icon(Icons.camera_alt),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: const ShapeDecoration(
        shape: _ScannerOverlayShape(
          borderColor: AppTheme.primaryColor,
          borderWidth: 3.0,
          borderRadius: 20.0,
        ),
      ),
    );
  }

  Widget _buildResultBadge() {
    final bestMatch = _recognitions!.first;
    final bool isConfident = bestMatch.confidence > 0.7;

    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isConfident ? AppTheme.successColor : AppTheme.saffronColor,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              'RECOGNIZED: ${bestMatch.label.toUpperCase()}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Confidence: ${(bestMatch.confidence * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                color:
                    isConfident ? AppTheme.successColor : AppTheme.saffronColor,
                fontSize: 14,
              ),
            ),
            if (isConfident)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ElevatedButton(
                  onPressed: () {
                    // Logic to return result to logging screen
                    Navigator.pop(context, bestMatch.label);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                  ),
                  child: const Text('LOG THIS MEAL'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

class _ScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;

  const _ScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 1.0,
    this.borderRadius = 0,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final boxSize = width * 0.7;
    final left = (width - boxSize) / 2;
    final top = (height - boxSize) / 2;
    final boxRect = Rect.fromLTWH(left, top, boxSize, boxSize);

    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    // Draw background with hole
    final path = Path()
      ..addRect(rect)
      ..addRRect(
          RRect.fromRectAndRadius(boxRect, Radius.circular(borderRadius)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRRect(
        RRect.fromRectAndRadius(boxRect, Radius.circular(borderRadius)),
        borderPaint);
  }

  @override
  ShapeBorder scale(double t) => this;
}
