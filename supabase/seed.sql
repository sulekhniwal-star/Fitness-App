-- ==============================================================================
-- FitKarma Root Database Seed Script
-- WARNING: LOCAL DEVELOPMENT AND TESTING ONLY!
-- DO NOT EXECUTE AGAINST PRODUCTION ENVIRONMENTS.
-- ==============================================================================

-- Safety Assertion: Guard against accidental execution in production databases
DO $$
BEGIN
  IF current_database() LIKE '%prod%' OR current_database() LIKE '%live%' THEN
    RAISE EXCEPTION 'CRITICAL SECURITY VIOLATION: Seed data execution blocked against production database (%)', current_database();
  END IF;
  RAISE NOTICE 'Executing FitKarma local development seed scripts...';
END $$;

-- 1. Reference Catalogs & Master Data
-- \i supabase/seeds/01_reference_catalogs.sql

-- 2. Synthetic Test Personas & Accounts
-- \i supabase/seeds/02_test_personas.sql

-- Product tables and specific seed inserts will be added in TASK 012B / 014.
