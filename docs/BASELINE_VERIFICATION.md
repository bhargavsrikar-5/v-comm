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
- GitHub Actions run 3 passed `mvn test`, including JWT, event ownership, login, password change, admin authorization and profile/search-history isolation tests.
- Release Android manifest now declares INTERNET; debug-only cleartext traffic is limited to local backend development.
- Official Gradle 8.14.3 wrapper scripts and JAR are tracked; the JAR matches Gradle’s published checksum and the distribution URL is checksum-pinned. Android build rerun is pending after the initial Gradle minimum-version failure.

## Not yet verified

- Flutter analysis, Flutter tests and the iOS simulator build passed in GitHub Actions run 3. Android debug build with the upgraded wrapper is pending.
- MySQL connection, Flyway persistence across restart, physical-device walkthrough, full end-to-end flows and penetration testing.
- MySQL connection, Flyway schema migration or data persistence across restart.
- Full end-to-end sign-in, provisioning, events, search, profile and chat flows.
- Authorization/data-isolation behavior through integration tests.
- Penetration testing, rate limiting or token revocation.
- Group messaging, media upload, admin UI or push notifications.

## Environment limitation

Java, Maven, Flutter and Dart executables are not available in this Windows environment, so no local build/test was run. GitHub Actions run 3 passed Maven tests, Flutter analysis/tests and the iOS simulator build. The Android rerun after the Gradle 8.14.3 upgrade is pending.
