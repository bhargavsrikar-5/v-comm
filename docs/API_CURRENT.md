# Current API contract

Base URL: `http://localhost:8080/api` by default. All endpoints except login and the intentionally-disabled public registration route require a valid `Authorization: Bearer <token>` header. The backend derives the acting user from the JWT principal.

## Authentication — `/auth`

| Method | Route | Access | Purpose |
|---|---|---|---|
| POST | `/auth/login` | Public | Authenticate email/password; returns a user DTO and bearer token |
| POST | `/auth/register` | Public route, always returns 403 | Public self-registration is disabled |
| POST | `/auth/change-password` | Authenticated | Change the current user's password; identity comes from the principal |

## Users — `/users`

| Method | Route | Access | Purpose |
|---|---|---|---|
| GET | `/users?query=...` | Authenticated | List/search faculty directory |
| GET | `/users/{id}` | Authenticated | Read public profile fields for a faculty member |
| PUT | `/users/{id}` | Same user only | Update own profile fields |
| PUT | `/users/{id}/status` | Same user only | Update own present/absent status |
| PUT | `/users/{id}/timetable` | Same user only | Update own HTTP(S) timetable URL reference |
| GET | `/users/{id}/search-history` | Same user only | Read own recent-search history |
| POST | `/users/{id}/search-history` | Same user only | Add a searched faculty member to own history |
| DELETE | `/users/{id}/search-history?searchedUserId=...` | Same user only | Remove one item or clear own history |

## Events — `/events`

| Method | Route | Access | Purpose |
|---|---|---|---|
| GET | `/events` | Authenticated | List the current user's events; optional `date=YYYY-MM-DD` |
| GET | `/events/today` | Authenticated | Current user's events for today |
| GET | `/events/upcoming` | Authenticated | Current user's events from today onward |
| POST | `/events` | Authenticated | Create event owned by the current user |
| PUT | `/events/{id}` | Event owner only | Update an owned event |
| DELETE | `/events/{id}` | Event owner only | Delete an owned event |

The client must not send `userId` to establish identity for these routes.

## Messages — `/messages`

| Method | Route | Access | Purpose |
|---|---|---|---|
| POST | `/messages` | Authenticated | Send direct text message; body contains `receiverId` and `content`; sender is derived from the principal |
| GET | `/messages/history?otherUserId={id}` | Authenticated | Fetch the direct conversation between the caller and the selected faculty member; mark incoming messages as read |
| GET | `/messages/conversations` | Authenticated | List direct conversations and unread counts for the caller |

The current message model is one-to-one text only. Group conversations, attachments and richer message actions are not yet implemented in the active API. The mobile client refreshes conversation data; there is no WebSocket/SSE transport in the current source.

## Administration — `/admin`

All routes require the `ADMIN` role.

| Method | Route | Access | Purpose |
|---|---|---|---|
| GET | `/admin/users` | Admin | List user DTOs |
| POST | `/admin/users` | Admin | Provision a faculty account with a BCrypt password hash |

There is no integrated admin web UI yet. The first administrator is bootstrapped only when `VCOMM_ADMIN_EMAIL` and `VCOMM_ADMIN_PASSWORD` are configured at backend startup. Public registration remains disabled.

## API limitations

- No refresh token or server-side token revocation is implemented; access tokens expire after the configured interval (default 12 hours).
- No rate limiting or account lockout has been implemented.
- List and message-history endpoints do not yet have pagination.
- Error and authorization behavior has not been verified with automated integration tests in this environment.
