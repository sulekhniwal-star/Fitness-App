---
phase: 2
plan: 2
wave: 1
---

# Plan 2.2: Social Feed Preparation

## Objective
Configure the Social Feed interactions while honoring the "server wins" syncing constraint and recognizing the feed operates fundamentally online.

## Context
- .gsd/SPEC.md
- fitkarma/lib/data/providers/community_provider.dart

## Tasks

<task type="auto">
  <name>Establish Posts Collection Operations</name>
  <files>
    - fitkarma/lib/data/providers/community_provider.dart
  </files>
  <action>
    Ensure the `CommunityNotifier` loads recent posts from the PocketBase `posts` collection efficiently. Implement offline caching (via `HiveService.postsBox`) for local viewing, though creates should trigger live uploads.
  </action>
  <verify>Run `flutter analyze` against the community modules.</verify>
  <done>Community provider retrieves and caches network posts efficiently.</done>
</task>

<task type="auto">
  <name>User Engagement & Karma Logic</name>
  <files>
    - fitkarma/lib/data/providers/community_provider.dart
  </files>
  <action>
    Map post interactions (creating a post, liking a post) to the `karmaProvider.earnKarma` method as per the Gamification Phase 2 spec. Ensure server updates handle concurrency.
  </action>
  <verify>Check `karmaProvider` invocation on engagement.</verify>
  <done>Creating a post rewards the user with specified Karma.</done>
</task>

## Success Criteria
- [ ] Social feed fetches from backend and stores redundantly in Hive.
- [ ] Social posts trigger Karma bonuses.
