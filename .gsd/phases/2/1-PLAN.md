---
phase: 2
plan: 1
wave: 1
---

# Plan 2.1: Robust OCR & Medical Fallbacks

## Objective
Finalize the Medical Scanner OCR functionality, ensuring regex captures the specified metrics reliably and provides robust manual fallbacks.

## Context
- .gsd/SPEC.md
- fitkarma/lib/domain/services/medical_parser_service.dart
- fitkarma/lib/presentation/screens/profile/medical_scanner_screen.dart

## Tasks

<task type="auto">
  <name>Audit Medical Parser Regex</name>
  <files>
    - fitkarma/lib/domain/services/medical_parser_service.dart
  </files>
  <action>
    Review the regex parsing module within `MedicalParserService`. Validate that matches properly capture values for metrics like HbA1c, BP, Cholesterol, and Glucose, even in complex or poorly OCR'ed text logs. Add fallback heuristics if matching fails outright.
  </action>
  <verify>Run `flutter analyze` inside the domain module to ensure code structures cleanly.</verify>
  <done>Regex accurately extracts available metrics without crashing.</done>
</task>

<task type="auto">
  <name>Verify Offline UI Dialogue Sync</name>
  <files>
    - fitkarma/lib/presentation/screens/profile/medical_scanner_screen.dart
  </files>
  <action>
    Verify that `_showEditableDialog` allows the user to manually edit or supplement values securely. Ensure offline model instances (Hive storage insertions) queue securely via the `syncServiceProvider`.
  </action>
  <verify>Visually inspect UI dialogue methods.</verify>
  <done>Dialog permits safe manual data entry.</done>
</task>

## Success Criteria
- [ ] OCR extraction is robust with offline regular expressions.
- [ ] Manual adjustments save properly.
