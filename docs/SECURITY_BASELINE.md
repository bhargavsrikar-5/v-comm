# Security baseline

This is a first-pass static source baseline for the merged `main` implementation, not a certification or penetration-test report. GitHub Actions Run #9 passed backend tests, Flutter analysis/tests, Android debug build, and iOS simulator build on the PR #2 head commit included in `main`; those checks do not establish production security.

Implemented in the current candidate:

- BCrypt password hashing with cost 12.
- User response DTOs that do not expose credential fields.
- JWT bearer token issuance and verification; protected non-public API routes.
- FACULTY and ADMIN roles; admin route restriction.
- Caller identity derived from the authenticated principal for own-profile, presence, timetable, search history, event and direct-message operations.
- Configurable `VCOMM_ALLOWED_EMAIL_DOMAINS` allow-list for login, faculty provisioning and bootstrap admin setup; blank configuration permits any email domain and no mailbox verification occurs.
- Database-backed token version checked on authenticated requests; password change and logout increment the version to revoke current account tokens.
- Group reads/messages require group membership; membership management is restricted to the group administrator or platform administrator. Timetable slot writes and event mutations are owner-scoped.
- Flutter release configuration requires an HTTPS API URL. Deployment still needs correct TLS termination and HTTPS server configuration.
- Environment-provided JWT/admin/database settings; H2 console disabled by default.
- Configurable browser-origin allow-list.
- Secret, Firebase service configuration and release keystore exclusions in `.gitignore` and the candidate package.

Still required before production use:

- Broader authentication/authorization/data-isolation coverage and penetration testing; the existing CI suite is not a complete security assessment.
- Rate limiting, refresh-token/session-management design and security audit events.
- Upgrade to a currently supported Spring Boot release.
- Persistent MySQL configuration, backups, migration rehearsal and deployment secret management.
- Reviewed account provisioning/reset process for existing V2 users; old plaintext passwords must not be copied into the new schema.
- Runtime review of current group membership controls, privacy of member profile fields, timetable visibility and event visibility.

See [Security Audit](SECURITY_AUDIT.md) for detailed residual risks.
