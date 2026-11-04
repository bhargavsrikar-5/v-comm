# V-COMM Migration Plan

## Guiding choice

Use the later Flutter + Spring Boot + SQL code line as the technical base. Use the earlier Flutter + Firebase line, capstone report, feature overview and APK as references for intended behavior and missing capabilities. The two generations have different identity and data models, so feature recovery must happen through the new backend contracts rather than by mixing Firebase services into the SQL-backed app.

## Phase 0 — Preserve and inventory

- Keep all original repositories and ZIP snapshots unchanged.
- Record each chosen source repository URL, branch, commit SHA, and date in `docs/SOURCE_PROVENANCE.md` before copying code.
- Compare the candidate source trees and identify generated files, secrets, signing material, and duplicate implementations.
- Confirm with all three contributors that the selected source and assets may be consolidated into the new canonical repository.

**Exit gate:** source provenance and team ownership/permission are documented; no credentials or private user data are included.

## Phase 1 — Repository foundation

- Add the reviewed application source under `mobile/` and `backend/`.
- Add a project-specific `.gitignore` and configuration examples containing placeholders only.
- Document exact local setup and supported development commands.
- Add a minimal CI workflow after the real build commands are known.

**Exit gate:** clean clone contains only intended source/documentation and has reproducible build instructions.

## Phase 2 — Backend security and persistence

- Replace plaintext password storage/comparison with a vetted adaptive password hash (for example, Argon2id or BCrypt through a maintained library).
- Never return password hashes or authentication internals in API responses.
- Implement authentication and authorization checks on every protected endpoint.
- Enforce ownership/role checks for profile, presence, events, conversations and admin operations.
- Validate request bodies and return safe, consistent error responses.
- Configure persistent MySQL for non-test environments; isolate H2 to tests/local profiles.
- Add schema migrations and tests for authorization boundaries.

**Exit gate:** automated tests demonstrate unauthenticated access is rejected and users cannot access or modify another user's protected data.

## Phase 3 — Mobile integration

- Configure API base URL outside source code.
- Replace any direct legacy Firebase data dependencies for migrated features with typed API clients.
- Add loading, empty, validation and failure states.
- Test login/session expiry and all key flows against a local backend.

**Exit gate:** mobile app can complete documented core flows against the SQL-backed API.

## Phase 4 — Admin migration

- Rebuild the legacy Firebase-connected admin page around authenticated backend endpoints.
- Add server-side admin role enforcement; hiding UI controls is not authorization.
- Add audit records for sensitive administrative actions.
- Validate manual and CSV-based account workflows, including row-level validation and safe error reporting.

**Exit gate:** admin functions work exclusively through authorized backend APIs; no Firebase write path remains for migrated data.

## Phase 5 — Feature recovery

Prioritize features in this order, subject to team confirmation and test coverage:

1. Faculty directory/search and profile/presence.
2. Events/calendar CRUD.
3. Timetable viewing.
4. Direct messaging.
5. Group conversations and membership/roles.
6. Message actions such as reply, forward, edit, delete, reactions, pin/star and archive.
7. Push notifications and media attachments, only after storage, privacy and access controls are designed.

**Exit gate:** each feature has an agreed acceptance checklist and automated or documented manual test evidence.

## Phase 6 — Release readiness

- Run backend unit/integration tests and Flutter analysis/tests.
- Perform dependency and secret scans.
- Test a clean setup from the README.
- Review privacy, data retention, backup/restore, logging and deployment configuration.
- Add screenshots and a demo only after they reflect the current code.
- Confirm team authorship and add a license only after permission is settled.

**Exit gate:** a fresh clone can be built and the documented core workflows can be demonstrated without relying on private developer machines or credentials.

## Not in scope for this initial scaffold

This scaffold does not implement code migration, database schema, authentication, chat transport, deployment, CI, push notifications, or a production admin portal.
