# FitKarma Logical Data Model

> Status labels: **CONFIRMED** = named by current source documentation; **PROPOSED** = needed for the expanded design but not confirmed as an existing physical table.

## 1. Confirmed/explicit concepts

- users / auth identity
- profiles
- recipes and Indian food catalog
- cooking multipliers
- health observations
- food logs
- workouts
- sleep/recovery data
- habits
- medications
- family health relationships
- entitlements
- push tokens
- storage assets
- audit/deletion operations

The existing source does not provide a complete physical schema. Do not infer columns that are not defined; all concrete physical columns instantiated in `supabase/migrations/20261008000001_baseline_schema_and_rls.sql` are explicitly documented below as **PROPOSED** specifications.

## 2. Physical Baseline Schema (TASK 012B Implementation)

All CONFIRMED concepts are instantiated with universal default-deny Row Level Security (RLS) and ownership keys (`user_id REFERENCES auth.users(id) ON DELETE CASCADE`) forming the foundation for the `delete_user_data` cascading erasure.

Columns beyond the historical entity names are classified as **PROPOSED**:

1. `public.profiles`:
   - Status: CONFIRMED entity
   - Proposed columns: `id` (uuid), `user_id` (uuid, fk), `display_name` (text), `locale` (text), `metadata` (jsonb), `created_at` (timestamptz), `updated_at` (timestamptz)
2. `public.food_catalog`:
   - Status: CONFIRMED entity (Indian food catalog)
   - Proposed columns: `id` (uuid), `user_id` (uuid, fk, nullable for system items), `name` (text), `regional_names` (jsonb), `calories_per_100g`, `protein_per_100g`, `carbs_per_100g`, `fat_per_100g`, `fiber_per_100g` (numeric), `is_system` (boolean), `metadata` (jsonb), timestamps
3. `public.recipes`:
   - Status: CONFIRMED entity
   - Proposed columns: `id` (uuid), `user_id` (uuid, fk), `name` (text), `servings` (int), `total_calories` (numeric), `metadata` (jsonb), timestamps
4. `public.cooking_multipliers`:
   - Status: CONFIRMED entity
   - Proposed columns: `id` (uuid), `user_id` (uuid, fk, nullable for system defaults), `food_name` (text), `cooking_state` (text), `yield_factor` (numeric), `is_system` (boolean), `metadata` (jsonb), timestamps
5. `public.health_observations`:
   - Status: CONFIRMED entity
   - Proposed columns: `id` (uuid), `user_id` (uuid, fk), `metric_type` (text), `observed_at` (timestamptz), `source` (text), `value_numeric` (numeric), `value_text` (text), `unit` (text), `metadata` (jsonb), `created_at` (timestamptz)
6. `public.food_logs`:
   - Status: CONFIRMED entity
   - Proposed columns: `id` (uuid), `user_id` (uuid, fk), `logged_at` (timestamptz), `meal_slot` (text), `food_name` (text), `portion_quantity` (numeric), `portion_unit` (text), `calories`, `protein_grams`, `carbs_grams`, `fat_grams` (numeric), `metadata` (jsonb), timestamps
7. `public.workouts`:
   - Status: CONFIRMED entity
   - Proposed columns: `id` (uuid), `user_id` (uuid, fk), `title` (text), `started_at` (timestamptz), `ended_at` (timestamptz), `calories_burned` (numeric), `source` (text), `metadata` (jsonb), timestamps
8. `public.sleep_recovery_logs`:
   - Status: CONFIRMED entity (sleep/recovery)
   - Proposed columns: `id` (uuid), `user_id` (uuid, fk), `sleep_date` (date), `duration_minutes` (int), `sleep_score` (int), `recovery_score` (int), `source` (text), `metadata` (jsonb), timestamps
9. `public.habits`:
   - Status: CONFIRMED entity
   - Proposed columns: `id` (uuid), `user_id` (uuid, fk), `title` (text), `frequency` (text), `target_value` (numeric), `target_unit` (text), `is_active` (boolean), `metadata` (jsonb), timestamps
