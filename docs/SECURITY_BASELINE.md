# Security baseline

This is a first-pass static source baseline, not a certification or penetration-test report.

Implemented in the current candidate:

- BCrypt password hashing with cost 12.
- User response DTOs that do not expose credential fields.
- JWT bearer token issuance and verification; protected non-public API routes.
- FACULTY and ADMIN roles; admin route restriction.
- Caller identity derived from the authenticated principal for own-profile, presence, timetable, search history, event and direct-message operations.
- Environment-provided JWT/admin/database settings; H2 console disabled by default.
- Configurable browser-origin allow-list.
- Secret, Firebase service configuration and release keystore exclusions in `.gitignore` and the candidate package.

Still required before production use:

- Automated authentication/authorization/data-isolation tests and penetration testing.
- Rate limiting, token revocation/refresh and security audit events.
- Upgrade to a currently supported Spring Boot release.
- Persistent MySQL configuration, backups, migration rehearsal and deployment secret management.
- Reviewed account provisioning/reset process for existing V2 users; old plaintext passwords must not be copied into the new schema.
- Group-chat membership and admin UI security reviews when those components are implemented.

See [Security Audit](SECURITY_AUDIT.md) for detailed residual risks.
