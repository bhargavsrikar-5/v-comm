# Changelog

## Unreleased — unified migration candidate

- Consolidated the active Flutter client and Spring Boot REST API into one repository layout.
- Preserved the older Firebase implementation as a read-only feature/provenance reference without live project configuration.
- Added BCrypt credential hashing, JWT bearer authentication, Spring Security authorization, DTO-based user responses, owner checks and an administrator provisioning API.
- Added Flyway-managed relational schema and environment-based configuration.
- Added secure bearer-token persistence in Flutter using platform secure storage.
- Corrected a stale undefined variable in the Flutter secure-session persistence helper.
- Updated API, architecture, feature, security and migration documentation to match the current source.
- Explicitly recorded the remaining group chat, media, notifications, admin UI, tests and framework-upgrade work.
