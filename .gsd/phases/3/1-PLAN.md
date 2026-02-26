---
phase: 3
plan: 1
wave: 1
---

# Plan 3.1: Ayurvedic Dosha Personalization

## Objective
Finalize the Dosha Quiz integration, ensuring the selected Dosha type successfully bridges to the global `userBox` via Hive and queues a mutation upstream to PocketBase via `SyncService` gracefully.

## Context
- .gsd/SPEC.md
- fitkarma/lib/data/providers/dosha_provider.dart
- fitkarma/lib/presentation/screens/profile/dosha_quiz_screen.dart

## Tasks

<task type="auto">
  <name>Synchronize Dosha Result State</name>
  <files>
    - fitkarma/lib/data/providers/dosha_provider.dart
  </files>
  <action>
    Review `DoshaNotifier.setResult`. It currently invokes `pb.collection('users').update` linearly. It must be refactored to utilize `HiveService.userBox.put` for optimistic offline capabilities and `syncServiceProvider.enqueueAction` for asynchronous PocketBase syncing conforming rigidly to "Offline-First" architectural requirements defined in SPEC phase 1.
  </action>
  <verify>Run `flutter analyze` ensuring the synchronization dependencies resolve properly without linear blockages.</verify>
  <done>Dosha type writes resiliently to local schemas and queues into PocketBase asynchronously.</done>
</task>

## Success Criteria
- [ ] Users can complete the Dosha quiz wholly offline.
- [ ] User models optimistically inherit the specified property instantly.
