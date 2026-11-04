# ADR 0001: Target architecture for the unified repository

- **Status:** Proposed
- **Date:** 2026-11-04

## Context

The project exists in at least two implementation generations: an earlier Flutter/Firebase implementation and a later Flutter/Spring Boot/SQL implementation. The identity and persistence models differ, so directly combining their data/service layers would create incompatible assumptions.

## Decision

Use Flutter as the mobile client and Java Spring Boot REST APIs with a relational database as the target architecture. Treat the Firebase generation as a reference for feature behavior and UI expectations. The admin UI must integrate through the same secured backend API.

## Consequences

- Feature behavior can be recovered without retaining Firebase as a second source of truth.
- API contracts and relational data mapping must be designed explicitly.
- Security issues identified in the later backend must be fixed before deployment.
- Real-time chat, media storage, notification delivery and admin permissions remain design decisions until their requirements and controls are agreed.

## Revisit when

The team identifies deployment constraints or confirms a requirement that materially changes this architecture.
