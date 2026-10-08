# FitKarma pgTAP Test Harness

## Overview
This directory contains pgTAP SQL tests for verifying database schema, Row Level Security (RLS) enforcement, multi-tenant isolation, and default-deny policies.

## Test Suites
- `00000_rls_isolation_test.sql`: Verifies table existence across all 14 confirmed domains, ensures RLS is active on every table, tests anonymous access denial, and proves tenant isolation between User A and User B.

## Execution

### With Local Supabase Stack
```bash
# Run all pgTAP test suites
npx supabase test db

# Run specific test file
npx supabase test db supabase/tests/00000_rls_isolation_test.sql
```

### Static CI Verification
```bash
# Verifies schema integrity, RLS commands, and foreign key cascades
npm run db:lint
```