10. `public.medications`:
    - Status: CONFIRMED entity
    - Proposed columns: `id` (uuid), `user_id` (uuid, fk), `name` (text), `dosage` (text), `frequency` (text), `instructions` (text), `is_active` (boolean), `metadata` (jsonb), timestamps
11. `public.family_health_relationships`:
    - Status: CONFIRMED entity
    - Proposed columns: `id` (uuid), `user_id` (uuid, fk), `related_user_id` (uuid, fk), `relationship_type` (text), `consent_status` (text), `consented_at` (timestamptz), `revoked_at` (timestamptz), `metadata` (jsonb), timestamps
12. `public.entitlements`:
    - Status: CONFIRMED entity
    - Proposed columns: `id` (uuid), `user_id` (uuid, fk), `plan_code` (text), `status` (text), `starts_at` (timestamptz), `expires_at` (timestamptz), `metadata` (jsonb), timestamps
13. `public.push_tokens`:
    - Status: CONFIRMED entity
    - Proposed columns: `id` (uuid), `user_id` (uuid, fk), `token` (text), `platform` (text), `device_id` (text), `is_active` (boolean), timestamps
14. `public.storage_assets`:
    - Status: CONFIRMED entity
    - Proposed columns: `id` (uuid), `user_id` (uuid, fk), `bucket_id` (text), `storage_path` (text), `mime_type` (text), `file_size_bytes` (bigint), `metadata` (jsonb), `created_at` (timestamptz)
15. `public.audit_deletion_operations`:
    - Status: CONFIRMED entity (audit/deletion)
    - Proposed columns: `id` (uuid), `user_id` (uuid, fk), `operation_type` (text), `status` (text), `details` (jsonb), `requested_at` (timestamptz), `completed_at` (timestamptz)

## 3. Proposed logical entities

### `portions` — PROPOSED
Purpose: canonical portion units and conversion metadata.
Fields: `id`, `food_id`, `unit`, `quantity`, `base_grams_or_ml`, `confidence`, timestamps.

### `recipes` — CONFIRMED
Purpose: regional recipes and structured nutrition metadata.

### `recipe_ingredients` — PROPOSED
Purpose: recipe composition and ingredient quantities.

### `cooking_multipliers` — CONFIRMED
Purpose: raw-to-cooked yield/cooking transformation factors.

### `tadka_estimates` — PROPOSED
Purpose: low/medium/high tempering fat estimates and provenance.

### `family_groups` / `family_members` / `family_permissions` — PROPOSED
Purpose: consented household relationships and scoped access.

### `subscriptions` / `payment_customers` / `payment_orders` / `payment_transactions` / `upi_mandates` / `payment_webhooks` — PROPOSED
Purpose: provider-neutral commercial state plus Razorpay reconciliation data.

### `ai_interactions` — PROPOSED
Purpose: bounded observability for AI requests/results with retention rules.

### `whatsapp_interactions` — PROPOSED
Purpose: inbound/outbound message correlation and consent/processing metadata.

### `health_integration_sources` — PROPOSED
Purpose: source attribution and connection state for Health Connect/Apple Health and future providers.

### `sync_queue` — PROPOSED
Purpose: offline outbox items, attempts, retries and idempotency.

### `audit_logs` — PROPOSED
Purpose: security/admin/deletion/payment events requiring auditability.

## 3. Nutrition relationships

```text
Food Entity
  ├── Portions
  ├── Cooking Multipliers
  └── Tadka Estimate

Recipe
  └── Recipe Ingredients → Food Entities

Family Recipe Log
  └── consumed_percentage → user Food Log
```

## 4. Data lifecycle

Sensitive records must have a deletion path and ownership policy. Family access must be removed when consent is revoked. AI media must follow an explicit retention policy. Payment records are retained only as legally/operationally required.

## 5. Open decisions

- Physical table names and exact schemas
- Whether provider webhook payloads are persisted in full or minimally normalized
- Conflict model for health observations and food logs
- Exact retention windows
- Partitioning/index strategy at scale
