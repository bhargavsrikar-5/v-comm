# Project status

Checked 5 November 2026.

## Completed in this migration candidate

- [x] Compare the main Firebase and Spring Boot source generations and document source provenance.
- [x] Establish one repository layout with active Flutter and Spring Boot trees.
- [x] Preserve the Firebase generation as a historical reference without live Firebase platform configuration.
- [x] Add BCrypt credential hashing, JWT bearer authentication and Spring Security authorization.
- [x] Add user response DTOs, faculty/admin roles, environment-based administrator bootstrap and owner checks.
- [x] Add Flyway schema migration and environment-based persistence configuration.
- [x] Add Flutter secure token storage and authenticated API headers.
- [x] Add group text messaging with server-enforced membership and group-admin authorization (source implemented; runtime tests pending).
- [x] Add structured weekly timetable slots while retaining the timetable URL/image reference path (source implemented; runtime tests pending).
- [x] Extend events with descriptions, local start/end times, visibility and reminder metadata; add a foreground in-app reminder prompt (source implemented; background/push reminders are not present).
- [x] Add Present, Absent, Available, Busy and In Class availability labels while retaining legacy boolean compatibility.
- [x] Add account token-version revocation on password change/logout and optional configured email-domain restrictions.
- [x] Add polling refresh for group summaries/history, event/dashboard data and search/profile views where wired.
- [x] Correct the stale undefined variable in `AuthState._persistProfile`.
- [x] Update README, API, architecture, feature and security documentation to reflect the current source.
- [x] Exclude committed signing keys, Firebase client/service config, local environment secrets and generated build folders from this package.

## Still outstanding

- [ ] Install/use Flutter and Maven toolchains; run `flutter pub get`, `flutter analyze`, `flutter test`, `mvn test` and platform builds.
- [ ] Add automated tests for login, token validation, role checks, owner isolation and data serialization.
- [ ] Add group ownership transfer/deletion if the approved requirements need those lifecycle actions; add pagination and concurrency-safe read cursors.
- [ ] Implement media messages and presentation-only rich actions only after separate scope approval.
- [ ] Implement secure media/timetable upload and object storage.
- [ ] Implement notifications and persisted preferences.
- [ ] Build an integrated admin web interface over `/api/admin/**`.
- [ ] Add pagination, rate limiting, refresh-token/session-management design, audit logging and operational monitoring.
- [ ] Upgrade Spring Boot 3.5.16 to a supported 4.x release and verify compatibility.
- [ ] Agree a project licence/redistribution terms with all three contributors.
- [ ] Record a clean Android build and end-to-end device walkthrough.

## Verification status

The implementation checkpoint was reviewed statically. No builds or tests were run for the current uncommitted changes. GitHub Actions results recorded for the previous pushed baseline do not cover this checkpoint. No compile, test, device, deployment or penetration-test success is claimed for the current source.
