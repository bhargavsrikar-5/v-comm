# Project status

Checked 4 November 2026.

## Completed in this migration candidate

- [x] Compare the main Firebase and Spring Boot source generations and document source provenance.
- [x] Establish one repository layout with active Flutter and Spring Boot trees.
- [x] Preserve the Firebase generation as a historical reference without live Firebase platform configuration.
- [x] Add BCrypt credential hashing, JWT bearer authentication and Spring Security authorization.
- [x] Add user response DTOs, faculty/admin roles, environment-based administrator bootstrap and owner checks.
- [x] Add Flyway schema migration and environment-based persistence configuration.
- [x] Add Flutter secure token storage and authenticated API headers.
- [x] Correct the stale undefined variable in `AuthState._persistProfile`.
- [x] Update README, API, architecture, feature and security documentation to reflect the current source.
- [x] Exclude committed signing keys, Firebase client/service config, local environment secrets and generated build folders from this package.

## Still outstanding

- [ ] Install/use Flutter and Maven toolchains; run `flutter pub get`, `flutter analyze`, `flutter test`, `mvn test` and platform builds.
- [ ] Add automated tests for login, token validation, role checks, owner isolation and data serialization.
- [ ] Implement group conversations, group membership and rich messaging actions.
- [ ] Implement secure media/timetable upload and object storage.
- [ ] Implement notifications and persisted preferences.
- [ ] Build an integrated admin web interface over `/api/admin/**`.
- [ ] Add pagination, rate limiting, token revocation/refresh, audit logging and operational monitoring.
- [ ] Upgrade Spring Boot 3.5.16 to a supported 4.x release and verify compatibility.
- [ ] Agree a project licence/redistribution terms with all three contributors.
- [ ] Record a clean Android build and end-to-end device walkthrough.

## Verification status

Only source review and structural parsing of XML/POM, plist, JSON and YAML files have been completed here. Maven, Flutter and Dart are not installed in the preparation environment. No compile, test, device, deployment or penetration-test success is claimed.
