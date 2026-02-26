---
phase: 1
plan: 1
wave: 1
---

# Plan 1.1: Core Architecture & State Management Setup

## Objective
Verify and solidify the foundational offline-first architecture, ensuring Hive local storage and PocketBase backend integration are correctly managed by Riverpod.

## Context
- .gsd/SPEC.md
- .gsd/ARCHITECTURE.md
- fitkarma/lib/main.dart
- fitkarma/pubspec.yaml

## Tasks

<task type="auto">
  <name>Audit Core Initialization Logic</name>
  <files>
    - fitkarma/lib/main.dart
  </files>
  <action>
    Review the app's `main.dart` or core initialization files to ensure Hive is initialized properly before PocketBase, and that the `ProviderScope` is correctly injecting required initial state. If missing, implement the initialization sequence.
  </action>
  <verify>Run `flutter analyze` to ensure structural code integrity.</verify>
  <done>Init sequence verifies Hive -> PocketBase -> Riverpod.</done>
</task>

<task type="auto">
  <name>Validate Core Dependencies</name>
  <files>
    - fitkarma/pubspec.yaml
  </files>
  <action>
    Audit pubspec.yaml to ensure all core packages (hive, riverpod, pocketbase) are up-to-date and correctly versioned as per STACK.md.
  </action>
  <verify>Run `flutter pub get` successfully.</verify>
  <done>Dependencies resolve without conflicts.</done>
</task>

## Success Criteria
- [ ] Hive and PocketBase are properly initialized on startup.
- [ ] Environment builds without errors.
