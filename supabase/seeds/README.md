# FitKarma Seed & Test Data Convention

## Purpose & Scope
This directory governs seed and test fixtures for local development, CI test suites, and regression testing.

## Strict Production Prohibition
> [!CAUTION]
> **SEED DATA MUST NEVER BE RUN IN PRODUCTION.**
> Production databases are populated strictly via user self-onboarding and verified external data pipelines (e.g., IFCT 2017 nutritional catalog imports).

## Conventions & Segregation

### 1. File Numbering & Layering
- `01_reference_catalogs.sql`: System-wide enums and reference lookup data (e.g., Indian regional meal slots, standard household portion units: katori, roti, tablespoon).
- `02_test_personas.sql`: Synthetic testing personas for local developer and automated test validation.

### 2. Test Persona Identifier Convention
- All synthetic test users must use reserved deterministic test UUIDs in the `00000000-0000-0000-0000-00000000000X` series.
- Synthetic email addresses must use the domain `@test.fitkarma.internal`.
- Test phone numbers must use dummy E.164 numbers (e.g., `+919999900001`).
- All test user rows must include metadata attribute: `{"is_synthetic_test_user": true}`.

### 3. Execution
When running `supabase db reset`, Supabase automatically loads `supabase/seed.sql`.
