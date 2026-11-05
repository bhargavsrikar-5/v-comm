# Security review and remediation status

This document compares the original Spring Boot V2 source with the current unified candidate. It is a static source review, **not** a penetration test or proof of runtime security.

## Original V2 findings and current status

| Finding in original V2 | Current candidate treatment | Remaining verification / limitation |
|---|---|---|
| Plaintext password storage and comparison | Replaced by BCrypt password hashing (`BCryptPasswordEncoder(12)`) and `password_hash` column | Confirm with DB/API integration tests; old plaintext accounts need reset/re-provisioning |
| Password-bearing User entity serialized from APIs | `UserResponse` DTO is used for user/profile/auth responses; `passwordHash` is `@JsonIgnore` | Add serialization tests to prove the hash never appears in responses |
| No authenticated request identity | JWT issued at login and validated by `JwtAuthenticationFilter`; token version and current role are checked against the account for each request | Historical CI tested the prior pushed baseline; current modified filter requires fresh tests |
| Client-supplied user ID trusted as identity | User-owned profile/status/timetable/search/events and message sender derive identity or enforce ownership; group messages require membership | Current added group/timetable authorization has not been covered by tests |
| No administrator authorization | `UserRole` and Spring Security `hasRole("ADMIN")`; admin provisioning and platform-admin group membership controls | Historical role tests do not verify the new group routes |
| Wildcard CORS | Central allow-list via `APP_CORS_ALLOWED_ORIGINS` | Set exact web origins for deployment and verify preflight behavior |
| H2 console exposed by default | `spring.h2.console.enabled=false` by default | Never enable on a publicly reachable environment |
| Predictable seeded demo accounts | Removed; optional initial admin is configured via environment variables, with minimum password length and BCrypt hashing | Keep bootstrap values in secret manager; no sample credentials are included |

## Current residual risks and gaps

1. **Token revocation uses an account-wide database version.** Password change and logout invalidate all existing tokens for that account at the next request. Each authenticated call now performs a user lookup; no refresh-token flow or per-device session management exists.
2. **No rate limiting / lockout.** Login, search and message routes need abuse protection at the API or gateway layer.
3. **Automated coverage is still limited.** Historical CI covered the previously pushed source only. New group membership/role enforcement, timetable ownership/overlap checks, event visibility/reminders, domain policy and token-version invalidation require tests. No tests or builds were run for the current uncommitted changes.
4. **New database only.** Flyway migration creates the unified schema. It does not convert old plaintext-password V2 data. Re-provision accounts or reset passwords using a controlled migration plan.
5. **H2 default is ephemeral.** It is for local evaluation only. Use MySQL with secrets supplied through the deployment environment for persistent use.
6. **Admin surface incomplete.** The protected admin API exists, but there is no integrated web UI, audit trail or multi-admin lifecycle workflow.
7. **Messaging is text-only.** Direct and group messaging with membership authorization and polling are present in source, but the current changes are untested. Attachments, message edit/delete/reactions, pin/star/archive, pagination and push delivery remain absent.
8. **Institutional domain checks are configuration-only.** `VCOMM_ALLOWED_EMAIL_DOMAINS` is not set by default; production operators must set approved domains. It restricts domains but does not verify mailbox ownership or support password recovery.
9. **HTTPS is an operational requirement.** Release Flutter configuration enforces an HTTPS API URL. The backend must be deployed behind correctly configured TLS; end-to-end encryption is not implemented or claimed.
10. **Framework support.** Spring Boot 3.5.16 was announced as the last open-source 3.5.x release. Upgrade to a supported 4.x release and validate all dependencies before public deployment.
11. **Legacy Firebase configuration/rules.** Firestore and Storage rules were not supplied in the reviewed snapshots. Do not reuse the historical Firebase project until rules and access controls are independently reviewed.
12. **Signing key exposure in old repos.** A `.jks` release key appeared in older repository snapshots. It is excluded from this candidate and must be treated as exposed if it was used for a real release.

## Release gate

Do not call this production-ready until the team:

- runs backend tests and Flutter analysis/widget tests against the completed implementation;
- verifies authorization and data isolation with integration tests;
- migrates to supported framework versions;
- configures persistent MySQL and secrets safely;
- verifies group ownership/privacy controls and decides separately whether media/admin/notification presentation claims are in scope;
- completes dependency, secret and signing-key review;
- performs an authorized security review / penetration test;
- records a successful Android build and end-to-end walkthrough.

## External framework reference

Spring Boot 3.5.16 release announcement and end-of-OSS-support note: https://spring.io/blog/2026/06/25/spring-boot-3-5-16-available-now/ . Spring Boot 4.1.0 release: https://spring.io/blog/2026/06/10/spring-boot-4/ .
