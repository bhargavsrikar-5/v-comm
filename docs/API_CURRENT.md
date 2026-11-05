# Current API contract

Base URL: `http://localhost:8080/api` for local development. All endpoints except login and the intentionally-disabled public registration route require a valid `Authorization: Bearer <token>` header. The backend derives the acting user from the authenticated principal. Deployed clients must use HTTPS. `VCOMM_ALLOWED_EMAIL_DOMAINS` optionally configures institution-approved email domains; an empty value imposes no domain restriction, and domain matching does not verify mailbox ownership.

## Authentication — `/auth`

| Method | Route | Access | Purpose |
|---|---|---|---|
| POST | `/auth/login` | Public | Authenticate email/password; returns a user DTO and bearer token |
| POST | `/auth/register` | Public route, always returns 403 | Public self-registration is disabled |
| POST | `/auth/change-password` | Authenticated | Change the current user's password; identity comes from the principal |
| POST | `/auth/logout` | Authenticated | Increment the account token version, invalidating all its current tokens on their next API request |

## Users — `/users`

| Method | Route | Access | Purpose |
|---|---|---|---|
| GET | `/users?query=...` | Authenticated | List/search faculty directory |
| GET | `/users/{id}` | Authenticated | Read public profile fields for a faculty member |
| PUT | `/users/{id}` | Same user only | Update own profile fields |
| PUT | `/users/{id}/status` | Same user only | Update availability to Present, Absent, Available, Busy or In Class; the legacy `isPresent` boolean body remains accepted |
| PUT | `/users/{id}/timetable` | Same user only | Update own HTTPS timetable URL reference |
| GET | `/users/{id}/timetable/slots` | Authenticated | View the selected faculty member's structured weekly timetable |
| POST | `/users/{id}/timetable/slots` | Same user only | Add a course/activity slot; day and time range are validated for overlap |
| PUT | `/users/{id}/timetable/slots/{slotId}` | Same user only | Update an owned slot |
| DELETE | `/users/{id}/timetable/slots/{slotId}` | Same user only | Delete an owned slot |
| GET | `/users/{id}/search-history` | Same user only | Read own recent-search history |
| POST | `/users/{id}/search-history` | Same user only | Add a searched faculty member to own history |
| DELETE | `/users/{id}/search-history?searchedUserId=...` | Same user only | Remove one item or clear own history |

## Events — `/events`

| Method | Route | Access | Purpose |
|---|---|---|---|
| GET | `/events` | Authenticated | List the caller's events plus faculty-visible events; optional `date=YYYY-MM-DD` |
| GET | `/events/today` | Authenticated | Caller-owned and faculty-visible events for today |
| GET | `/events/upcoming` | Authenticated | Caller-owned and faculty-visible events from today onward |
| POST | `/events` | Authenticated | Create caller-owned event; title/date/start required, end optional; supports description, PRIVATE/FACULTY visibility and reminder minutes |
| PUT | `/events/{id}` | Event owner only | Update an owned event and its scheduling/visibility/reminder fields |
| DELETE | `/events/{id}` | Event owner only | Delete an owned event |

The client must not send `userId` to establish identity for these routes.

Event dates and `LocalTime` values use the backend/database local time zone, while the foreground reminder combines them with the device's local time. No institutional time zone is defined; deployments must keep server/database and client time zones aligned until a zone-aware scheduling policy is approved. Reminders are stored as event metadata and currently produce an in-app prompt only while the owner's Flutter home screen is open and refreshing. They are not scheduled OS or push notifications.

## Messages — `/messages`

| Method | Route | Access | Purpose |
|---|---|---|---|
| POST | `/messages` | Authenticated | Send direct text message; body contains `receiverId` and `content`; sender is derived from the principal |
| GET | `/messages/history?otherUserId={id}` | Authenticated | Fetch the direct conversation between the caller and the selected faculty member; mark incoming messages as read |
| GET | `/messages/conversations` | Authenticated | List direct conversations and unread counts for the caller |

Direct messages are one-to-one text. The client polls conversation summaries and open histories; history requests mark incoming messages read. There is no WebSocket/SSE transport.

## Groups — `/groups`

| Method | Route | Access | Purpose |
|---|---|---|---|
| GET | `/groups` | Authenticated | List memberships; a platform admin can list all groups |
| POST | `/groups` | Authenticated | Create a group; creator becomes its group administrator |
| GET | `/groups/{groupId}` | Member or platform admin | Read group details and member list |
| POST | `/groups/{groupId}/members` | Group admin or platform admin | Add a faculty account by user ID |
| DELETE | `/groups/{groupId}/members/{userId}` | Group admin or platform admin | Remove a member; owner removal is rejected |
| GET | `/groups/{groupId}/messages` | Member or platform admin | Read the latest 100 messages and update member read time |
| POST | `/groups/{groupId}/messages` | Group member | Send text (maximum 4000 characters) |

The mobile client refreshes group lists and open histories by polling. Group deletion, ownership transfer, pagination, attachments and rich message actions are not implemented.

## Administration — `/admin`

All routes require the `ADMIN` role.

| Method | Route | Access | Purpose |
|---|---|---|---|
| GET | `/admin/users` | Admin | List user DTOs |
| POST | `/admin/users` | Admin | Provision a faculty account with a BCrypt password hash |

There is no integrated admin web UI yet. The first administrator is bootstrapped only when `VCOMM_ADMIN_EMAIL` and `VCOMM_ADMIN_PASSWORD` are configured at backend startup. Public registration remains disabled.

## API limitations

- Password change and logout revoke account tokens through a token version checked against the database on each request. There is no refresh-token flow; access tokens also expire after the configured interval (default 12 hours).
- No rate limiting or account lockout has been implemented.
- List and message-history endpoints do not yet have pagination.
- The current uncommitted group, timetable, event, availability, token-version and domain-policy changes have not been tested or built. Historical CI results apply to the last pushed baseline only.
