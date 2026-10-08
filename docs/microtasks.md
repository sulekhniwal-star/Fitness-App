# FitKarma Microtasks

Every task includes dependencies, acceptance criteria and testing requirements.

| ID | Task | Depends on | Acceptance | Tests |
|---|---|---|---|---|
| DOC-001 | Create documentation structure | — | all docs exist | link/check script |
| DOC-002 | Adopt master rules | DOC-001 | agents can resolve source hierarchy | documentation lint |
| PAY-001 | Inventory historical payment references | DOC-001 | no stale active dependency references | grep audit |
| PAY-002 | Define Razorpay server contract | PAY-001 | provider boundary documented | contract tests |
| PAY-003 | Define UPI payment states | PAY-002 | state machine documented | state tests |
| PAY-004 | Define UPI AutoPay lifecycle | PAY-003 | mandate states covered | webhook tests |
| PAY-005 | Implement webhook idempotency design | PAY-004 | duplicate event safe | replay tests |
| NUT-001 | Define Indian portion model | DOC-001 | household units represented | model tests |
| NUT-002 | Define raw/cooked nutrition model | NUT-001 | cooking state + multipliers represented | nutrition tests |
| NUT-003 | Define Tadka estimation model | NUT-002 | low/medium/high estimate rules | calculation tests |
| NUT-004 | Define Family Recipe Splitter | NUT-002 | percentage allocation works offline | unit/offline tests |
| HEALTH-001 | Health Connect contract | DOC-001 | permissions/sync/source attribution defined | integration tests |
| HEALTH-002 | Apple Health contract | HEALTH-001 | iOS counterpart defined | integration tests |
| AI-001 | WhatsApp text extraction | NUT-001 | structured food candidate output | fixture tests |
| AI-002 | WhatsApp voice pipeline | AI-001 | transcript→food flow works | audio/integration tests |
| AI-003 | AI confirmation UX | AI-001 | uncertain results require confirmation | widget tests |
| AI-004 | Photo recognition P1 contract | AI-003 | privacy/deletion/fallback specified | vision fixture tests |
| TDEE-001 | Define adaptive TDEE algorithm | NUT-002 | formula + adjustment policy approved | math tests |
| FAMILY-001 | Family consent model | DOC-001 | consent/revocation is explicit | authz tests |
