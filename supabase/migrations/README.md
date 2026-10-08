# FitKarma Supabase Database Migrations

## 1. Migration Protocol & Naming Convention

All PostgreSQL schema changes across FitKarma environments (local, staging, production) must be tracked as deterministic, versioned migration files in this directory.

### Naming Pattern
```text
<YYYYMMDDHHMMSS>_<snake_case_description>.sql
```

Example:
- `20261008000000_init_extensions.sql`
- `20261008000001_baseline_schema.sql` (TASK 012B)

### Rules & Standards
1. **Never mutate remote schemas directly:** All schema, table, column, index, trigger, and RLS policy modifications must be authored as versioned migration scripts and checked into Git.
2. **Deterministic & Idempotent:** Migrations should use idempotent clauses (`CREATE EXTENSION IF NOT EXISTS`, `CREATE INDEX IF NOT EXISTS`) wherever possible.
3. **Strict Monotonic Sequencing:** Every migration file timestamp must be strictly greater than preceding migrations. Duplicate timestamps or out-of-order timestamps will fail CI validation (`npm run db:lint`).
4. **Universal Default-Deny RLS:** Any migration introducing a table must immediately execute `ALTER TABLE <table_name> ENABLE ROW LEVEL SECURITY;` with explicit policies (enforced in TASK 012B).
5. **No Embedded Secrets:** Migration scripts must never hard-code API tokens, service role keys, or private signing keys.

## 2. Running Migrations Locally

```bash
# Start local Supabase stack (requires Docker)
npm run supabase:start

# Apply pending migrations
npx supabase migration up

# Check status of local migrations
npx supabase migration list

# Reset local database from scratch (runs migrations + seed.sql)
npm run supabase:reset
```

## 3. Validating Migrations in CI

```bash
# Validate naming convention, sequence, syntax, and safety rules
npm run db:lint
```
