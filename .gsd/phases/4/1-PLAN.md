---
phase: 4
plan: 1
wave: 1
---

# Plan 4.1: AI Health Twin Data Mining

## Objective
Finalize the Health Twin Analytics by mapping its heuristics directly into the offline Step provider and Meal matrices rather than statically mocking inputs, producing real-life tracking.

## Context
- .gsd/SPEC.md
- fitkarma/lib/domain/services/health_twin_service.dart

## Tasks

<task type="auto">
  <name>Bind Real Step Analytics</name>
  <files>
    - fitkarma/lib/domain/services/health_twin_service.dart
  </files>
  <action>
    Refactor `_analyzeWeekendSlump` in `HealthTwinService` to actively parse `stepProvider` arrays (or Hive offline step equivalents dynamically) to pinpoint inactivity dips organically without depending upon hardcoded numeric constant lists.
  </action>
  <verify>Ensure compilation and check analyzer output.</verify>
  <done>Weekend Slump triggers natively on real pedometer drop-offs.</done>
</task>

## Success Criteria
- [ ] Analytics leverage exact offline data sets reliably.
- [ ] Fallbacks operate securely.
