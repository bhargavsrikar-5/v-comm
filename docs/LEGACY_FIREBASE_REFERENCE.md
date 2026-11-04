# Legacy Firebase source reference

`legacy/firebase-v1/` preserves the old Flutter + Firebase Dart source and supporting Cloud Function/admin-panel code for comparison while porting features into the active V-COMM architecture.

- It is not part of the active Flutter build.
- Firebase options, Android `google-services.json`, iOS/macOS Google service plists, `.firebaserc`, and live project identifiers were intentionally excluded.
- Firestore and Storage security rules were not present in the reviewed source snapshots.
- The Cloud Function sends notifications to a topic named `allUsers`; the reviewed Flutter source did not contain a matching topic subscription.
- The local notification scheduler found in the recovered working copy is not called by the app in the inspected source.

Do not re-add the original live Firebase configuration or deploy this legacy source as-is. Reimplement the desired behavior against the secured V-COMM API and approved storage/notification services.
