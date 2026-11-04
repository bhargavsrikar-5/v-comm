# Unified migration plan

## Guiding decision

Use the newer Flutter + Spring Boot + relational generation as the active application baseline. Use the Firebase generation as a feature and UX reference. Do not copy V1 screens unchanged: Firebase UIDs/Firestore documents and the V2 numeric relational IDs/API contract are different systems.

## Stage 0 — Source recovery and baseline

- [x] Review the five GitHub repositories and source snapshots.
- [x] Inspect the older Firebase source copies and recovered local working copy.
- [x] Inspect the Spring Boot migration source.
- [x] Inspect APK metadata and identify it as a Firebase-era build.
- [x] Review capstone report and feature presentations.
- [x] Create the unified repository layout and retain the legacy source reference without live Firebase configuration.
- [ ] Run clean Flutter and Maven builds in an environment with the required toolchains.

## Stage 1 — Backend security foundation

- [x] Add Spring Security and BCrypt password hashing.
- [x] Remove plaintext password comparisons and seeded demo credentials.
- [x] Add user DTOs and hide the credential hash.
- [x] Implement JWT issuance, verification and authenticated principal.
- [x] Protect non-public endpoints and derive caller identity from the principal.
- [x] Add FACULTY/ADMIN role and administrator faculty-provisioning API.
- [x] Add owner checks for profiles, presence, timetable URL, search history, events and direct messages.
- [x] Restrict CORS by configured allow-list; disable H2 console by default; externalize secrets.
- [ ] Add automated tests for authentication, authorization and data isolation.
- [ ] Add rate limiting, token revocation/refresh and security-event audit trail.

## Stage 2 — Database and domain model

- [x] Define normalized initial MySQL schema and Flyway migration.
- [ ] Add conversation and group membership entities.
- [ ] Add message type, attachment metadata, reply/forward relationships and timestamps.
- [ ] Add per-user message reaction, pin/star and chat archive/delete state.
- [ ] Define event time zone and timetable storage metadata.
- [ ] Add pagination and performance indexes for chat history/conversations.
- [ ] Design a safe account/data migration from the older database; never carry plaintext passwords forward.

## Stage 3 — Flutter integration

- [x] Add secure token storage and bearer authorization headers.
- [x] Implement session restoration and local logout/token-expiry handling.
- [x] Update API calls to use principal-derived identity routes.
- [ ] Standardize API error, loading, empty and offline states.
- [ ] Add API/client integration tests and handle expired/invalid token responses consistently.
- [ ] Add secure timetable/media upload through approved storage.

## Stage 4 — Restore the V1 communication experience

- [ ] Group creation, member management and role checks.
- [ ] Rich text/image/file messages.
- [ ] Reply, forward, reactions, edit and deletion semantics.
- [ ] Pin/star and per-user archive state.
- [ ] Unread counts/read receipts tests and pagination.
- [ ] Real-time delivery (WebSocket/SSE or a documented polling alternative).
- [ ] End-to-end notification flow and persisted user preferences.

## Stage 5 — Administration and quality

- [x] Add protected admin API and environment-based initial admin bootstrap.
- [ ] Build an integrated admin web interface using the protected Spring Boot API.
- [ ] Add unit, repository, API integration and Flutter widget tests.
- [ ] Add CI for Flutter analysis/tests and Maven build/tests.
- [ ] Add observability and privacy-safe logging.
- [ ] Verify Android build, install APK and run a full feature walkthrough.
- [ ] Upgrade from Spring Boot 3.5.x to a supported 4.x release and validate the migration.

## Stage 6 — Portfolio release

- [ ] Confirm all three contributors agree on license and redistribution terms.
- [ ] Review secret scanning, dependency checks and release signing.
- [ ] Create a clear demo video/screenshots from the final build.
- [ ] Update README with only verified feature claims and actual test results.
- [ ] Publish one canonical repository and tag a reviewed release.
