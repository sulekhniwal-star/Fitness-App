# FitKarma Data Sources & Provenance

## Source policy

Preferred order:

**Official APIs → licensed datasets → open datasets → permitted scraping**

Every imported record should retain provenance metadata where practical.

| Source | Purpose | Status | Auth/Cost/limits | Fallback |
|---|---|---|---|---|
| Internal Indian food DB | nutrition, recipes, portions | Confirmed | internal | curated seed data |
| Open Food Facts | supplementary food data | Candidate | verify current API terms/limits before use | internal DB |
| Google Health Connect | Android health observations | P0 | OS permissions | manual logging |
| Apple Health/HealthKit | iOS health observations | P0 | OS permissions | manual logging |
| CGM provider integrations | glucose telemetry | P2 | provider-specific | no CGM feature |
| AQI provider | workout context | Optional | API-specific | no AQI recommendation |
| WhatsApp Business Cloud API | text/voice interface | P0/P1 | Meta credentials/limits | in-app logging |
| Razorpay | payment processing | Confirmed | server credentials/limits | supported alternative payment flow only if later approved |
| Groq | AI routing | Confirmed | server credentials/limits | deterministic/manual fallback |

Exact provider pricing, quotas, API versions and legal terms must be rechecked before implementation and launch; they are not frozen here.

## Caching

Cache only data that is allowed by provider terms. User health data may be locally cached under the product’s encryption model.

## Privacy

Do not transmit more health data to a third party than necessary for the requested feature. Define retention per integration before launch.
