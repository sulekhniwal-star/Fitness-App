---
phase: 3
plan: 3
wave: 2
---

# Plan 3.3: Thali Meal Planner

## Objective
Solidify the Meal Planner provider ensuring recommended nutrition arrays correctly derive offline calculations leveraging the specific `DoshaType` and internal BMR models safely.

## Context
- .gsd/SPEC.md
- fitkarma/lib/data/providers/meal_provider.dart

## Tasks

<task type="auto">
  <name>Dynamic BMR Calculation Initialization</name>
  <files>
    - fitkarma/lib/data/providers/meal_provider.dart
  </files>
  <action>
    Review `MealNotifier.generatePlan`. The MVP algorithm statically leverages "25" as a default age if absent. Ensure fallbacks pull accurately from instantiated `HiveService.userBox` variables (DOB if present) instead of hardcoding whenever viable. Verify that resulting maintenance macros scale securely across weight fluctuations continuously offline.
  </action>
  <verify>Run `flutter analyze` against the meal logic checking edge cases.</verify>
  <done>Maintenance calories generated algorithmically against the local user model accurately map to Dosha arrays.</done>
</task>

## Success Criteria
- [ ] Users obtain recommended Thali combinations immediately natively.
- [ ] Output adjusts correctly following respective physical parameter updates dynamically.
