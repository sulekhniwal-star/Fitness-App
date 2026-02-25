---
phase: 7
plan: 2
wave: 1
depends_on: ["7.1"]
files_modified:
  - fitkarma/lib/domain/services/health_twin_service.dart
  - fitkarma/lib/presentation/widgets/health_twin_card.dart
autonomous: true
must_haves:
  truths:
    - "Service can identify at least one pattern (e.g., late night eating or inactive weekend)"
    - "UI card properly displays the category and importance of the insight"
  artifacts:
    - "fitkarma/lib/domain/services/health_twin_service.dart exists"
---

# Plan 7.2: AI Health Twin - Offline Pattern Logic

<objective>
Implement the "brains" of the Health Twin — logic that analyzes local logs to produce meaningful patterns and alerts.

Purpose: Turn raw data into actionable health advice without server-side processing.
Output: HealthTwinService and a Dashboard widget for insights.
</objective>

<context>
Load for context:
- fitkarma/lib/data/models/food_log_model.dart
- fitkarma/lib/data/providers/insight_provider.dart
- fitkarma/lib/data/providers/food_provider.dart
- fitkarma/lib/data/providers/step_provider.dart
</context>

<tasks>

<task type="auto">
  <name>Implement Pattern Analysis Logic</name>
  <files>fitkarma/lib/domain/services/health_twin_service.dart</files>
  <action>
    Create 'HealthTwinService' that scans Hive logs (steps, food) for patterns:
    1. 'Late Night Snacker': Meal log after 10 PM in more than 3/7 days.
    2. 'Weekend Slump': Steps on Saturday/Sunday < 50% of weekday average.
    3. 'Dosha Alignment': Eating meals suitable for user's Dosha (using MealRepository logic).
    
    The service should generate 'HealthInsight' objects and add them via 'insightProvider'.
  </action>
  <verify>Call analysis method and check if insights are created in Hive.</verify>
  <done>Service successfully detects behavioral patterns from offline logs.</done>
</task>

<task type="auto">
  <name>Build Health Twin Dashboard Widget</name>
  <files>fitkarma/lib/presentation/widgets/health_twin_card.dart</files>
  <action>
    Create a 'HealthTwinCard' widget that:
    - Displays the latest unread high-score insight.
    - Uses icons based on category (diet = Icons.restaurant, activity = Icons.bolt).
    - Integrates into DashboardTab safely.
    AVOID: Overwhelming the user; show only one impactful insight at a time.
  </action>
  <verify>Insight card appears on Dashboard when a pattern is detected.</verify>
  <done>Insights are visually communicated to the user on the home screen.</done>
</task>

</tasks>

<verification>
After all tasks, verify:
- [ ] Logic correctly identifies a mock "Weekend Slump" pattern.
- [ ] Card layout is responsive and matches AppTheme.
</verification>

<success_criteria>
- [ ] User receives a specific warning/praise notification inside the app based on their data.
</success_criteria>
