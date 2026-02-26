---
phase: 1
plan: 5
wave: 3
---

# Plan 1.5: Karma Gamification Foundation

## Objective
Solidify the Karma point system, ensuring offline actions (like steps taken) reliably calculate and cache earned points before syncing.

## Context
- .gsd/SPEC.md
- fitkarma/lib/features/karma/

## Tasks

<task type="auto">
  <name>Pedometer / Karma Sync Logic</name>
  <files>
    - fitkarma/lib/features/karma/
  </files>
  <action>
    Review the mechanism tying step tracking to Karma points (e.g. Cricket overs conversion). Verify that points are awarded according to the SPEC.
  </action>
  <verify>Identify the point conversion calculation in the codebase.</verify>
  <done>Karma logic for step goals is correctly mapped.</done>
</task>

<task type="auto">
  <name>Offline Karma Transaction Queue</name>
  <files>
    - fitkarma/lib/data/repositories/
  </files>
  <action>
    Ensure Karma transactions are queued locally. As per the SPEC, the server is the source of truth ("Server wins") for Karma, so ensure proper validation upon sync.
  </action>
  <verify>Analyze sync logic for conflict resolution handling.</verify>
  <done>Karma sync implements 'Server wins' logic.</done>
</task>

## Success Criteria
- [ ] Steps accurately convert to Karma offline.
- [ ] Sync resolves conflicts in favor of the server.
