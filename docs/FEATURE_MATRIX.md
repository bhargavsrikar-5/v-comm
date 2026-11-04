# Feature verification matrix

Status definitions:

- **Present in active source** — corresponding code exists in the unified Flutter/API source; runtime behavior is not independently verified here.
- **Legacy reference only** — available in the older Firebase source but not integrated into the active Spring Boot API.
- **Partial / not verified** — source implementation exists but requires additional integration, automated tests or operational setup.
- **Not implemented** — not found in the active source baseline.

| Feature | Firebase V1 source | Active Spring Boot candidate | Current assessment |
|---|---|---|---|
| Faculty sign-in | Firebase Authentication | Login + BCrypt + JWT + secure token storage | Present in source; runtime/security tests pending |
| Public registration | Admin-provisioned accounts | Public endpoint returns 403; admin provisioning API | Admin API present; integrated admin UI absent |
| Password recovery | Firebase reset-email flow | Not found | Not implemented |
| Change password | Profile flow | Authenticated API | Present in source; token revocation is not implemented |
| Faculty profile | Profile/edit screens | Profile/edit screens + DTO-backed API | Present in source; integration tests pending |
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
| Role-based access control | Firebase rules need separate verification | FACULTY/ADMIN roles + Spring Security | Present in source; automated authorization tests pending |
| Backend security/ownership tests | Firebase rules not available for automated review | JWT signature/claims/config and event owner unit tests added | Source added; execution pending; route-level authorization tests still needed |

## Verification note

This matrix is based on static inspection of supplied source snapshots. No Flutter build, Maven test, MySQL deployment, device walkthrough, live Firebase inspection or end-to-end test was performed as part of this package preparation. Source presence is not equivalent to runtime verification.
