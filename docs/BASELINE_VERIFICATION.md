# Baseline verification record

## Static inspection completed

- Repository structures compared for the older Firebase and newer Spring Boot generations.
- Flutter and backend source files inventoried.
- Backend authentication, authorization, DTOs, domain services and database migration statically inspected.
- JWT issuance and validation, BCrypt configuration, protected admin routes and owner checks identified in current candidate source.
- Legacy Firebase group/messaging/media/notification modules inspected as migration references.
- Firebase configuration, signing keystores, local build caches and platform-generated output excluded from this candidate.
- Android application identifier and Flutter API base URL configured for the unified workspace.
- A stale Flutter secure-storage helper reference was corrected in this candidate before packaging.
- XML, POM, plist, JSON and YAML files passed structural parsing during package preparation; this is not an application compile or dependency-resolution check.

## Not yet verified

- Flutter dependency resolution, `flutter analyze`, Flutter widget tests or Android APK build.
- Maven compile/test or Spring Boot runtime startup.
- MySQL connection, Flyway schema migration or data persistence across restart.
- Full end-to-end sign-in, provisioning, events, search, profile and chat flows.
- Authorization/data-isolation behavior through integration tests.
- Penetration testing, rate limiting or token revocation.
- Group messaging, media upload, admin UI or push notifications.

## Environment limitation

Java 21 is present in the workspace, but Maven, Flutter and Dart executables are not installed. Therefore no claim of a successful Maven or Flutter build is made. Run the commands in the root README or configure CI before calling the app build-verified.
