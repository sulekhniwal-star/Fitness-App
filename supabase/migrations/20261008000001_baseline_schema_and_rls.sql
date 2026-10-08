-- ==============================================================================
-- Migration: 20261008000001_baseline_schema_and_rls.sql
-- Description: Baseline relational schema and universal default-deny RLS
-- Governing Docs: Brain/data_model.md, Brain/security.md, Brain/api_contract.md
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. PROFILES (CONFIRMED)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name text,
  locale text DEFAULT 'en' NOT NULL,
  metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "profiles_owner_select" ON public.profiles
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "profiles_owner_insert" ON public.profiles
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "profiles_owner_update" ON public.profiles
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "profiles_owner_delete" ON public.profiles
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 2. RECIPES AND INDIAN FOOD CATALOG (CONFIRMED)
-- ------------------------------------------------------------------------------
-- 2A. Food Catalog (System catalog + custom user additions)
CREATE TABLE IF NOT EXISTS public.food_catalog (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE, -- NULL for system reference items
  name text NOT NULL,
  regional_names jsonb DEFAULT '{}'::jsonb NOT NULL,
  calories_per_100g numeric(8, 2),
  protein_per_100g numeric(8, 2),
  carbs_per_100g numeric(8, 2),
  fat_per_100g numeric(8, 2),
  fiber_per_100g numeric(8, 2),
  is_system boolean DEFAULT false NOT NULL,
  metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

ALTER TABLE public.food_catalog ENABLE ROW LEVEL SECURITY;

-- Authenticated users can view system foods OR their own custom entries
CREATE POLICY "food_catalog_select" ON public.food_catalog
  FOR SELECT TO authenticated
  USING (is_system = true OR user_id IS NULL OR auth.uid() = user_id);

-- Authenticated users can only insert their own custom entries
CREATE POLICY "food_catalog_owner_insert" ON public.food_catalog
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id AND is_system = false);

-- Authenticated users can only update their own custom entries
CREATE POLICY "food_catalog_owner_update" ON public.food_catalog
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id AND is_system = false)
  WITH CHECK (auth.uid() = user_id AND is_system = false);

-- Authenticated users can only delete their own custom entries
CREATE POLICY "food_catalog_owner_delete" ON public.food_catalog
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id AND is_system = false);

-- 2B. Recipes (User-created recipes)
CREATE TABLE IF NOT EXISTS public.recipes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name text NOT NULL,
  servings integer DEFAULT 1 NOT NULL,
  total_calories numeric(8, 2),
  metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

ALTER TABLE public.recipes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "recipes_owner_select" ON public.recipes
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "recipes_owner_insert" ON public.recipes
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "recipes_owner_update" ON public.recipes
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "recipes_owner_delete" ON public.recipes
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 3. COOKING MULTIPLIERS (CONFIRMED)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.cooking_multipliers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE, -- NULL for system multipliers
  food_name text NOT NULL,
  cooking_state text NOT NULL, -- 'raw', 'boiled', 'roasted', 'fried'
  yield_factor numeric(6, 3) NOT NULL,
  is_system boolean DEFAULT false NOT NULL,
  metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

ALTER TABLE public.cooking_multipliers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "cooking_multipliers_select" ON public.cooking_multipliers
  FOR SELECT TO authenticated
  USING (is_system = true OR user_id IS NULL OR auth.uid() = user_id);

CREATE POLICY "cooking_multipliers_owner_insert" ON public.cooking_multipliers
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id AND is_system = false);

CREATE POLICY "cooking_multipliers_owner_update" ON public.cooking_multipliers
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id AND is_system = false)
  WITH CHECK (auth.uid() = user_id AND is_system = false);

CREATE POLICY "cooking_multipliers_owner_delete" ON public.cooking_multipliers
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id AND is_system = false);

-- ------------------------------------------------------------------------------
-- 4. HEALTH OBSERVATIONS (CONFIRMED)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.health_observations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  metric_type text NOT NULL, -- 'steps', 'heart_rate', 'blood_glucose', 'blood_pressure', 'weight'
  observed_at timestamptz NOT NULL,
  source text NOT NULL, -- 'health_connect', 'apple_health', 'manual', 'cgm'
  value_numeric numeric(12, 4),
  value_text text,
  unit text,
  metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL
);

ALTER TABLE public.health_observations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "health_observations_owner_select" ON public.health_observations
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "health_observations_owner_insert" ON public.health_observations
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "health_observations_owner_update" ON public.health_observations
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "health_observations_owner_delete" ON public.health_observations
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 5. FOOD LOGS (CONFIRMED)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.food_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  logged_at timestamptz NOT NULL,
  meal_slot text NOT NULL, -- 'breakfast', 'lunch', 'evening_snack', 'dinner'
  food_name text NOT NULL,
  portion_quantity numeric(8, 2) NOT NULL,
  portion_unit text NOT NULL, -- 'katori', 'roti', 'grams', 'cup'
  calories numeric(8, 2),
  protein_grams numeric(8, 2),
  carbs_grams numeric(8, 2),
  fat_grams numeric(8, 2),
  metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

