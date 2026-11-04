# V-COMM

**A faculty-centred campus communication and scheduling platform**

V-COMM is a three-member university group project. This unified repository brings together the newer Flutter + Spring Boot implementation and the earlier Firebase-era source as a feature reference. It preserves the team's contribution history rather than presenting the work as a solo project.

> **Project status: migration candidate / working prototype source.** GitHub Actions run 3 passed the Maven test suite, Flutter analysis/tests and iOS simulator build. The first Android build failed because Flutter 3.47.9 requires Gradle 8.14 while the initial wrapper was 8.12; the wrapper is now upgraded and pinned to Gradle 8.14.3, with an Android rerun pending. MySQL deployment, physical-device and full end-to-end verification remain outstanding. Group messaging, media messaging, an integrated admin web UI, notifications and several richer V1 message actions remain future work. Do not treat this repository as production-ready.

## Team

| Contributor | GitHub |
|---|---|
| Chegu Bhargav Srikar | [@bhargavsrikar-5](https://github.com/bhargavsrikar-5) |
| Arava Hithesh Prem | [@hithesh1120](https://github.com/hithesh1120) |
| Malisetty Rupesh | [@Rupesh42590](https://github.com/Rupesh42590) |

Project guide: **Dr. Kumar Debasis** · **VIT-AP University, School of CSE** · Capstone report: **December 2025**.

See [AUTHORS.md](AUTHORS.md) for attribution notes and source repositories.

## Current technology

- **Mobile:** Flutter / Dart.
- **API:** Java 21, Spring Boot 3.5.16, Spring Web, Spring Data JPA and Spring Security.
- **Authentication:** BCrypt password hashing and stateless HS256 JWT bearer tokens.
- **Database:** H2 in-memory for local evaluation by default; MySQL for persistent local/deployed environments.
- **Schema management:** Flyway SQL migration.
- **Legacy reference:** Flutter + Firebase source under `legacy/firebase-v1/`; it is not part of the active build.

Spring Boot 3.5.16 was the final open-source 3.5.x release. Upgrade to a supported Spring Boot 4.x line and run the full regression suite before a long-lived public deployment. See [Framework Baseline](docs/FRAMEWORK_BASELINE.md).

## Repository layout

```text
v-comm/
├── mobile/                       # Active Flutter client
├── backend/                      # Active Spring Boot API
├── admin/                        # Admin UI status and integration notes
├── legacy/firebase-v1/            # Historical Firebase implementation (reference only)
├── legacy/springboot-v2-reference/ # Original V2 README / provenance
├── docs/                         # Architecture, features, API, security, migration
├── AUTHORS.md
├── CONTRIBUTING.md
├── SECURITY.md
└── LICENSE-STATUS.md
```

## Features in the current source

- Faculty sign-in with a server-issued bearer token.
- Faculty directory search and profile viewing/editing.
- Present/absent status and timetable URL reference.
- Event calendar with create, update, delete, today and upcoming views.
- One-to-one text messages, conversation list, unread counts and read markers (client refreshes/polls; no WebSocket transport yet).
- Admin-only faculty account provisioning API.

The old Firebase generation contains additional reference implementations for group chats, image/media messages, replies, forwarding, reactions, pin/star, archive and notification-related behavior. These are **not** integrated into the active Spring Boot application yet. See [Feature Matrix](docs/FEATURE_MATRIX.md).

## Local setup

### Prerequisites

- Flutter SDK compatible with the Dart constraint in `mobile/pubspec.yaml`.
- Java 21.
- Maven 3.9+.
- MySQL 8+ only when using the MySQL configuration; H2 is the default local database.

### 1. Configure and start the backend

The backend requires a strong `JWT_SECRET` (at least 32 UTF-8 bytes). To enable the first administrator account, configure both `VCOMM_ADMIN_EMAIL` and `VCOMM_ADMIN_PASSWORD` (minimum 14 characters). No reusable demo credentials are committed.

**PowerShell example:**

```powershell
$env:JWT_SECRET = [Convert]::ToBase64String([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(48))
$env:VCOMM_ADMIN_EMAIL = "admin@example.edu"
$env:VCOMM_ADMIN_PASSWORD = "REPLACE-WITH-A-UNIQUE-14-CHARACTER-OR-LONGER-PASSWORD"
$env:VCOMM_ADMIN_NAME = "V-COMM Administrator"
cd backend
mvn spring-boot:run
```

**Bash example:**

```bash
export JWT_SECRET="$(openssl rand -base64 48)"
export VCOMM_ADMIN_EMAIL="admin@example.edu"
export VCOMM_ADMIN_PASSWORD="REPLACE-WITH-A-UNIQUE-14-CHARACTER-OR-LONGER-PASSWORD"
export VCOMM_ADMIN_NAME="V-COMM Administrator"
cd backend
mvn spring-boot:run
```

The API listens on `http://localhost:8080/api`. H2 is in-memory and data is lost when the backend stops. For MySQL, set `DB_URL`, `DB_DRIVER=com.mysql.cj.jdbc.Driver`, `DB_USERNAME` and `DB_PASSWORD` before starting the API. Keep credentials in your local environment or secret manager, never in Git.

The first admin account is provisioned at startup only when the environment variables are configured and the email is not already present. Use the admin bearer token to create faculty accounts through `POST /api/admin/users`. There is currently **no integrated admin web UI**; the endpoint can be exercised with an API client (for example, Postman or `curl`).

### 2. Install and run the Flutter client

```bash
cd mobile
flutter pub get
flutter analyze
flutter test
```

Set the API URL at run time:

```bash
# Android emulator
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api

# iOS simulator / browser / desktop on the same host
flutter run --dart-define=API_BASE_URL=http://localhost:8080/api

# Physical Android/iOS device: replace the host with your development machine's LAN IP
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080/api
```

The Flutter client stores its access token using `flutter_secure_storage` and attaches it as a Bearer token to authenticated API calls. Browser CORS origins are configured separately through `APP_CORS_ALLOWED_ORIGINS`.

Android release builds declare the INTERNET permission; cleartext traffic is enabled only in the debug manifest for local API development. Configure HTTPS for release API deployments. The Android Gradle 8.14.3 wrapper scripts and JAR are tracked in `mobile/android/gradle/wrapper/` and `mobile/android/gradlew[.bat]`. The wrapper downloads Gradle 8.14.3 on first use.

### 3. Backend verification

```bash
cd backend
mvn test
```

These are the required commands, not a claim that they have already passed. See [Baseline Verification](docs/BASELINE_VERIFICATION.md) for the checks actually performed and the remaining verification gates.

Backend unit and HTTP integration test sources cover JWT verification, login, role-protected admin access, profile ownership and event ownership. They must still be run with Maven before their results can be considered verified.

## Security and data migration

- Passwords are stored as BCrypt hashes in `password_hash`; user API responses use `UserResponse` DTOs.
- Non-public endpoints require a valid Bearer token; the acting user is derived from the authenticated principal for user-owned actions.
- Admin routes require the `ADMIN` role.
- JWT signing secret, admin bootstrap credentials and database credentials are environment-supplied.
- H2 console is disabled by default; do not enable it on an exposed network.
- The Flyway schema is for a **new unified database**. It does not automatically convert an older V2 plaintext-password database. Re-provision faculty accounts with password resets; do not copy old plaintext passwords into the new schema.
- Previously committed Android signing keystores in old repositories must be treated as exposed. They are not included here.
- Legacy Firebase config/rules were not supplied as a complete deployable set. Do not re-add old service config or assume Firestore/Storage security rules are safe.

See [Security Review](docs/SECURITY_AUDIT.md) and [SECURITY.md](SECURITY.md). This work has not been penetration-tested.

## Licence and redistribution

No open-source licence is included. Obtain agreement from all three contributors and review third-party assets before adding a licence or authorizing redistribution. See [LICENSE-STATUS.md](LICENSE-STATUS.md).

## Project documentation

- [Architecture](docs/ARCHITECTURE.md)
- [Feature Matrix](docs/FEATURE_MATRIX.md)
- [Current API Contract](docs/API_CURRENT.md)
- [Security Review](docs/SECURITY_AUDIT.md)
- [Migration Plan](docs/MIGRATION_PLAN.md)
- [Data Model](docs/DATA_MODEL.md)
- [Source Provenance](docs/SOURCE_PROVENANCE.md)
- [Baseline Verification](docs/BASELINE_VERIFICATION.md)

---

**V-COMM — one place for faculty communication and coordination.**
