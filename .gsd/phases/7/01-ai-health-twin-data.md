---
phase: 7
plan: 1
wave: 1
depends_on: []
files_modified:
  - fitkarma/lib/data/models/health_insight_model.dart
  - fitkarma/lib/data/models/health_insight_model.g.dart
  - fitkarma/lib/data/providers/insight_provider.dart
autonomous: true
must_haves:
  truths:
    - "HealthInsightModel supports pattern types like 'warning', 'achievement', and 'suggestion'"
    - "Insights are persisted in a dedicated Hive box"
  artifacts:
    - "fitkarma/lib/data/models/health_insight_model.dart exists"
---

# Plan 7.1: AI Health Twin - Predictive Data Modeling

<objective>
Build the data foundation for the AI Health Twin. This enables the system to store and display personalized health patterns derived from offline usage data.

Purpose: Allow the app to "learn" user habits and store them as actionable insights.
Output: HealthInsight model, Hive adapter, and InsightProvider.
</objective>

<context>
Load for context:
- fitkarma/lib/data/models/user_model.dart
- fitkarma/lib/data/models/food_log_model.dart
- fitkarma/lib/data/providers/hive_provider.dart
</context>

<tasks>

<task type="auto">
  <name>Create HealthInsight Model</name>
  <files>fitkarma/lib/data/models/health_insight_model.dart</files>
  <action>
    Define a Hive-annotated model 'HealthInsight' with fields:
    - id (String)
    - type (Enum: pattern, warning, recommendation)
    - title (String)
    - description (String)
    - category (Enum: diet, activity, sleep, medical)
    - createdAt (DateTime)
    - isRead (bool)
    - score (double - certainty of the pattern)
    
    Register the TypeAdapter in hive_service.dart.
  </action>
  <verify>flutter pub run build_runner build --delete-conflicting-outputs</verify>
  <done>HealthInsight model generated with Hive support.</done>
</task>

<task type="auto">
  <name>Implement Insight Provider</name>
  <files>fitkarma/lib/data/providers/insight_provider.dart</files>
  <action>
    Create a StateNotifierProvider 'insightProvider' that:
    - Manages a list of HealthInsights.
    - Provides a method 'addInsight' that saves to 'insightsBox'.
    - Provides 'markAsRead' functionality.
    AVOID: Complex logic in the first pass; keep it to pure state management and storage persistence.
  </action>
  <verify>Check for lib/data/providers/insight_provider.dart existence and successful compile.</verify>
  <done>Insights are persistable and accessible via Riverpod.</done>
</task>

</tasks>

<verification>
After all tasks, verify:
- [ ] HealthInsight adapter registered in hive_service.dart
- [ ] build_runner completes without errors
</verification>

<success_criteria>
- [ ] Model is persistable in Hive.
- [ ] Provider correctly reflects the state of the 'insightsBox'.
</success_criteria>
