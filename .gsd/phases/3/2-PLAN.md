---
phase: 3
plan: 2
wave: 1
---

# Plan 3.2: Festival Modes & Fasting

## Objective
Enable cultural fasting periods (like Navratri) to automatically configure daily baseline caloric goals locally without disrupting persistent algorithms.

## Context
- .gsd/SPEC.md
- fitkarma/lib/data/providers/festival_provider.dart

## Tasks

<task type="auto">
  <name>Bind Global Calorie Targets</name>
  <files>
    - fitkarma/lib/data/providers/festival_provider.dart
  </files>
  <action>
    Connect `FestivalNotifier.getAdjustedCalorieGoal` mathematically into whatever core logic computes the total recommended nutrition targets, likely accessed via the overarching `meal_provider` or food macros logic. Verify that multipliers engage only on explicit festival dates gracefully.
  </action>
  <verify>Ensure `FestivalRepository` logic outputs correctly parsed metadata parameters based on local device boundaries.</verify>
  <done>Daily intake algorithms incorporate adjusted Multipliers automatically during Indian fasts.</done>
</task>

## Success Criteria
- [ ] Caloric goals cleanly throttle back autonomously on targeted dates (e.g., multiplier algorithms function properly).
- [ ] App logic correctly respects user calendar metrics offline.