ALTER TABLE public.food_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "food_logs_owner_select" ON public.food_logs
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "food_logs_owner_insert" ON public.food_logs
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "food_logs_owner_update" ON public.food_logs
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "food_logs_owner_delete" ON public.food_logs
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 6. WORKOUTS (CONFIRMED)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.workouts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title text NOT NULL,
  started_at timestamptz NOT NULL,
  ended_at timestamptz,
  calories_burned numeric(8, 2),
  source text DEFAULT 'manual' NOT NULL,
  metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

ALTER TABLE public.workouts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "workouts_owner_select" ON public.workouts
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "workouts_owner_insert" ON public.workouts
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "workouts_owner_update" ON public.workouts
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "workouts_owner_delete" ON public.workouts
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 7. SLEEP / RECOVERY DATA (CONFIRMED)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.sleep_recovery_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  sleep_date date NOT NULL,
  duration_minutes integer NOT NULL,
  sleep_score integer,
  recovery_score integer,
  source text DEFAULT 'manual' NOT NULL,
  metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

ALTER TABLE public.sleep_recovery_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "sleep_recovery_logs_owner_select" ON public.sleep_recovery_logs
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "sleep_recovery_logs_owner_insert" ON public.sleep_recovery_logs
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "sleep_recovery_logs_owner_update" ON public.sleep_recovery_logs
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "sleep_recovery_logs_owner_delete" ON public.sleep_recovery_logs
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 8. HABITS (CONFIRMED)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.habits (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title text NOT NULL,
  frequency text DEFAULT 'daily' NOT NULL,
  target_value numeric(8, 2),
  target_unit text,
  is_active boolean DEFAULT true NOT NULL,
  metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

ALTER TABLE public.habits ENABLE ROW LEVEL SECURITY;

CREATE POLICY "habits_owner_select" ON public.habits
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "habits_owner_insert" ON public.habits
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "habits_owner_update" ON public.habits
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "habits_owner_delete" ON public.habits
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 9. MEDICATIONS (CONFIRMED)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.medications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name text NOT NULL,
  dosage text NOT NULL,
  frequency text NOT NULL,
  instructions text,
  is_active boolean DEFAULT true NOT NULL,
  metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

ALTER TABLE public.medications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "medications_owner_select" ON public.medications
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "medications_owner_insert" ON public.medications
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "medications_owner_update" ON public.medications
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "medications_owner_delete" ON public.medications
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 10. FAMILY HEALTH RELATIONSHIPS (CONFIRMED)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.family_health_relationships (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  related_user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  relationship_type text NOT NULL, -- 'parent', 'spouse', 'child', 'sibling'
  consent_status text DEFAULT 'pending' NOT NULL, -- 'pending', 'active', 'revoked'
  consented_at timestamptz,
  revoked_at timestamptz,
  metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

ALTER TABLE public.family_health_relationships ENABLE ROW LEVEL SECURITY;

CREATE POLICY "family_relationships_owner_select" ON public.family_health_relationships
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id OR auth.uid() = related_user_id);

CREATE POLICY "family_relationships_owner_insert" ON public.family_health_relationships
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "family_relationships_owner_update" ON public.family_health_relationships
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id OR auth.uid() = related_user_id)
  WITH CHECK (auth.uid() = user_id OR auth.uid() = related_user_id);

CREATE POLICY "family_relationships_owner_delete" ON public.family_health_relationships
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 11. ENTITLEMENTS (CONFIRMED)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.entitlements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  plan_code text NOT NULL, -- 'free', 'karma_pro_monthly', 'karma_pro_annual'
  status text DEFAULT 'active' NOT NULL, -- 'active', 'grace_period', 'expired', 'canceled'
  starts_at timestamptz NOT NULL,
  expires_at timestamptz,
  metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

ALTER TABLE public.entitlements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "entitlements_owner_select" ON public.entitlements
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

-- Client writes to entitlements are forbidden; entitlements are managed server-side via Edge Functions / Webhooks
CREATE POLICY "entitlements_service_write" ON public.entitlements
  FOR ALL TO service_role
  USING (true)
  WITH CHECK (true);

-- ------------------------------------------------------------------------------
-- 12. PUSH TOKENS (CONFIRMED)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.push_tokens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  token text NOT NULL,
  platform text NOT NULL, -- 'android', 'ios', 'web'
  device_id text,
  is_active boolean DEFAULT true NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL,
  UNIQUE (user_id, token)
);

ALTER TABLE public.push_tokens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "push_tokens_owner_select" ON public.push_tokens
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "push_tokens_owner_insert" ON public.push_tokens
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "push_tokens_owner_update" ON public.push_tokens
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "push_tokens_owner_delete" ON public.push_tokens
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 13. STORAGE ASSETS (CONFIRMED)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.storage_assets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  bucket_id text NOT NULL,
  storage_path text NOT NULL,
  mime_type text,
  file_size_bytes bigint,
  metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL
);

