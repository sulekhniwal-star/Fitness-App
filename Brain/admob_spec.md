# AdMob Specification

## Role

Ads are a Free-tier monetization mechanism only and must never interfere with critical health functions.

## Placement rules

`PROPOSED` placements:

- non-critical list/detail surfaces
- between non-critical content sections

Do not place ads over:

- emergency/crisis alerts
- health metric warnings
- payment confirmation
- consent/revocation
- data deletion/export
- core logging confirmation

## Frequency

Exact frequency caps are `OPEN DECISION`. Prefer conservative caps to protect trust and retention.

## Premium

Karma Pro and above are ad-free as defined in pricing requirements.

## Privacy/consent

Implement the applicable consent flow before serving personalized ads. Store only the minimum analytics/ad metadata required.

## Rewarded ads

`PROPOSED`: optional rewarded ads for non-health-critical cosmetic or convenience benefits. Never gate a medical/health-safety function behind an ad.
