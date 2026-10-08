-- ==============================================================================
-- pgTAP Test Suite: 00000_rls_isolation_test.sql
-- Description: Universal RLS, tenant isolation, and anonymous access denial tests
-- Governing Docs: Brain/security.md, Brain/data_model.md
-- ==============================================================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(37);

-- ------------------------------------------------------------------------------
-- 1. Table Existence Assertions (All 14 CONFIRMED Entities)
-- ------------------------------------------------------------------------------
SELECT has_table('public', 'profiles', 'public.profiles table must exist');
SELECT has_table('public', 'food_catalog', 'public.food_catalog table must exist');
SELECT has_table('public', 'recipes', 'public.recipes table must exist');
SELECT has_table('public', 'cooking_multipliers', 'public.cooking_multipliers table must exist');
SELECT has_table('public', 'health_observations', 'public.health_observations table must exist');
SELECT has_table('public', 'food_logs', 'public.food_logs table must exist');
SELECT has_table('public', 'workouts', 'public.workouts table must exist');
SELECT has_table('public', 'sleep_recovery_logs', 'public.sleep_recovery_logs table must exist');
SELECT has_table('public', 'habits', 'public.habits table must exist');
SELECT has_table('public', 'medications', 'public.medications table must exist');
SELECT has_table('public', 'family_health_relationships', 'public.family_health_relationships table must exist');
SELECT has_table('public', 'entitlements', 'public.entitlements table must exist');
SELECT has_table('public', 'push_tokens', 'public.push_tokens table must exist');
SELECT has_table('public', 'storage_assets', 'public.storage_assets table must exist');
SELECT has_table('public', 'audit_deletion_operations', 'public.audit_deletion_operations table must exist');

-- ------------------------------------------------------------------------------
-- 2. Row Level Security Enabled Assertions (Universal Default-Deny)
-- ------------------------------------------------------------------------------
SELECT results_eq(
  $$ SELECT rowsecurity FROM pg_tables WHERE schemaname = 'public' AND tablename = 'profiles' $$,
  $$ VALUES (true) $$,
  'public.profiles must have RLS enabled'
);

SELECT results_eq(
  $$ SELECT rowsecurity FROM pg_tables WHERE schemaname = 'public' AND tablename = 'food_catalog' $$,
  $$ VALUES (true) $$,
  'public.food_catalog must have RLS enabled'
);

SELECT results_eq(
  $$ SELECT rowsecurity FROM pg_tables WHERE schemaname = 'public' AND tablename = 'recipes' $$,
  $$ VALUES (true) $$,
  'public.recipes must have RLS enabled'
);

SELECT results_eq(
  $$ SELECT rowsecurity FROM pg_tables WHERE schemaname = 'public' AND tablename = 'cooking_multipliers' $$,
  $$ VALUES (true) $$,
  'public.cooking_multipliers must have RLS enabled'
);

SELECT results_eq(
  $$ SELECT rowsecurity FROM pg_tables WHERE schemaname = 'public' AND tablename = 'health_observations' $$,
  $$ VALUES (true) $$,
  'public.health_observations must have RLS enabled'
);

SELECT results_eq(
  $$ SELECT rowsecurity FROM pg_tables WHERE schemaname = 'public' AND tablename = 'food_logs' $$,
  $$ VALUES (true) $$,
  'public.food_logs must have RLS enabled'
);

SELECT results_eq(
  $$ SELECT rowsecurity FROM pg_tables WHERE schemaname = 'public' AND tablename = 'workouts' $$,
  $$ VALUES (true) $$,
  'public.workouts must have RLS enabled'
);

SELECT results_eq(
  $$ SELECT rowsecurity FROM pg_tables WHERE schemaname = 'public' AND tablename = 'sleep_recovery_logs' $$,
  $$ VALUES (true) $$,
  'public.sleep_recovery_logs must have RLS enabled'
);

SELECT results_eq(
  $$ SELECT rowsecurity FROM pg_tables WHERE schemaname = 'public' AND tablename = 'habits' $$,
  $$ VALUES (true) $$,
  'public.habits must have RLS enabled'
);

SELECT results_eq(
  $$ SELECT rowsecurity FROM pg_tables WHERE schemaname = 'public' AND tablename = 'medications' $$,
  $$ VALUES (true) $$,
  'public.medications must have RLS enabled'
);

