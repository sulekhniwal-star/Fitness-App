---
phase: 7
plan: 3
wave: 2
depends_on: ["7.1"]
files_modified:
  - fitkarma/pubspec.yaml
  - fitkarma/lib/domain/services/food_scanner_service.dart
  - fitkarma/assets/models/food_model.tflite
  - fitkarma/assets/models/labels.txt
autonomous: true
must_haves:
  truths:
    - "TFLite interpreter loads successfully without crashes"
    - "Labels.txt contains common Indian food items (Thali, Dosa, Idli, etc.)"
  artifacts:
    - "fitkarma/lib/domain/services/food_scanner_service.dart exists"
---

# Plan 7.3: TFLite Implementation - Model Integration

<objective>
Set up the TensorFlow Lite environment and load a lightweight food recognition model.

Purpose: Enable on-device visual food recognition for zero-latency, zero-cost logging.
Output: TFLite configuration and FoodScannerService.
</objective>

<context>
Load for context:
- fitkarma/pubspec.yaml
- fitkarma/lib/data/repositories/food_repository.dart
</context>

<tasks>

<task type="auto">
  <name>Configure TFLite Dependencies</name>
  <files>fitkarma/pubspec.yaml</files>
  <action>
    Add 'tflite_v2' and 'image' packages to pubspec.yaml.
    Configure assets section to include 'assets/models/' folder.
    Note: Using tflite_v2 for broad compatibility with older Android devices often found in the target Indian demographic.
  </action>
  <verify>flutter pub get completes successfully.</verify>
  <done>Dependencies installed and assets registered.</done>
</task>

<task type="auto">
  <name>Implement Food Scanner Service</name>
  <files>fitkarma/lib/domain/services/food_scanner_service.dart</files>
  <action>
    Create 'FoodScannerService' that:
    - Loads 'food_model.tflite' from assets.
    - Pre-processes Image objects (resize, normalize).
    - Runs inference and returns top-3 results with confidence scores.
    AVOID: Complex threading in this first pass; use basic async inference.
  </action>
  <verify>Check service initialization log for 'Interpreter loaded successfully'.</verify>
  <done>On-device inference engine is ready for image classification.</done>
</task>

</tasks>

<verification>
After all tasks, verify:
- [ ] Interpreter initializes without 'Null pointer' or 'Invalid model' errors.
- [ ] Service can handle a mock Image input without crashing.
</verification>

<success_criteria>
- [ ] TFLite model is bundled and loadable at runtime.
</success_criteria>
