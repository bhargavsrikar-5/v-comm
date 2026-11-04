# Feature verification matrix

Status definitions:

- **Present in active source** — corresponding code exists in the unified Flutter/API source; runtime behavior is not independently verified here.
- **Legacy reference only** — available in the older Firebase source but not integrated into the active Spring Boot API.
- **Partial / not verified** — source implementation exists but requires additional integration, automated tests or operational setup.
- **Not implemented** — not found in the active source baseline.

| Feature | Firebase V1 source | Active Spring Boot candidate | Current assessment |
|---|---|---|---|
| Faculty sign-in | Firebase Authentication | Login + BCrypt + JWT + secure token storage | Backend auth and authorization tests passed in GitHub Actions run 6; full mobile/device sign-in flow remains unverified |
| Public registration | Admin-provisioned accounts | Public endpoint returns 403; admin provisioning API | Admin API present; integrated admin UI absent |
| Password recovery | Firebase reset-email flow | Not found | Not implemented |
| Change password | Profile flow | Authenticated API | Present in source; token revocation is not implemented |
| Faculty profile | Profile/edit screens | Profile/edit screens + DTO-backed API | HTTP profile ownership tests passed in GitHub Actions run 6; full Flutter-to-API flow remains unverified |
| Faculty directory/search | Firestore search UI | Authenticated search API + Flutter screen | Present in source; pagination absent |
| Recent search history | Firestore profile history | Authenticated owner-scoped API/model | Present in source; runtime verification pending |
| Present/absent status | Firestore status update | Owner-scoped API + Flutter UI | Present in source |
| Timetable view/link | Drive link and zoomable viewer | URL field and profile/home support | Partial; secure file upload not implemented |
| Timetable image upload | Firebase Storage in local snapshot | Not found as object upload | Legacy reference only |
| Calendar | Firestore stream + calendar UI | Calendar screen + event API | Present in source; H2/MySQL runtime tests pending |
| Event create/edit/delete | Firestore CRUD | Owner-scoped event API CRUD | Present in source |
| Today/upcoming dashboard | Local snapshot | Home screen + today/upcoming endpoints | Present in source |
| One-to-one text chat | Firestore streams | Authenticated REST API + Flutter screen | Present in source; client polling, no push transport |
| Unread counts/read markers | Firestore counters | API count + mark-read behavior | Present in source; concurrency/performance tests pending |
| Group chats | Group create/member management | No group/conversation tables or routes | Legacy reference only |
| Image/media messages | Firebase Storage + picker | Not found | Legacy reference only |
| Replies/forwarding | Message metadata/UI | Not found | Legacy reference only |
| Reactions | Message metadata/UI | Not found | Legacy reference only |
| Pin/star messages | Message metadata/UI | Not found | Legacy reference only |
| Edit/delete message | Sender actions in V1 | Not found | Legacy reference only |
| Archive chat/filtering | V1 filters and per-user state | Not found | Legacy reference only |
| Local reminders | Scheduler in recovered snapshot; no call sites found | Not found | Not integrated / unverified |
| Push notifications | Cloud Function topic send; client topic subscription not found | Not found | Not end-to-end verified |
| Notification preferences | UI toggle had TODO save action | Not found | Not implemented persistently |
| Admin user panel | Separate Firebase HTML panel | Protected admin API only | Admin UI not integrated; endpoint requires ADMIN role |
| Role-based access control | Firebase rules need separate verification | FACULTY/ADMIN roles + Spring Security | HTTP role authorization tests passed in CI; broader admin workflows remain unverified |
| Backend security/ownership tests | Firebase rules not available for automated review | JWT signature/claims/config and HTTP ownership tests | GitHub Actions run 6 passed JWT, login, password-change, admin-role, profile/search-history ownership and cross-user event isolation tests |

## Verification note

This matrix combines static inspection with GitHub Actions run 6, which passed Maven tests, Flutter analysis/tests and the Android debug APK build. The iOS simulator build passed in run 3; its run 6 job remains queued. MySQL deployment, physical-device walkthrough, live Firebase inspection and full end-to-end testing remain outstanding. Source presence is not equivalent to full feature verification.
