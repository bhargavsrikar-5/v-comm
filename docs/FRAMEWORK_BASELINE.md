# Framework baseline selected for V-COMM

Checked on 4 November 2026.

| Component | Selected baseline | Notes |
|---|---|---|
| Flutter | Source constraint `sdk: ^3.9.0`; intended to be evaluated with a current stable Flutter SDK | Dependency resolution, `flutter analyze` and Flutter tests have not been run in this workspace. |
| Dart | `^3.9.0` constraint in `mobile/pubspec.yaml` | Keep until `flutter pub get` and analysis confirm any upgrade. |
| Java | 21 LTS | The backend targets Java 21. |
| Spring Boot | 3.5.16 | Kept for a smaller migration from the V2 codebase. Spring announced that 3.5.16 is the final open-source 3.5.x release; this version must be upgraded to a supported 4.x line before a long-lived public deployment. |
| Maven | 3.9+ recommended | The current environment did not include Maven, so no `mvn test` or package build was performed. |

## Framework support note

Spring Boot 3.5.16 release note: https://spring.io/blog/2026/06/25/spring-boot-3-5-16-available-now/ . The Spring team states this is the final open-source 3.5.x release and recommends moving to 4.0.x or 4.1.x for continuing open-source support. Spring Boot 4.1.0 release: https://spring.io/blog/2026/06/10/spring-boot-4/ .

## Verification gate

The version table records the current source selection, not proof that all code compiles. Before updating further dependencies or adopting Spring Boot 4.x, run `mvn test`, `flutter pub get`, `flutter analyze` and `flutter test`, then handle migration warnings deliberately.
