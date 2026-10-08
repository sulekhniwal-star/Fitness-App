#!/usr/bin/env node

/**
 * FitKarma Database Migration & Workspace Validator
 * Runs in CI and local pre-commit hooks to guarantee migration integrity,
 * strict monotonic ordering, naming conventions, and secret-free schemas.
 */

const fs = require('fs');
const path = require('path');

const ROOT_DIR = path.resolve(__dirname, '..');
const SUPABASE_DIR = path.join(ROOT_DIR, 'supabase');
const MIGRATIONS_DIR = path.join(SUPABASE_DIR, 'migrations');
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

// 2. Verify Migrations Directory
console.log('\n2. Checking Migrations Directory...');
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

    for (const file of migrationFiles) {
      const match = file.match(filenameRegex);
      if (!match) {
        reportFail(`Migration filename '${file}' does not match pattern YYYYMMDDHHMMSS_description.sql`);
        continue;
      }

      const timestamp = match[1];
      const description = match[2];

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
    }
  }
}

// 3. Verify Seed Configuration and Safety Guards
console.log('\n3. Checking Seed Data & Production Guards...');
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
  console.error('\nResult: MIGRATION VALIDATION FAILED!');
  process.exit(1);
} else {
  console.log('\nResult: ALL MIGRATION AND CONFIGURATION CHECKS PASSED.');
  process.exit(0);
}
