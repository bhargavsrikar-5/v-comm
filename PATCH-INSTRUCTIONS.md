# V-COMM follow-up fixes

This package supplements the migration candidate already uploaded to `migration/clean-source-audit`.

## Included
- Reorders the Android Gradle Kotlin DSL `plugins {}` block to the top of the build script.
- Removes stale `GoogleService-Info.plist` references from the iOS and macOS Xcode projects. Those project-specific Firebase files are intentionally not carried into the active Spring Boot app.
- Restores eight dotfiles missed by the browser folder upload.
- Expands the root `.gitignore` for generated Flutter/Xcode files.

## Apply
Extract this ZIP. Upload/replace each file at its matching path in the GitHub repository while on `migration/clean-source-audit`. Keep the directories exactly as shown in the ZIP.

The iOS `Podfile.lock` still contains dependencies from the older Firebase build. Regenerate it after running `flutter pub get` and `pod install` in a Flutter/macOS environment. Do not call the iOS build verified until that is done.

This is a source correction package, not a build/test result. Maven, Flutter and CocoaPods builds remain pending.
