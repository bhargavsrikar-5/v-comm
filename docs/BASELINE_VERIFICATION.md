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
- GitHub Actions Run #9 completed successfully on PR #2 head commit `84d4b5bb7f2f4565dde0dca1ccb2876930e7acd8`, which is included in the merged `main` branch. Backend Maven tests, Flutter analysis and tests, Android debug build, and iOS simulator build all passed.
- Release Android manifest now declares INTERNET; debug-only cleartext traffic is limited to local backend development.
- Official Gradle 8.14.3 wrapper scripts and JAR are tracked; the JAR matches the published checksum and the distribution URL is checksum-pinned. Android debug APK build passed in GitHub Actions Run #9 with the workflow's configured toolchain.

## Not yet verified

- Full manual sign-in, provisioning, profile, search, event, timetable, direct/group chat and cross-user workflows have not been verified end-to-end on a running deployment or physical device.
- MySQL connection, Flyway schema migration/persistence across restart, physical-device walkthrough, full end-to-end flows and penetration testing.
- Penetration testing, rate limiting, refresh-token/session management or security-event auditing. Token-version revocation is implemented in source, but CI is not a substitute for a security review.
- Media upload, integrated admin UI, push/background notifications, and rich message actions.

## Environment limitation

No local builds or tests were run during this documentation cleanup. CI Run #9 passed on the PR head commit noted above. That run does not verify a production deployment, MySQL operations, physical-device behavior, full end-to-end workflows, or penetration resistance.
