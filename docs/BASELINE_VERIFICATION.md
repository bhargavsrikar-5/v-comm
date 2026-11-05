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
- GitHub Actions run 6 passed `mvn test`, Flutter analysis/tests and an Android debug APK build on the previously pushed baseline. These results do not cover the current uncommitted migration changes.
- Release Android manifest now declares INTERNET; debug-only cleartext traffic is limited to local backend development.
- Official Gradle 8.14.3 wrapper scripts and JAR are tracked; the JAR matches the published checksum and the distribution URL is checksum-pinned. Android debug APK build passed in GitHub Actions run 6 with AGP 8.11.1 and Kotlin 2.2.20.

## Not yet verified

- The current local changes to group messaging, structured timetable slots, event metadata/reminders, token versioning and configurable email domains have not been compiled, tested or run.
- Historical Flutter analysis/tests and Android debug APK build passed in GitHub Actions run 6 for the prior pushed baseline. The iOS simulator build passed in run 3; run 6's iOS job was recorded as queued at the last check, and its current state was not checked in this handoff.
- MySQL connection, Flyway schema migration/persistence across restart, physical-device walkthrough, full end-to-end flows and penetration testing.
- Full end-to-end sign-in, provisioning, events, search, profile and chat flows.
- Penetration testing, rate limiting, refresh-token/session management or security-event auditing. Token-version revocation exists in the current uncommitted source but has not been verified.
- Media upload, integrated admin UI, push/background notifications, and rich message actions.

## Environment limitation

No builds or tests were run for this implementation checkpoint by instruction. Historical GitHub Actions run 6 results apply only to the earlier pushed baseline; they must not be used to claim that this local source passes. The current changed source requires the final testing phase.
