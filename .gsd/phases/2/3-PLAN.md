---
phase: 2
plan: 3
wave: 2
---

# Plan 2.3: Community Challenges & Teams

## Objective
Build upon the `ChallengeProvider` to accurately process Team participation, ensuring multi-user leaderboards reflect accurately across instances.

## Context
- .gsd/SPEC.md
- fitkarma/lib/data/providers/challenge_provider.dart
- fitkarma/lib/data/providers/team_provider.dart

## Tasks

<task type="auto">
  <name>Verify Challenge Enrollment Synchronization</name>
  <files>
    - fitkarma/lib/data/providers/challenge_provider.dart
  </files>
  <action>
    Audit `-joinChallenge` mechanics to make sure the PocketBase patch requests properly attach the user's ID into the `participants` relation securely.
  </action>
  <verify>Verify challenge logic is valid mathematically via analyzer.</verify>
  <done>Challenge participants are joined asynchronously.</done>
</task>

<task type="auto">
  <name>Team Aggregation Models</name>
  <files>
    - fitkarma/lib/data/providers/team_provider.dart
  </files>
  <action>
    If Teams are used for subset challenges, make sure `team_provider.dart` aggregates step logs across users properly, fetching group statistics without rate limiting the SDK.
  </action>
  <verify>Ensure `team_provider` fetches efficiently.</verify>
  <done>Teams parse their aggregated step metadata via optimized backend queries.</done>
</task>

## Success Criteria
- [ ] Users can safely enroll in robust challenges.
- [ ] Team models calculate relative positioning securely.
