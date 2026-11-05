# Changelog

## Unreleased — unified migration candidate

- Consolidated the active Flutter client and Spring Boot REST API into one repository layout.
- Preserved the older Firebase implementation as a read-only feature/provenance reference without live project configuration.
- Added BCrypt credential hashing, JWT bearer authentication, Spring Security authorization, DTO-based user responses, owner checks and an administrator provisioning API.
- Added Flyway-managed relational schema and environment-based configuration.
- Added secure bearer-token persistence in Flutter using platform secure storage.
- Added group text chats with creator-admin membership, server-side membership authorization, read markers and polling refresh.
- Added structured weekly timetable slots while preserving existing HTTPS timetable URL/image viewing.
- Added event descriptions, start/end times, PRIVATE/FACULTY visibility and foreground-only in-app reminder prompts.
- Added the documented availability labels, optional institution-configured email-domain restrictions and database-backed token revocation on password change/logout.
- Required HTTPS API URLs for Flutter release builds; local HTTP remains limited to debug loopback/emulator/private-LAN addresses.
- Corrected a stale undefined variable in the Flutter secure-session persistence helper.
- Updated the API contract, architecture, data model, feature matrix, security review, migration plan and verification notes to reflect this source checkpoint.
- Recorded current code as unbuilt and untested; prior CI results cover only the last pushed baseline. Media messaging, push/background notifications, password recovery and integrated admin UI remain absent.
