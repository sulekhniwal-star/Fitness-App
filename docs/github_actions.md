# GitHub Actions CI/CD Specification

## Required checks

1. Formatting
2. Dart/Flutter analysis
3. Unit tests
4. Widget tests
5. Integration tests where configured
6. Supabase/Postgres RLS tests
7. Dependency/security checks
8. Secret scanning
9. Android build
10. iOS build on macOS runner
11. Signed release build in protected workflow

## Rules

- Secrets must come only from GitHub Actions secrets/environments or approved secret managers.
- Pull requests should block on failing formatting, analysis, tests or security scans.
- Release workflows require protected branches/environments and human approval where appropriate.

## Suggested workflow stages

```text
checkout
→ dependency cache
→ format check
→ static analysis
→ unit/widget tests
→ backend/RLS tests
→ security scans
→ build artifacts
→ release/sign/publish
```

Exact action versions and signing mechanism are `OPEN DECISION` and should be pinned before production.
