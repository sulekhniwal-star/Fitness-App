import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/karma_provider.dart';
import '../../../core/storage/hive_service.dart';
import '../../../core/sync/sync_service.dart';
import '../../../domain/services/medical_parser_service.dart';
import '../../../data/models/medical_record_model.dart';

class MedicalScannerScreen extends ConsumerStatefulWidget {
  const MedicalScannerScreen({super.key});

  @override
  ConsumerState<MedicalScannerScreen> createState() =>
      _MedicalScannerScreenState();
}

class _MedicalScannerScreenState extends ConsumerState<MedicalScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();

  bool _isProcessing = false;

  Future<void> _processImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      setState(() {
        _isProcessing = true;
      });

      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      final String rawText = recognizedText.text;

      // Parse Using our new static Regex Map Service
      final parsedData = MedicalParserService.parseText(rawText);

      setState(() {
        _isProcessing = false;
      });

      if (!mounted) return;

      if (parsedData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('No recognizable medical data found in the image.')),
        );
        return;
      }

      _showEditableDialog(parsedData);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error analyzing image: $e')),
      );
    }
  }

  void _showEditableDialog(Map<String, String> data) {
    // Keep internal local state for the dialog form edits
    final Map<String, TextEditingController> controllers = {};
    for (var entry in data.entries) {
      controllers[entry.key] = TextEditingController(text: entry.value);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Verify Scanned Data'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: controllers.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: TextFormField(
                    controller: entry.value,
                    decoration: InputDecoration(
                      labelText: entry.key.toUpperCase(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final user = ref.read(authStateProvider).user;
                if (user == null) return;

                final now = DateTime.now();

                // Build models from validated controllers natively
                for (var key in controllers.keys) {
                  final val = controllers[key]!.text;
                  if (val.isEmpty) continue;

                  final record = MedicalRecordModel(
                    id: const Uuid().v4(),
                    userId: user.id,
                    type: key,
                    value: val,
                    unit: _getUnitForType(key),
                    date: now,
                  );

                  // Save Offline
                  HiveService.medicalBox.put(record.id, record);

                  // Queue Pocketbase Sync Syncronization Map Explicitly
                  ref.read(syncServiceProvider).enqueueAction(
                        collection: 'medical_records',
                        operation: 'create',
                        data: record.toJson(),
                      );
                }

                // Award Karma Points explicitly mapped natively mapping 25 points successfully globally
                ref
                    .read(karmaProvider.notifier)
                    .earnKarma(25, 'Uploaded Report Map');

                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('+25 Karma! Records safely logged offline.'),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                );

                // Exit Scanner Screen back into Profile safely
                Navigator.of(context).pop();
              },
              child: const Text('Save to Profile'),
            )
          ],
        );
      },
    );
  }

  String _getUnitForType(String type) {
    switch (type) {
      case 'hba1c':
        return '%';
      case 'bp':
        return 'mmHg';
      case 'cholesterol':
        return 'mg/dL';
      case 'glucose':
        return 'mg/dL';
      case 'hemoglobin':
        return 'g/dL';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Medical Report'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.document_scanner_outlined,
                size: 100,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Digitize your lab reports instantly. We extract vital metrics completely offline, ensuring your privacy natively.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 48),
              if (_isProcessing)
                const CircularProgressIndicator()
              else ...[
                ElevatedButton.icon(
                  onPressed: () => _processImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take a Photo'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _processImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Choose from Gallery'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
