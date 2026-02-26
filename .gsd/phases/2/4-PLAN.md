---
phase: 2
plan: 4
wave: 2
---

# Plan 2.4: GPS Tracking Setup for Indian Sports

## Objective
Establish location listening to record tracks for Indian Sports and specialized GPS-backed workouts.

## Context
- .gsd/SPEC.md
- fitkarma/lib/data/providers/gps_provider.dart
- fitkarma/pubspec.yaml

## Tasks

<task type="auto">
  <name>Integrate Geolocator Provider Streams</name>
  <files>
    - fitkarma/lib/data/providers/gps_provider.dart
  </files>
  <action>
    Review the GPS provider streams and ensure `geolocator` listens accurately natively while preventing background battery drain. Add safeguards for absent permissions.
  </action>
  <verify>Compile and inspect coordinate streams.</verify>
  <done>Stream activates on-demand and parses coordinates.</done>
</task>

<task type="auto">
  <name>Map Route Persistence to Database</name>
  <files>
    - fitkarma/lib/data/models/workout_model.dart
  </files>
  <action>
    Link the resulting GPS routes to `WorkoutModel`s if the category requires mapping, ensuring coordinates can be saved offline securely inside `Hive` alongside the base duration constraints.
  </action>
  <verify>Check `WorkoutModel` polyline/coordinate inclusion.</verify>
  <done>GPS polygons correctly attach to `WorkoutModels` on completion.</done>
</task>

## Success Criteria
- [ ] GPS listeners respect Android/iOS battery saving metrics.
- [ ] Coordinates persist into workout summaries successfully.
