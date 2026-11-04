# Security review and remediation status

This document compares the original Spring Boot V2 source with the current unified candidate. It is a static source review, **not** a penetration test or proof of runtime security.

## Original V2 findings and current status

| Finding in original V2 | Current candidate treatment | Remaining verification / limitation |
|---|---|---|
| Plaintext password storage and comparison | Replaced by BCrypt password hashing (`BCryptPasswordEncoder(12)`) and `password_hash` column | Confirm with DB/API integration tests; old plaintext accounts need reset/re-provisioning |
| Password-bearing User entity serialized from APIs | `UserResponse` DTO is used for user/profile/auth responses; `passwordHash` is `@JsonIgnore` | Add serialization tests to prove the hash never appears in responses |
| No authenticated request identity | JWT issued at login and validated by `JwtAuthenticationFilter`; protected routes require authentication | Add tests for missing, malformed, forged and expired tokens |
| Client-supplied user ID trusted as identity | User-owned profile, status, timetable, search history, events and message sender use authenticated principal / owner checks | Add cross-user authorization integration tests |
| No administrator authorization | `UserRole` and Spring Security `hasRole("ADMIN")`; admin user-provisioning routes | Add tests for faculty denied access and administrator allowed access |
| Wildcard CORS | Central allow-list via `APP_CORS_ALLOWED_ORIGINS` | Set exact web origins for deployment and verify preflight behavior |
| H2 console exposed by default | `spring.h2.console.enabled=false` by default | Never enable on a publicly reachable environment |
| Predictable seeded demo accounts | Removed; optional initial admin is configured via environment variables, with minimum password length and BCrypt hashing | Keep bootstrap values in secret manager; no sample credentials are included |

## Current residual risks and gaps

1. **No token revocation or refresh flow.** Access tokens are stateless and remain valid until expiry (default 12 hours). Password changes do not currently revoke previously issued tokens.
2. **No rate limiting / lockout.** Login, search and message routes need abuse protection at the API or gateway layer.
3. **No security integration tests.** The current environment lacks Maven, Flutter and Dart toolchains, so no backend tests or client analysis have been run here.
4. **New database only.** Flyway migration creates the unified schema. It does not convert old plaintext-password V2 data. Re-provision accounts or reset passwords using a controlled migration plan.
5. **H2 default is ephemeral.** It is for local evaluation only. Use MySQL with secrets supplied through the deployment environment for persistent use.
6. **Admin surface incomplete.** The protected admin API exists, but there is no integrated web UI, audit trail or multi-admin lifecycle workflow.
7. **Messaging incomplete.** Group messaging, membership permissions, attachments, message edit/delete/reactions, pin/star/archive and notification delivery are not implemented in the active API.
8. **Framework support.** Spring Boot 3.5.16 was announced as the last open-source 3.5.x release. Upgrade to a supported 4.x release and validate all dependencies before public deployment.
9. **Legacy Firebase configuration/rules.** Firestore and Storage rules were not supplied in the reviewed snapshots. Do not reuse the historical Firebase project until rules and access controls are independently reviewed.
10. **Signing key exposure in old repos.** A `.jks` release key appeared in older repository snapshots. It is excluded from this candidate and must be treated as exposed if it was used for a real release.

## Release gate

Do not call this production-ready until the team:

- runs backend tests and Flutter analysis/widget tests;
- verifies authorization and data isolation with integration tests;
- migrates to supported framework versions;
- configures persistent MySQL and secrets safely;
- implements the agreed group/media/admin/notification scope;
- completes dependency, secret and signing-key review;
- performs an authorized security review / penetration test;
- records a successful Android build and end-to-end walkthrough.

## External framework reference

Spring Boot 3.5.16 release announcement and end-of-OSS-support note: https://spring.io/blog/2026/06/25/spring-boot-3-5-16-available-now/ . Spring Boot 4.1.0 release: https://spring.io/blog/2026/06/10/spring-boot-4/ .
