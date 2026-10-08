#!/usr/bin/env node

/**
 * FitKarma Database Migration & Workspace Validator
 * Runs in CI and local pre-commit hooks to guarantee migration integrity,
 * strict monotonic ordering, naming conventions, secret-free schemas,
 * universal Row Level Security (RLS), and pgTAP test coverage.
 */

const fs = require('fs');
const path = require('path');

const ROOT_DIR = path.resolve(__dirname, '..');
const SUPABASE_DIR = path.join(ROOT_DIR, 'supabase');
const MIGRATIONS_DIR = path.join(SUPABASE_DIR, 'migrations');
const TESTS_DIR = path.join(SUPABASE_DIR, 'tests');
const CONFIG_FILE = path.join(SUPABASE_DIR, 'config.toml');
const SEED_FILE = path.join(SUPABASE_DIR, 'seed.sql');

const FORBIDDEN_SECRET_PATTERNS = [
  /eyJh[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}/, // JWT tokens
  /rzp_(?:test|live)_[A-Za-z0-9]{14,}/,                              // Razorpay keys
  /gsk_[A-Za-z0-9]{20,}/,                                           // Groq API keys
  /-----BEGIN (?:RSA |EC )?PRIVATE KEY-----/,                       // Private keys
  /service_role_key\s*=\s*['"][^'"]+['"]/i                          // Explicit service role assignments
];

let errorsFound = 0;
let checksPassed = 0;

function reportPass(message) {
  checksPassed++;
  console.log(`  [PASS] ${message}`);
}

function reportFail(message) {
  errorsFound++;
  console.error(`  [FAIL] ${message}`);
}

console.log('=== FitKarma Database Migration & Backend Validator ===\n');

// 1. Verify Supabase config.toml
console.log('1. Checking Supabase configuration...');
if (!fs.existsSync(CONFIG_FILE)) {
  reportFail('supabase/config.toml is missing');
} else {
  const configContent = fs.readFileSync(CONFIG_FILE, 'utf8');
  if (configContent.includes('project_id = "fitkarma"')) {
    reportPass('config.toml exists with project_id = "fitkarma"');
  } else {
    reportFail('config.toml must specify project_id = "fitkarma"');
  }
}

