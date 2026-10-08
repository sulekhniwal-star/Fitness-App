-- ==============================================================================
-- FitKarma Test Personas Seed (LOCAL & DEV ONLY)
-- Layer: 02_test_personas.sql
-- Description: Deterministic synthetic test profiles for developer workflows.
-- Note: Product tables are created in TASK 012B.
-- ==============================================================================

-- Safety check: Ensure this is NOT executed against production
DO $$
BEGIN
  IF current_database() LIKE '%prod%' THEN
    RAISE EXCEPTION 'CRITICAL: Attempted to run local test user seed against a production database!';
  END IF;
END $$;

-- Persona Definitions (Deterministic UUIDs for automated testing):
-- Persona 1: Urban Tier-1 Professional (Weight loss goal, high protein preference)
-- UUID: 00000000-0000-0000-0000-000000000001
-- Email: arjun.sharma@test.fitkarma.internal
--
-- Persona 2: Tier-2 Family Caregiver (Vegetarian, Gujarati, managing elderly parent diet)
-- UUID: 00000000-0000-0000-0000-000000000002
-- Email: priya.patel@test.fitkarma.internal
--
-- Persona 3: College Student (Budget-conscious, Hindi vernacular voice preference)
-- UUID: 00000000-0000-0000-0000-000000000003
-- Email: rohit.verma@test.fitkarma.internal