SELECT results_eq(
  $$ SELECT rowsecurity FROM pg_tables WHERE schemaname = 'public' AND tablename = 'family_health_relationships' $$,
  $$ VALUES (true) $$,
  'public.family_health_relationships must have RLS enabled'
);

SELECT results_eq(
  $$ SELECT rowsecurity FROM pg_tables WHERE schemaname = 'public' AND tablename = 'entitlements' $$,
  $$ VALUES (true) $$,
  'public.entitlements must have RLS enabled'
);

SELECT results_eq(
  $$ SELECT rowsecurity FROM pg_tables WHERE schemaname = 'public' AND tablename = 'push_tokens' $$,
  $$ VALUES (true) $$,
  'public.push_tokens must have RLS enabled'
);

SELECT results_eq(
  $$ SELECT rowsecurity FROM pg_tables WHERE schemaname = 'public' AND tablename = 'storage_assets' $$,
  $$ VALUES (true) $$,
  'public.storage_assets must have RLS enabled'
);

SELECT results_eq(
  $$ SELECT rowsecurity FROM pg_tables WHERE schemaname = 'public' AND tablename = 'audit_deletion_operations' $$,
  $$ VALUES (true) $$,
  'public.audit_deletion_operations must have RLS enabled'
);

-- ------------------------------------------------------------------------------
-- 3. delete_user_data RPC Function Assertion
-- ------------------------------------------------------------------------------
SELECT has_function('public', 'delete_user_data', ARRAY['uuid'], 'delete_user_data(uuid) function must exist');

-- ------------------------------------------------------------------------------
-- 4. Anonymous Role Denial Test (Anon Cannot Read Sensitive Tables)
-- ------------------------------------------------------------------------------
SET LOCAL ROLE anon;
SET LOCAL "request.jwt.claims" = '{}';

SELECT is_empty(
  $$ SELECT id FROM public.profiles $$,
  'Anonymous role cannot read public.profiles'
);

SELECT is_empty(
  $$ SELECT id FROM public.food_logs $$,
  'Anonymous role cannot read public.food_logs'
);

SELECT is_empty(
  $$ SELECT id FROM public.health_observations $$,
  'Anonymous role cannot read public.health_observations'
);

-- ------------------------------------------------------------------------------
-- 5. Tenant Isolation Test (User A Cannot Read User B)
-- ------------------------------------------------------------------------------
-- Switch to service_role to seed test data for user A and user B
SET LOCAL ROLE service_role;

DO $$
DECLARE
  v_user_a uuid := '00000000-0000-0000-0000-000000000001';
  v_user_b uuid := '00000000-0000-0000-0000-000000000002';
BEGIN
  -- Insert dummy profile and food log for User A
  INSERT INTO public.profiles (user_id, display_name)
  VALUES (v_user_a, 'User A (Arjun)')
  ON CONFLICT (user_id) DO NOTHING;

  INSERT INTO public.food_logs (user_id, logged_at, meal_slot, food_name, portion_quantity, portion_unit)
  VALUES (v_user_a, now(), 'lunch', 'Moong Dal Khichdi', 1.5, 'katori');

  -- Insert dummy profile and food log for User B
  INSERT INTO public.profiles (user_id, display_name)
  VALUES (v_user_b, 'User B (Priya)')
  ON CONFLICT (user_id) DO NOTHING;

  INSERT INTO public.food_logs (user_id, logged_at, meal_slot, food_name, portion_quantity, portion_unit)
  VALUES (v_user_b, now(), 'dinner', 'Methi Thepla', 2.0, 'piece');
END $$;

-- Switch to authenticated User A
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "00000000-0000-0000-0000-000000000001", "role": "authenticated"}';

SELECT results_eq(
  $$ SELECT display_name FROM public.profiles WHERE user_id = '00000000-0000-0000-0000-000000000001' $$,
  $$ VALUES ('User A (Arjun)') $$,
  'User A can read their own profile'
);

-- Switch to authenticated User B
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "00000000-0000-0000-0000-000000000002", "role": "authenticated"}';

SELECT is_empty(
  $$ SELECT id FROM public.profiles WHERE user_id = '00000000-0000-0000-0000-000000000001' $$,
  'User B cannot read User A profile (Isolation Confirmed)'
);

SELECT is_empty(
  $$ SELECT id FROM public.food_logs WHERE user_id = '00000000-0000-0000-0000-000000000001' $$,
  'User B cannot read User A food logs (Isolation Confirmed)'
);

SELECT * FROM finish();
ROLLBACK;
