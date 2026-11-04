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
- Backend test sources cover JWT claims/signature/configuration, event ownership and HTTP-level login, role authorization, profile ownership and search-history isolation. Tests have not been executed in this environment.
- Release Android manifest now declares INTERNET; debug-only cleartext traffic is limited to local backend development.
- Official Gradle 8.12 wrapper scripts and JAR are now tracked; the JAR was extracted from a checksum-verified official Gradle distribution. The wrapper/build has not yet been executed.

## Not yet verified

- Flutter dependency resolution, `flutter analyze`, Flutter widget tests, Android wrapper execution or Android APK build.
- Maven compile/test or Spring Boot runtime startup.
- MySQL connection, Flyway schema migration or data persistence across restart.
- Full end-to-end sign-in, provisioning, events, search, profile and chat flows.
- Authorization/data-isolation behavior through integration tests.
- Penetration testing, rate limiting or token revocation.
- Group messaging, media upload, admin UI or push notifications.

## Environment limitation

Java, Maven, Flutter and Dart executables were not found on PATH in the V-COMM checkout environment. No Maven or Flutter test/build was run, and no passing result is claimed. A GitHub Actions workflow now runs backend tests, Flutter analysis/tests, an Android debug APK build and an iOS simulator build; its first run has not reported a result yet.\n