// 2. Verify Migrations Directory & Sequencing
console.log('\n2. Checking Migrations Directory & Sequencing...');
if (!fs.existsSync(MIGRATIONS_DIR)) {
  reportFail('supabase/migrations directory is missing');
} else {
  reportPass('supabase/migrations directory exists');

  const migrationFiles = fs.readdirSync(MIGRATIONS_DIR)
    .filter(file => file.endsWith('.sql'));

  if (migrationFiles.length === 0) {
    reportFail('No migration files found in supabase/migrations');
  } else {
    reportPass(`Found ${migrationFiles.length} migration file(s)`);

    const filenameRegex = /^(\d{14})_([a-z0-9_]+)\.sql$/;
    let previousTimestamp = '';
    const seenTimestamps = new Set();
    const createdTables = new Set();
    const rlsEnabledTables = new Set();
    let hasCascadeFunction = false;
    let hasPrivateBuckets = false;

    for (const file of migrationFiles) {
      const match = file.match(filenameRegex);
      if (!match) {
        reportFail(`Migration filename '${file}' does not match pattern YYYYMMDDHHMMSS_description.sql`);
        continue;
      }

      const timestamp = match[1];
      if (seenTimestamps.has(timestamp)) {
        reportFail(`Duplicate migration timestamp detected: ${timestamp} in '${file}'`);
      }
      seenTimestamps.add(timestamp);

      if (previousTimestamp && timestamp <= previousTimestamp) {
        reportFail(`Migration out of order: '${file}' timestamp (${timestamp}) is not greater than preceding timestamp (${previousTimestamp})`);
      }
      previousTimestamp = timestamp;

      // Check file content
      const filePath = path.join(MIGRATIONS_DIR, file);
      const content = fs.readFileSync(filePath, 'utf8');

      if (content.trim().length === 0) {
        reportFail(`Migration '${file}' is empty`);
      } else {
        reportPass(`Migration '${file}' is valid non-empty SQL`);
      }

      // Check for accidental committed secrets
      for (const pattern of FORBIDDEN_SECRET_PATTERNS) {
        if (pattern.test(content)) {
          reportFail(`Potential secret or credential pattern detected in '${file}'`);
        }
      }

      // Scan for table creation and RLS
      const tableMatches = content.matchAll(/CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?public\.([a-z0-9_]+)/gi);
      for (const tableMatch of tableMatches) {
        createdTables.add(tableMatch[1]);
      }

      const rlsMatches = content.matchAll(/ALTER\s+TABLE\s+public\.([a-z0-9_]+)\s+ENABLE\s+ROW\s+LEVEL\s+SECURITY/gi);
      for (const rlsMatch of rlsMatches) {
        rlsEnabledTables.add(rlsMatch[1]);
      }

      if (content.includes('FUNCTION public.delete_user_data') && content.includes('SECURITY DEFINER')) {
        hasCascadeFunction = true;
      }

      if (content.includes('storage.buckets') && content.includes('false')) {
        hasPrivateBuckets = true;
      }
    }

    // 3. Verify Universal RLS on all created tables
    console.log('\n3. Verifying Universal Row Level Security (RLS)...');
    if (createdTables.size > 0) {
      reportPass(`Detected ${createdTables.size} public table(s): ${[...createdTables].join(', ')}`);
      for (const table of createdTables) {
        if (rlsEnabledTables.has(table)) {
          reportPass(`Table 'public.${table}' has Row Level Security ENABLED`);
        } else {
          reportFail(`Table 'public.${table}' is MISSING 'ENABLE ROW LEVEL SECURITY'`);
        }
      }
    } else {
      reportPass('No public tables defined yet');
    }

    // 4. Verify Cascade Deletion Foundation
    console.log('\n4. Verifying Cascade Erasure & Storage Buckets...');
    if (hasCascadeFunction) {
      reportPass('Function public.delete_user_data(uuid) defined with SECURITY DEFINER');
    } else {
      reportFail('Missing function public.delete_user_data(uuid)');
    }

    if (hasPrivateBuckets) {
      reportPass('Private storage buckets (public = false) configured for sensitive media');
    } else {
      reportFail('Private storage buckets not configured');
    }
  }
}

// 5. Verify pgTAP Test Suite
console.log('\n5. Checking pgTAP Test Harness...');
if (!fs.existsSync(TESTS_DIR)) {
  reportFail('supabase/tests directory is missing');
} else {
  const testFiles = fs.readdirSync(TESTS_DIR).filter(file => file.endsWith('.sql'));
  if (testFiles.length === 0) {
    reportFail('No test files found in supabase/tests');
  } else {
    reportPass(`Found ${testFiles.length} pgTAP test file(s) in supabase/tests`);
    for (const testFile of testFiles) {
      const testContent = fs.readFileSync(path.join(TESTS_DIR, testFile), 'utf8');
      if (testContent.includes('pgtap') && testContent.includes('plan(')) {
        reportPass(`pgTAP harness valid in '${testFile}'`);
      } else {
        reportFail(`File '${testFile}' does not contain valid pgTAP test harness assertions`);
      }
    }
  }
}

// 6. Verify Seed Configuration and Safety Guards
console.log('\n6. Checking Seed Data & Production Guards...');
if (!fs.existsSync(SEED_FILE)) {
  reportFail('supabase/seed.sql is missing');
} else {
  const seedContent = fs.readFileSync(SEED_FILE, 'utf8');
  if (seedContent.includes('prod') && seedContent.includes('RAISE EXCEPTION')) {
    reportPass('supabase/seed.sql contains explicit production database safety guards');
  } else {
    reportFail('supabase/seed.sql must contain safety guards rejecting execution against production databases');
  }

  for (const pattern of FORBIDDEN_SECRET_PATTERNS) {
    if (pattern.test(seedContent)) {
      reportFail('Potential secret pattern detected in supabase/seed.sql');
    }
  }
}

// Summary
console.log('\n-------------------------------------------------------');
console.log(`Validation complete: ${checksPassed} checks passed, ${errorsFound} errors found.`);

if (errorsFound > 0) {
  console.error('\nResult: MIGRATION & RLS VALIDATION FAILED!');
  process.exit(1);
} else {
  console.log('\nResult: ALL MIGRATION, RLS, AND BACKEND CHECKS PASSED.');
  process.exit(0);
}
