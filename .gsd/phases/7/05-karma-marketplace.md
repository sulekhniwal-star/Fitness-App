---
phase: 7
plan: 5
wave: 3
depends_on: ["7.2"]
files_modified:
  - fitkarma/lib/data/models/reward_model.dart
  - fitkarma/lib/presentation/screens/profile/karma_marketplace_screen.dart
autonomous: true
must_haves:
  truths:
    - "Karma balance decreases when a reward is claimed"
    - "User cannot claim rewards if balance is insufficient"
  artifacts:
    - "fitkarma/lib/data/models/reward_model.dart exists"
---

# Plan 7.5: Scaling — Karma Marketplace Foundation

<objective>
Implement the redemption half of the Karma system, allowing users to spend their hard-earned points on physical or digital rewards.

Purpose: Complete the gamification loop to drive long-term retention.
Output: Reward model and Marketplace UI.
</objective>

<context>
Load for context:
- fitkarma/lib/data/providers/karma_provider.dart
- fitkarma/lib/presentation/screens/profile/profile_screen.dart
</context>

<tasks>

<task type="auto">
  <name>Create Reward Model</name>
  <files>fitkarma/lib/data/models/reward_model.dart</files>
  <action>
    Define 'Reward' model:
    - id, title, description, karmaCost, imageUrl, type (discount, physical, digital).
    - Create a static list of initial rewards (e.g., '1 month Premium', 'FitKarma T-shirt', 'Yoga Mat discount').
  </action>
  <verify>Compile check.</verify>
  <done>Rewards representable in the codebase.</done>
</task>

<task type="auto">
  <name>Build Marketplace UI</name>
  <files>fitkarma/lib/presentation/screens/profile/karma_marketplace_screen.dart</files>
  <action>
    Create a grid-based reward catalog:
    - Display current Karma balance prominently.
    - Show 'Unlock' buttons with point costs.
    - Implement a confirmation dialog that triggers 'karmaProvider.redeem()'.
    AVOID: Complex shipping/address logic for now; keep it to digital-first fulfillment.
  </action>
  <verify>Redeem a mock reward and confirm points are deducted from Hive.</verify>
  <done>Full gamification loop (Earn -> Spend) is functional.</done>
</task>

</tasks>

<verification>
After all tasks, verify:
- [ ] Karma balance updates in real-time across the app after redemption.
- [ ] 'Insufficient Balance' state is visually clear.
</verification>

<success_criteria>
- [ ] User can successfully "buy" a digital reward using points.
</success_criteria>
