# FitKarma Documentation Changelog

## 2026-10-08 — Documentation architecture expansion

- Preserved the main master documentation as the high-level source.
- Created dedicated domain specifications under `/docs`.
- Incorporated India-first nutrition, WhatsApp, family health, fasting, AQI, Ayurveda, women's health and DIP strategy from the competitive analysis.
- Moved adaptive TDEE earlier in the strategic roadmap.
- Formalized Razorpay + UPI + UPI AutoPay as the active payment direction.
- Documented the historical migration from RevenueCat to Razorpay in `decisions.md`; RevenueCat is not an active architecture dependency.
- Classified undefined implementation details as `PROPOSED` or `OPEN DECISION`.
- Added testing, security, CI/CD, production and AI-agent rules.

## 2026-10-08 — TASK 001 & TASK 002 Consistency Baseline
- Completed full repository and documentation audit in `Brain/implementation_audit.md`.
- Confirmed zero active RevenueCat dependencies in code or configuration.
- Added ADR-016 defining `F:\Fitness App` as a clean-slate greenfield workspace.
- Added ADR-017 and created filesystem directory junction `docs` -> `Brain` to seamlessly bridge references to `/docs` and `Brain/`.
- Ensured `.agent/skills/SKILLS.md` and `.agent/skills/SKILL.md` are synchronized.
- Recorded open architectural decisions OD-001 through OD-004 in `Brain/decisions.md`.
- Updated `Brain/testing.md` with implementation note explaining historical test metrics vs. new test creation.

