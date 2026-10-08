#!/usr/bin/env node

/**
 * FitKarma Documentation Lint & Link Checker
 * Implements Microtasks DOC-001 and DOC-002 per Todo TASK 001A.
 */

const fs = require('fs');
const path = require('path');

const ROOT_DIR = path.resolve(__dirname, '..');

let totalChecks = 0;
let errors = [];
let warnings = [];

function check(desc, fn) {
  totalChecks++;
  try {
    const result = fn();
    if (result !== true) {
      errors.push(`${desc}: ${result || 'Failed'}`);
    }
  } catch (err) {
    errors.push(`${desc}: Exception: ${err.message}`);
  }
}

console.log('=== FitKarma Doc-Lint & Link Checker ===\n');

// 1. Required Documents Check
const REQUIRED_FILES = [
  '.agent/skills/SKILL.md',
  'FitKarma_Master_Documentation_v1.md',
  'Todo.md',
  'Brain/master_rules.md',
  'Brain/pdr.md',
  'Brain/trd.md',
  'Brain/architecture.md',
  'Brain/data_model.md',
  'Brain/api_contract.md',
  'Brain/data_sources.md',
  'Brain/ui_spec.md',
  'Brain/security.md',
  'Brain/error_handling.md',
  'Brain/testing.md',
  'Brain/production_checklist.md',
  'Brain/github_actions.md',
  'Brain/admob_spec.md',
  'Brain/scrapping_spec.md',
  'Brain/decisions.md',
  'Brain/changelog.md',
  'Brain/microtasks.md',
  'Brain/implementation_audit.md',
];

REQUIRED_FILES.forEach(relPath => {
  check(`File exists: ${relPath}`, () => {
    const fullPath = path.join(ROOT_DIR, relPath);
    if (!fs.existsSync(fullPath)) return `File missing at ${relPath}`;
    const stats = fs.statSync(fullPath);
    if (stats.size === 0) return `File is empty at ${relPath}`;
    return true;
  });
});

// 2. Stale /docs path lint
const BRAIN_FILES = fs.readdirSync(path.join(ROOT_DIR, 'Brain'))
  .filter(f => f.endsWith('.md'))
  .map(f => path.join('Brain', f));

BRAIN_FILES.forEach(relPath => {
  check(`No stale /docs path in ${relPath}`, () => {
    const content = fs.readFileSync(path.join(ROOT_DIR, relPath), 'utf8');
    const staleDocsMatch = content.match(/\/docs\b/i);
    if (staleDocsMatch) {
      return `Found stale '/docs' reference in ${relPath}`;
    }
    return true;
  });
});

// 3. RevenueCat isolation lint (Must only appear as historical migration context)
const ALL_DOC_FILES = [
  ...REQUIRED_FILES,
  'FitKarma_Master_Documentation_v1.0.md'
];

ALL_DOC_FILES.forEach(relPath => {
  check(`RevenueCat isolated as historical context in ${relPath}`, () => {
    const fullPath = path.join(ROOT_DIR, relPath);
    if (!fs.existsSync(fullPath)) return true;
    const content = fs.readFileSync(fullPath, 'utf8');
    if (!content.includes('RevenueCat')) return true;

    const allowedFiles = [
      'Brain/decisions.md',
      'Brain/changelog.md',
      'Todo.md',
      'FitKarma_Master_Documentation_v1.md',
      'FitKarma_Master_Documentation_v1.0.md'
    ];
    if (!allowedFiles.includes(relPath)) {
      return `Unexpected RevenueCat reference in ${relPath}`;
    }
    // Check that where it appears, it is marked as historical / removed
    if (!content.toLowerCase().includes('historical') &&
        !content.toLowerCase().includes('migration') &&
        !content.toLowerCase().includes('removed') &&
        !content.toLowerCase().includes('not an active')) {
      return `RevenueCat referenced without historical migration qualifier in ${relPath}`;
    }
    return true;
  });
});

// 4. Baseline claims classified as UNVERIFIED
check('Baseline claims marked UNVERIFIED in Brain/testing.md', () => {
  const content = fs.readFileSync(path.join(ROOT_DIR, 'Brain/testing.md'), 'utf8');
  if (!content.includes('UNVERIFIED')) return 'Missing UNVERIFIED designation in testing.md';
  if (!content.includes('160/160')) return 'Missing 160/160 baseline reference';
  if (!content.includes('delete_user_data')) return 'Missing delete_user_data reference';
  if (!content.includes('pgTAP')) return 'Missing pgTAP reference';
  return true;
});

check('Baseline deletion claim marked UNVERIFIED in Brain/security.md', () => {
  const content = fs.readFileSync(path.join(ROOT_DIR, 'Brain/security.md'), 'utf8');
  if (!content.includes('UNVERIFIED')) return 'Missing UNVERIFIED designation in security.md';
  return true;
});

check('Baseline claims marked UNVERIFIED in Brain/implementation_audit.md', () => {
  const content = fs.readFileSync(path.join(ROOT_DIR, 'Brain/implementation_audit.md'), 'utf8');
  if (!content.includes('UNVERIFIED')) return 'Missing UNVERIFIED designation in implementation_audit.md';
  return true;
});

// 5. Markdown relative link check across all documentation
const MD_FILES = [
  ...REQUIRED_FILES,
  'FitKarma_Master_Documentation_v1.0.md'
];

MD_FILES.forEach(relPath => {
  const fullPath = path.join(ROOT_DIR, relPath);
  if (!fs.existsSync(fullPath)) return;
  const content = fs.readFileSync(fullPath, 'utf8');
  const baseDir = path.dirname(fullPath);

  // Match Markdown links: [text](target)
  const linkRegex = /\[([^\]]+)\]\(([^)]+)\)/g;
  let match;
  while ((match = linkRegex.exec(content)) !== null) {
    const rawTarget = match[2].trim();
    // Ignore external URLs, mailto, anchor-only links
    if (rawTarget.startsWith('http://') ||
        rawTarget.startsWith('https://') ||
        rawTarget.startsWith('mailto:') ||
        rawTarget.startsWith('#') ||
        rawTarget.startsWith('file://')) {
      continue;
    }

    const [targetPath] = rawTarget.split('#');
    if (!targetPath) continue;

    check(`Link in ${relPath} -> ${rawTarget}`, () => {
      let resolved;
      if (targetPath.startsWith('/')) {
        resolved = path.join(ROOT_DIR, targetPath.slice(1));
      } else {
        resolved = path.resolve(baseDir, targetPath);
      }

      if (!fs.existsSync(resolved)) {
        return `Broken link to '${targetPath}' (resolved to ${resolved})`;
      }
      return true;
    });
  }
});

// Summary
console.log(`Ran ${totalChecks} documentation checks.`);
if (warnings.length > 0) {
  console.log(`\nWarnings (${warnings.length}):`);
  warnings.forEach(w => console.log(`  - ${w}`));
}

if (errors.length > 0) {
  console.log(`\nErrors (${errors.length}):`);
  errors.forEach(e => console.log(`  ✖ ${e}`));
  console.log('\nResult: FAILED');
  process.exit(1);
} else {
  console.log('\nResult: ALL CHECKS PASSED (DOC-001, DOC-002 validated)\n');
  process.exit(0);
}
