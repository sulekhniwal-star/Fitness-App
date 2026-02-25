---
phase: 7
plan: 4
wave: 2
depends_on: ["7.3"]
files_modified:
  - fitkarma/lib/presentation/screens/food/food_scanner_screen.dart
  - fitkarma/lib/presentation/screens/food/food_logging_screen.dart
autonomous: true
must_haves:
  truths:
    - "Camera preview displays in real-time"
    - "Top detection result appears as a floating badge or overlay"
  artifacts:
    - "fitkarma/lib/presentation/screens/food/food_scanner_screen.dart exists"
---

# Plan 7.4: TFLite Implementation - Visual Search UI

<objective>
Build the user interface for visual food recognition, allowing users to log meals by simply pointing their camera at their thali.

Purpose: Dramatically reduce friction in food logging.
Output: FoodScannerScreen.
</objective>

<context>
Load for context:
- fitkarma/lib/presentation/screens/food/food_logging_screen.dart
- fitkarma/lib/domain/services/food_scanner_service.dart
</context>

<tasks>

<task type="auto">
  <name>Create Food Scanner UI</name>
  <files>fitkarma/lib/presentation/screens/food/food_scanner_screen.dart</files>
  <action>
    Implement a camera-based screen using 'camera' package:
    - Full-screen camera preview.
    - Floating 'Analyzing...' indicator with real-time confidence readout.
    - 'Log This' button that appears when confidence > 70%.
    - Integration with 'FoodRepository' to fetch detailed nutrition for the recognized item.
  </action>
  <verify>Open screen, verify camera feed, and mock a detection result to see UI update.</verify>
  <done>Interactive scanner UI built and integrated with inference engine.</done>
</task>

<task type="auto">
  <name>Add Scanner Entry Point</name>
  <files>fitkarma/lib/presentation/screens/food/food_logging_screen.dart</files>
  <action>
    Add a 'Visual Scan' button next to Barcode and Voice icons.
    Link it to the new FoodScannerScreen.
  </action>
  <verify>Button appears and navigates correctly.</verify>
  <done>Feature is discoverable from the main logging flow.</done>
</task>

</tasks>

<verification>
After all tasks, verify:
- [ ] UI is smooth (no frame drops during inference).
- [ ] User can return to logging screen if detection fails.
</verification>

<success_criteria>
- [ ] Camera stream displays correctly on both Android and iOS targets.
- [ ] Recognized food items can be added to the daily log with one tap.
</success_criteria>
