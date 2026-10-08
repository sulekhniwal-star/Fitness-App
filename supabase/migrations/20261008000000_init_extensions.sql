-- ==============================================================================
-- Migration: 20261008000000_init_extensions.sql
-- Description: Greenfield PostgreSQL extension setup and baseline configuration
-- Note: Product tables are intentionally deferred to TASK 012B.
-- ==============================================================================

-- 1. UUID & Cryptography Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";

-- 2. Text Search & Case-Insensitive String Types
CREATE EXTENSION IF NOT EXISTS "citext" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "pg_trgm" WITH SCHEMA "extensions";

-- 3. Verification comment
COMMENT ON EXTENSION "uuid-ossp" IS 'UUID generation functions for distributed identifiers';
COMMENT ON EXTENSION "pgcrypto" IS 'Cryptographic functions for secure tokens and hashes';
COMMENT ON EXTENSION "citext" IS 'Case-insensitive string type for emails and unique identifiers';
COMMENT ON EXTENSION "pg_trgm" IS 'Trigram matching for fuzzy search in Indian food databases and logs';
