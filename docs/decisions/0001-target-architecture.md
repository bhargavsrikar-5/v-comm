# ADR 0001: Use Flutter + Spring Boot + relational persistence as the active target

- **Status:** Accepted for the unified migration candidate; not a production architecture sign-off.
- **Date:** 4 November 2026.

## Context

The project exists in multiple Firebase-era snapshots and a later Flutter + Spring Boot migration. The Firebase generation contains richer messaging and notification-related UI/logic; the later generation moves identity and core application data to a relational Spring Boot API.

## Decision

Use the later Flutter + Spring Boot code as the active starting point. Keep Firebase V1 under `legacy/firebase-v1/` for reference. Rebuild any selected V1 capability against the relational identity and API model; do not copy V1 Firebase service/screens unchanged into the active mobile app.

## Consequences

- The active client uses numeric relational IDs and bearer-authenticated REST calls.
- The active backend uses BCrypt hashes, JWT authentication, role checks and owner-scoped services.
- Group messaging, media, richer message actions and notifications require new relational/API design.
- The original Firebase rules were not supplied for verification; historical Firebase deployment must not be assumed secure.
- The active source remains a prototype until builds, tests, data-migration rehearsal and security review pass.
