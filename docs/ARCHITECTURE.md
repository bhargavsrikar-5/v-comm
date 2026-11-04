# V-COMM Architecture

## 1. Goal and scope

V-COMM is intended to provide faculty with a unified place to manage their faculty profile and availability, find colleagues, access timetable information, coordinate events, and communicate through direct and group conversations.

The December 2025 capstone report describes a Flutter client backed by Firebase services. A later source snapshot migrates the backend direction to Java Spring Boot and a relational database. The canonical repository should use the Spring Boot + SQL direction as its target architecture while treating the Firebase version as a feature and behavior reference.

## 2. Target logical architecture

```text
┌─────────────────────┐       HTTPS / JSON       ┌────────────────────────┐
│ Flutter mobile app  │ ───────────────────────▶ │ Spring Boot REST API   │
│ Dart                │ ◀─────────────────────── │ Java 21 / Spring Boot 3│
└─────────────────────┘                          └────────────┬───────────┘
                                                              │
┌─────────────────────┐       HTTPS / JSON                    │ JPA / SQL
│ Admin web interface │ ──────────────────────────────────────┘
│ Role-protected UI   │                                       │
└─────────────────────┘                             ┌─────────▼──────────┐
                                                    │ MySQL              │
                                                    │ H2 for tests/local │
                                                    └────────────────────┘
```

The diagram is a proposed target, not a verified deployment diagram. The admin interface must call the Spring Boot API; it must not maintain a separate Firebase user store.

## 3. Main components

### Mobile client (`mobile/`)

Flutter application for sign-in, profile and presence, faculty directory/search, events/calendar, timetable access, and messaging. The client should contain presentation and client-side state only; authorization and sensitive business rules belong on the server.

### Backend (`backend/`)

Spring Boot REST API. It should own authentication/session validation, authorization, validation, business rules, persistence, and safe response DTOs. Controllers must not serialize persistence entities directly when those entities contain password hashes or internal fields.

### Admin (`admin/`)

A web-based administrative interface for authorized staff. It should use backend endpoints and server-side role checks. The currently supplied legacy admin page uses Firebase client SDK calls and is not compatible with the SQL-backed target without a deliberate rewrite.

### Persistence

MySQL is the intended persistent database. H2 can support isolated tests and local development, but an in-memory H2 configuration must not be mistaken for persistent production storage.

## 4. Existing implementation generations

The reviewed source sets indicate two materially different generations:

| Area | Earlier Firebase generation | Later Spring Boot generation |
|---|---|---|
| Mobile | Flutter | Flutter |
| Backend/data | Firebase Auth, Firestore, Storage and Cloud Functions | Java Spring Boot REST API with MySQL/H2 configuration |
| Faculty directory and presence | Present in source/feature materials | Present in source |
| Events/calendar | Present in source/feature materials | Present in source |
| Timetable | Link-based access in source/feature materials | URL-based support in source |
| Messaging | Direct and group messaging with richer message actions described in feature materials | Direct text messaging and conversation list; polling is used in the reviewed implementation |
| Admin page | Firebase-connected | Legacy Firebase admin page remains disconnected from the SQL backend |

This comparison is based on static source/document review. It is not proof that every feature is fully operational in a deployed environment.

## 5. Migration principles

1. Keep one canonical implementation of each feature in this repository.
2. Use the later Spring Boot version as the backend architecture starting point, subject to security remediation.
3. Use the older Firebase implementation and project documents as references for intended UX and feature behavior—not as code to paste blindly into the SQL-backed implementation.
4. Map Firebase-era identifiers and document structures to explicit relational entities and API DTOs. Do not assume Firebase UIDs and SQL numeric IDs are interchangeable.
5. Migrate in small reviewable changes with tests and a recorded source commit for provenance.
6. Do not include signing keys, credentials, user databases, generated build folders, or machine-specific state.

## 6. Decisions still required

- Final authentication/session approach and token/session revocation strategy.
- Exact relational schema and migration tool.
- Whether chat delivery remains polling-based initially or moves to WebSocket/SSE.
- File/image upload storage and access-control design.
- Push-notification provider and consent/permission flow.
- Admin roles, permissions and audit requirements.
- License and ownership/third-party asset review.

Do not treat these undecided items as implemented features.
