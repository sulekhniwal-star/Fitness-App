# Scraping / Responsible Data Collection Specification

## Source hierarchy

Official APIs > licensed datasets > open datasets > permitted scraping.

## Before collecting data

- confirm Terms of Service
- inspect robots.txt where applicable
- document permitted fields/use
- define rate limits/throttling
- store provenance
- deduplicate
- validate quality

## Do not

- bypass access controls
- evade rate limits
- collect data contrary to provider terms
- scrape personal/sensitive user data for convenience

## Nutrition data

Prefer curated/licensed/open datasets. Internal transformations must preserve source attribution and update frequency.

## Refresh policy

Exact schedules are `OPEN DECISION`; define source-specific refresh frequency and rollback procedures.
