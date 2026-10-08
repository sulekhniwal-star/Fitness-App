# FitKarma Greenfield Repository Audit

> Generated as part of **TASK 001** (Phase 0: Repository Initialization & Engineering Foundation).  
> Date: 2026-10-08  
> Authoritative sources: `FitKarma_Master_Documentation_v1.md`, `.agent/skills/SKILL.md`, `Brain/master_rules.md`, `Brain/trd.md`, `Brain/architecture.md`, `Brain/decisions.md`.

---

## 1. Executive Summary

This repository is currently in a **pure greenfield state**. There is **no existing application code, database schema, migration file, backend function, or test suite**. Only the architecture documentation, agent instructions, and implementation roadmap exist.

All past historical metrics cited in source documents (such as "160/160 tests passing", "zero analyzer issues", "28-table `delete_user_data` cascade", and "pgTAP-validated RLS") are classified as **UNVERIFIED** until implemented and verified directly within this repository.

---

## 2. Inventory of Existing Assets

| Category | Path / File | Status | Notes |
|---|---|---|---|
| **Root Docs** | `FitKarma_Master_Documentation_v1.md` | Present | High-level master specification (v1.0 baseline) |
| **Root Docs** | `FitKarma_Master_Documentation_v1.0.md` | Present | Source release file |
| **Roadmap** | `Todo.md` | Present | Greenfield implementation plan v1.1 (146 tasks) |
| **Agent Skill** | `.agent/skills/SKILL.md` | Present | High-level engineering guidelines and conventions |
| **Agent Skill** | `.agent/skills/SKILLS.md` | Present | Alias to `SKILL.md` |
| **Domain Specs** | `Brain/` (18 markdown files) | Present | Complete specification set (`master_rules`, `pdr`, `trd`, `architecture`, `decisions`, `data_model`, `api_contract`, `data_sources`, `ui_spec`, `security`, `error_handling`, `testing`, `production_checklist`, `github_actions`, `admob_spec`, `scrapping_spec`, `changelog`, `microtasks`) |
| **Version Control** | `.git/` | Present | Clean working tree on branch `main` |

---

## 3. Inventory of Missing Components

| Component | Expected Path / Location | Impact |
|---|---|---|
| **Flutter Project Shell** | `pubspec.yaml`, `lib/`, `test/` | Complete absence of client application code |
| **Platform Target Folders** | `android/`, `ios/` | Mobile runner containers not yet scaffolded |
| **Local Persistence** | Drift schemas, SQLCipher configurations | Database layer not yet initialized |
| **Backend Workspace** | `supabase/` (config, migrations, functions) | Supabase project, RLS policies, and Edge Functions not scaffolded |
| **Environment & Secrets** | `.env.example`, `.gitignore` environment rules | Environment configuration boundary missing |
| **Continuous Integration** | `.github/workflows/` | GitHub Actions pipeline not yet configured |
| **Test Suites** | Unit, widget, integration, security tests | No automated test coverage exists yet |

---

## 4. Environment & Toolchain Inspection

The local development environment on the Windows host was audited on 2026-10-08:

| Tool | Detected Version | Details & Constraints |
|---|---|---|
| **OS** | Windows 11 (build 26340.9596) | Host operating system (locale: `en-IN`) |
| **Flutter SDK** | **3.47.6** (channel stable) | Revision `5fc346839b`, Engine `b8c8d3d8d5` |
| **Dart SDK** | **3.13.5** | DevTools `2.60.0` |
| **Android SDK** | **37.0.0** (platform android-37.0) | Build-tools `37.0.0`, SDK at `C:\Users\JSK\AppData\Local\Android\sdk` |
| **Android JDK** | OpenJDK Runtime 25.0.3 | Bundled with Android Studio (`jbr\bin\java`) |
| **Android Licenses** | All accepted | Android toolchain ready for compilation |
| **iOS Toolchain** | Not available on Windows | iOS builds require a macOS runner via GitHub Actions (per `Brain/github_actions.md`) |
| **Node.js** | **v24.18.0** | Available in system PATH |
| **npm** | **11.16.0** | Available in system PATH |
| **Supabase CLI** | Not detected in system PATH | Required for local backend stack (Task 012A) |
| **Deno** | Not detected in system PATH | Required for local Supabase Edge Functions development (Task 012C) |
| **Visual Studio** | Build Tools 2026 (incomplete) | Only affects Windows desktop C++ target; mobile targets unaffected |

---

## 5. Immediate Blockers & Risks

1. **Supabase CLI / Deno Absence**: Supabase CLI is not installed in the Windows system PATH. This is not a blocker for client initialization (Tasks 002–011), but will need to be resolved prior to Phase 1 backend tasks (`012A–012C`).
2. **iOS Local Build Constraint**: As standard on Windows machines, iOS compilation must be executed via remote CI (macOS runner) rather than locally.
3. **Unverified Documentation Claims**: All historical claims in documentation regarding test counts, code coverage, and database functions are strictly treated as UNVERIFIED until implemented and executed.

---

## 6. Recommended Bootstrap Sequence

Following the ordering notes in `Todo.md`:

1. **TASK 001A**: Documentation Wiring and Doc-Lint Gate — Verify doc paths, add doc link-checking script, record unverified baseline claims.
2. **TASK 002**: Bootstrap Flutter Application — Create clean Flutter project with package ID `com.sulekhniwal.fitkarma`, Android and iOS targets, minimal smoke test.
3. **TASK 003**: Establish Git Ignore, Environment, and Secret Boundaries — Configure `.gitignore`, `.env.example`, and client/server secret separation.
4. **TASK 004**: Establish Project Folder Architecture — Implement modular directory layout adhering to `Brain/architecture.md`.
5. **TASK 005**: Riverpod Application Architecture — Set up root DI providers and overrides.
6. **TASK 006**: Navigation & Route Architecture — Establish auth-guarded routing skeleton.
7. **TASK 007**: Error & Result Primitives — Establish `FK-xxxx` error taxonomy and safe Result envelopes.
8. **TASK 008**: Logging & Observability — Scaffold PII-safe logging and Sentry boundary.
9. **TASK 008A**: Remote Config & Feature Flags — Backend-configurable flags with safe offline fallbacks.
