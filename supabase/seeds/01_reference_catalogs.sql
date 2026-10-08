-- ==============================================================================
-- FitKarma Reference Catalogs Seed (LOCAL & DEV ONLY)
-- Layer: 01_reference_catalogs.sql
-- Description: Baseline reference data constants for Indian nutrition and metrics.
-- Note: Product tables are created in TASK 012B; this file defines standard seed fixtures.
-- ==============================================================================

-- Safety check: Ensure this is NOT executed against production
DO $$
BEGIN
  IF current_database() LIKE '%prod%' THEN
    RAISE EXCEPTION 'CRITICAL: Attempted to run local seed data against a production database!';
  END IF;
END $$;

-- Reference categories and constants will be inserted once schema tables are established in TASK 012B.
-- Catalog fixtures planned:
-- 1. Standard Indian Household Portions (Katori, Roti, Spoon, Cup, Handful)
-- 2. Meal Slots (Breakfast, Morning Snack, Lunch, Evening Snack, Dinner, Post Dinner)
-- 3. Core Nutrient Indicators (Calories, Protein, Carbs, Fat, Fiber)
