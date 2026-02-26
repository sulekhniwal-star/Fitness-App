---
phase: 1
plan: 2
wave: 1
---

# Plan 1.2: Authentication System Configuration

## Objective
Finalize the PocketBase authentication flows, particularly addressing known technical debt with phone OTP verification and resend logic.

## Context
- .gsd/SPEC.md
- fitkarma/lib/presentation/screens/auth/phone_otp_screen.dart
- fitkarma/lib/features/auth/

## Tasks

<task type="auto">
  <name>Implement PocketBase OTP Verification</name>
  <files>
    - fitkarma/lib/presentation/screens/auth/phone_otp_screen.dart
  </files>
  <action>
    Locate the `// TODO: Implement OTP verification with PocketBase` comment on line 47. Implement the verification call using the configured AuthProvider/PocketBase client.
  </action>
  <verify>Run `flutter analyze` to verify the syntax of the new implementation.</verify>
  <done>OTP verification correctly invokes the backend service.</done>
</task>

<task type="auto">
  <name>Implement Resend OTP Logic</name>
  <files>
    - fitkarma/lib/presentation/screens/auth/phone_otp_screen.dart
  </files>
  <action>
    Locate the `// TODO: Implement resend OTP` comment on line 142. Implement the callback to request a new OTP generation from PocketBase.
  </action>
  <verify>Run `flutter analyze`.</verify>
  <done>Resend OTP triggers a valid backend request.</done>
</task>

## Success Criteria
- [ ] OTP verification connects to PocketBase.
- [ ] Users can request a new OTP successfully.
