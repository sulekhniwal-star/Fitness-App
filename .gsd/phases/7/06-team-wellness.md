---
phase: 7
plan: 6
wave: 3
depends_on: ["7.5"]
files_modified:
  - fitkarma/lib/data/models/team_model.dart
  - fitkarma/lib/presentation/screens/home/team_challenge_screen.dart
autonomous: true
must_haves:
  truths:
    - "Teams aggregate Karma points from multiple members"
    - "A 'Team Leaderboard' exists distinct from the individual one"
  artifacts:
    - "fitkarma/lib/data/models/team_model.dart exists"
---

# Plan 7.6: Scaling — Team Challenges & Corporate Wellness

<objective>
Introduce group-based health competition, allowing users to form teams for challenges. This targets the corporate wellness segment.

Purpose: Foster social accountability and viral growth through group features.
Output: Team model and Team Challenge UI.
</objective>

<context>
Load for context:
- fitkarma/lib/data/models/challenge_model.dart
- fitkarma/lib/data/providers/leaderboard_provider.dart
</context>

<tasks>

<task type="auto">
  <name>Create Team Infrastructure</name>
  <files>fitkarma/lib/data/models/team_model.dart</files>
  <action>
    Define 'Team' model:
    - id, name, memberIds, totalKarma, logoUrl.
    - Updated 'Challenge' model to support 'Team' participant types.
  </action>
  <verify>Compile check.</verify>
  <done>Data structures support group-based tracking.</done>
</task>

<task type="auto">
  <name>Implement Team Competition UI</name>
  <files>fitkarma/lib/presentation/screens/home/team_challenge_screen.dart</files>
  <action>
    Create a screen for Team Challenges:
    - 'Join a Team' or 'Create Team' flow.
    - Team vs Team leaderboard (ranking teams by average member Karma).
    - Team-specific progress bars for active challenges.
  </action>
  <verify>Create a team, add mock members, and verify rank calculation logic.</verify>
  <done>User can compete as part of a collective, boosting engagement.</done>
</task>

</tasks>

<verification>
After all tasks, verify:
- [ ] Team scores correctly sum up individual member contributions.
- [ ] UI displays cultural references to 'Kabaddi' or 'Cricket Team' dynamics for familiarity.
</verification>

<success_criteria>
- [ ] Functional "Team Leaderboard" successfully ranks groups based on local/sync data.
</success_criteria>
