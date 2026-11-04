# Security Baseline and Release Blockers

This document records security issues and checks identified during static review of the available source snapshots. It is not a penetration-test report. Re-test each item against the exact source revision chosen for migration.

## Known issues to remediate before deployment

- **Plaintext password handling:** the reviewed Spring Boot source stored/compared passwords in plaintext. Replace with a vetted adaptive password hashing library and require password changes if any real credentials were stored this way.
- **Sensitive entity serialization:** reviewed user entity/API paths could expose a password field through entity serialization. Use explicit response DTOs and tests that assert password hashes never appear in responses.
- **Authorization coverage:** endpoint-level authentication and authorization were not sufficiently demonstrated in the reviewed backend. Protect every private endpoint and verify user/resource ownership on the server.
- **Demo/test accounts:** remove demo-user initialization from production profiles and ensure no default credentials are deployed.
- **Admin panel:** the legacy web admin page talks to Firebase and must not be treated as an authorized admin interface for the SQL backend. Rebuild it on protected backend endpoints.
- **Legacy signing key:** a file named `my-release-key.jks` was present in older source archives. Exclude it from the new repository. Treat a previously committed signing key as exposed and assess key rotation/replacement before publishing an Android release. Do not put passwords or replacement keys in Git.
- **Firebase rules:** the older source snapshot did not include the Firestore/Storage rules needed to verify access isolation. Do not rely on undocumented or default rules.
- **Persistence:** an in-memory H2 default is not durable storage. Use configured persistent storage for any shared or production deployment.

## Repository rules

- Commit `.env.example` with dummy placeholders; never commit `.env`.
- Never commit service-account files, OAuth client secrets, tokens, SMTP passwords, database credentials, keystores, private keys, or real user exports.
- Keep uploads private by default and authorize every read/write server-side.
- Do not log passwords, tokens, OTPs, private messages, or sensitive personal data.
- Pin and update dependencies; run vulnerability and secret scanning in CI.
- Use HTTPS outside local development.

## Minimum verification tests

- Passwords are never stored or returned in plaintext.
- Unauthenticated requests to protected endpoints receive an authorization failure.
- A user cannot read or mutate another user's private profile, events or conversations without explicit permission.
- Admin endpoints reject non-admin users even when called directly.
- CSV imports validate each row and cannot bypass server-side authorization or validation.
- Upload access is scoped to authorized users/conversations.
- Error responses do not leak stack traces, secrets, or database details.

## Release decision

Do not label the system production-ready until the blockers above are resolved and tested against the exact release commit.
