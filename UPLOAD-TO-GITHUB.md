# Upload this migration candidate to GitHub

This archive is intended for the existing branch `migration/clean-source-audit` in `bhargavsrikar-5/v-comm`. Do not upload it to `main` yet.

## Recommended: GitHub Desktop

1. Clone `https://github.com/bhargavsrikar-5/v-comm.git` with GitHub Desktop if you have not already.
2. In GitHub Desktop, select branch `migration/clean-source-audit` (it already exists).
3. Extract this ZIP into a temporary folder.
4. Copy **all contents** of the extracted folder into the cloned repository root, allowing files with the same names to be replaced.
5. Review the changed-file list. Do not add any `.env`, `.jks`, `.keystore`, `google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`, or local build output.
6. Commit with message `feat: add unified V-COMM Flutter and Spring Boot baseline` and push the `migration/clean-source-audit` branch.
7. Do not merge into `main` until tests and feature/security review are complete.

If GitHub Desktop reports a conflict or unexpected deletion, stop and review before committing. The old source repositories are not modified by this package.
