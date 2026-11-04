# V-COMM

**A Faculty-Centric Campus Communication and Scheduling Platform**

V-COMM is a university capstone project intended to bring faculty communication and day-to-day campus coordination into one application. The project scope documented by the team includes faculty profiles and availability, events/calendar, timetable access, faculty discovery, and direct/group communication.

> **Repository status: foundation scaffold.** This ZIP contains repository documentation, a proposed directory layout, and baseline ignore rules. It does **not** contain the Flutter application, Spring Boot implementation, database migrations, or a runnable release. Those will be migrated and implemented in subsequent, reviewed steps.

## Project team

This is a three-member university group project. Preserve the team attribution in future releases and documentation.

| Contributor | Student ID |
|---|---|
| Arava Hithesh Prem | 22BCE20145 |
| Chegu Bhargav Srikar | 22BCE7676 |
| Malisetty Rupesh | 22BCE9097 |

**Project guide:** Dr. Kumar Debasis  
**Institution:** VIT-AP University, School of Computer Science and Engineering  
**Project report:** December 2025

## Intended technology direction

- **Mobile client:** Flutter / Dart.
- **Backend:** Java 21 with Spring Boot 3 REST APIs.
- **Database:** MySQL for persistent deployments; H2 may be used for local development and automated tests.
- **Admin experience:** a role-protected web interface that uses the same backend API. The existing Firebase-connected admin page is a legacy reference and is not integrated with the planned SQL backend.

This is the target direction, not a claim that all components are already integrated or production-ready. See [Architecture](docs/ARCHITECTURE.md) and [Migration Plan](docs/MIGRATION_PLAN.md).

## Repository layout

```text
v-comm/
├── admin/       # Admin interface; backend integration to be implemented
├── backend/     # Spring Boot REST API; implementation to be migrated/reviewed
├── mobile/      # Flutter application; implementation to be migrated/reviewed
├── docs/        # Architecture, migration, security, testing and decisions
└── scripts/     # Safe developer/CI helper scripts (added as needed)
```

## Current status

- [x] New canonical GitHub repository created.
- [x] Initial architecture and migration documentation scaffolded.
- [ ] Select and migrate the reviewed Flutter source snapshot.
- [ ] Select and migrate the reviewed Spring Boot source snapshot.
- [ ] Replace legacy Firebase admin integration with backend API integration.
- [ ] Implement authentication, authorization, password hashing and data access controls.
- [ ] Restore missing messaging capabilities against the SQL-backed API where approved.
- [ ] Add repeatable local setup, automated tests and CI.
- [ ] Verify end-to-end mobile, backend and admin workflows.

See [Project Status](docs/PROJECT_STATUS.md) for the work sequence and verification gates.

## Before running anything

This starter scaffold is documentation-only. There is no application command to run yet. When the application code is added, its exact prerequisites and commands must be documented in the relevant `mobile/`, `backend/` and `admin/` READMEs.

## Security and repository hygiene

- Never commit `.env` files, API tokens, database passwords, service-account JSON, private keys, or Android signing keystores.
- Treat any signing key previously committed to an older repository as exposed; assess replacement before publishing releases.
- Do not deploy the current legacy backend as-is. The source review identified plaintext password handling and insufficiently demonstrated endpoint authorization. See [Security Baseline](docs/SECURITY_BASELINE.md).
- Do not copy Firebase credentials, production user data, generated build output, IDE state, or browser profiles into this repository.

## License

No license is included in this scaffold. Confirm ownership and permission for all contributed code and assets with the full project team before choosing and adding a license.
