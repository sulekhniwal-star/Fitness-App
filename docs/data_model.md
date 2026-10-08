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

The existing source does not provide a complete physical schema. Do not infer columns that are not defined.

## 2. Proposed logical entities

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
