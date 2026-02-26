---
phase: 1
plan: 4
wave: 2
---

# Plan 1.4: Base Workout System & Video Integration

## Objective
Ensure the workout screens correctly parse and render embedded YouTube videos alongside local progression stats.

## Context
- .gsd/SPEC.md
- fitkarma/lib/features/workouts/
- fitkarma/lib/presentation/screens/workouts/

## Tasks

<task type="auto">
  <name>Verify YouTube Player Integration</name>
  <files>
    - fitkarma/lib/presentation/screens/workouts/
  </files>
  <action>
    Check the workout video UI to ensure `youtube_player_flutter` is implemented efficiently. Implement lifecycle handlers to pause videos when the app goes into the background.
  </action>
  <verify>Code inspection for lifecycle observer integration with the player.</verify>
  <done>Video player handles app lifecycle states without crashing or bleeding audio.</done>
</task>

<task type="auto">
  <name>Workout Logging Persistence</name>
  <files>
    - fitkarma/lib/data/repositories/
  </files>
  <action>
    Ensure completed workouts correctly record offline metrics (calories, duration) to Hive before syncing.
  </action>
  <verify>Inspect repository logging function.</verify>
  <done>Workout logs save offline and sync.</done>
</task>

## Success Criteria
- [ ] YouTube player manages lifecycle transitions smoothly.
- [ ] Workout logs persist to Hive correctly.