ALTER TABLE public.storage_assets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "storage_assets_owner_select" ON public.storage_assets
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "storage_assets_owner_insert" ON public.storage_assets
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "storage_assets_owner_update" ON public.storage_assets
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "storage_assets_owner_delete" ON public.storage_assets
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 14. AUDIT / DELETION OPERATIONS (CONFIRMED)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.audit_deletion_operations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  operation_type text NOT NULL, -- 'delete_user_data_requested', 'delete_user_data_completed'
  status text DEFAULT 'initiated' NOT NULL, -- 'initiated', 'processing', 'completed', 'failed'
  details jsonb DEFAULT '{}'::jsonb NOT NULL,
  requested_at timestamptz DEFAULT now() NOT NULL,
  completed_at timestamptz
);

ALTER TABLE public.audit_deletion_operations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "audit_deletion_operations_owner_select" ON public.audit_deletion_operations
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "audit_deletion_operations_owner_insert" ON public.audit_deletion_operations
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "audit_deletion_operations_service_manage" ON public.audit_deletion_operations
  FOR ALL TO service_role
  USING (true)
  WITH CHECK (true);

-- ------------------------------------------------------------------------------
-- 15. PRIVATE STORAGE BUCKETS FOR SENSITIVE MEDIA
-- ------------------------------------------------------------------------------
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'storage') THEN
    INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
    VALUES
      ('meal_photos', 'meal_photos', false, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp']),
      ('medical_reports', 'medical_reports', false, 20971520, ARRAY['application/pdf', 'image/jpeg', 'image/png']),
      ('voice_notes', 'voice_notes', false, 15728640, ARRAY['audio/mpeg', 'audio/ogg', 'audio/wav', 'audio/m4a']),
      ('data_exports', 'data_exports', false, 52428800, ARRAY['application/zip', 'application/json'])
    ON CONFLICT (id) DO UPDATE SET
      public = false,
      file_size_limit = EXCLUDED.file_size_limit,
      allowed_mime_types = EXCLUDED.allowed_mime_types;
  END IF;
END $$;

-- ------------------------------------------------------------------------------
-- 16. FOUNDATION FOR THE delete_user_data CASCADE
-- ------------------------------------------------------------------------------
-- Auditable cascading erasure function fulfilling DPDP Section 12 requirements
CREATE OR REPLACE FUNCTION public.delete_user_data(target_user_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  v_caller_id uuid;
  v_op_id uuid;
BEGIN
  v_caller_id := auth.uid();

  -- Authorization guard: caller must be target user or service_role
  IF v_caller_id IS NOT NULL AND v_caller_id <> target_user_id THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Cannot delete data for another user (caller=%, target=%)', v_caller_id, target_user_id;
  END IF;

  -- 1. Insert audit record for the initiation of deletion
  INSERT INTO public.audit_deletion_operations (user_id, operation_type, status, details)
  VALUES (
    target_user_id,
    'delete_user_data_requested',
    'processing',
    jsonb_build_object('initiated_by', coalesce(v_caller_id::text, 'service_role'), 'timestamp', now())
  )
  RETURNING id INTO v_op_id;

  -- 2. Explicit cascade deletions across user-owned tables
  -- Note: Foreign keys ON DELETE CASCADE also automatically clean child rows when auth.users is deleted,
  -- but this explicit procedure ensures immediate auditability and cleans user data within public schema.
  DELETE FROM public.storage_assets WHERE user_id = target_user_id;
  DELETE FROM public.push_tokens WHERE user_id = target_user_id;
  DELETE FROM public.family_health_relationships WHERE user_id = target_user_id OR related_user_id = target_user_id;
  DELETE FROM public.medications WHERE user_id = target_user_id;
  DELETE FROM public.habits WHERE user_id = target_user_id;
  DELETE FROM public.sleep_recovery_logs WHERE user_id = target_user_id;
  DELETE FROM public.workouts WHERE user_id = target_user_id;
  DELETE FROM public.food_logs WHERE user_id = target_user_id;
  DELETE FROM public.health_observations WHERE user_id = target_user_id;
  DELETE FROM public.cooking_multipliers WHERE user_id = target_user_id;
  DELETE FROM public.recipes WHERE user_id = target_user_id;
  DELETE FROM public.food_catalog WHERE user_id = target_user_id;
  DELETE FROM public.entitlements WHERE user_id = target_user_id;
  DELETE FROM public.profiles WHERE user_id = target_user_id;

  -- 3. Mark audit record completed
  UPDATE public.audit_deletion_operations
  SET status = 'completed', completed_at = now()
  WHERE id = v_op_id;

  RETURN jsonb_build_object(
    'status', 'completed',
    'operation_id', v_op_id,
    'user_id', target_user_id,
    'completed_at', now()
  );
END;
$$;
