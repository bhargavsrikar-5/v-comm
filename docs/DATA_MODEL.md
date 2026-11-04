# Data model

## Current relational entities

| Entity/table | Current purpose | Main fields |
|---|---|---|
| `User` / `users` | Faculty identity/profile | id, name, email, `password_hash`, role, department, custom ID, phone, photo URL, timetable URL, present flag, createdAt |
| `Event` / `events` | User-owned calendar event | id, userId, title, time (currently free text), eventDate, createdAt |
| `Message` / `messages` | One-to-one text message | id, senderId, receiverId, content, sentAt, isRead |
| `SearchHistory` / `search_history` | Recent faculty searches | id, userId, searchedUserId, searched-user snapshot fields, searchedAt |

Password hashes are never intended to be returned to clients. The API uses `UserResponse` DTOs; the entity's password-hash property is also marked `@JsonIgnore` as defense in depth.

## Current model limitations

- Message records support only one sender and one receiver; there is no group/conversation entity.
- Message content has no type or attachment metadata.
- Replies, forwarding, reactions, per-user pins/stars, archive state and delete-for-me state are absent.
- Event time is stored as a string rather than structured start/end instants with a time zone.
- Timetable data is an HTTP(S) URL reference; controlled upload/storage is not implemented.
- Message history and conversation queries do not yet expose pagination.

## Target domain model to design and migrate

- `users`, `roles`, and role assignments.
- `conversations` with `DIRECT` / `GROUP` type.
- `conversation_members` with membership role, joined/left timestamps, archive state and last-read marker.
- `messages` linked to a conversation and authenticated sender.
- `message_attachments` for object-storage keys, media type, size and checksum.
- `message_reactions` keyed by message/user/reaction.
- `message_pins` and `message_stars` as per-user or conversation-level state, according to agreed product rules.
- `events` with owner, title, description, structured start/end date-time and time zone.
- `timetables` or profile timetable metadata pointing to controlled storage, not arbitrary public URLs.
- `search_history` tied to the authenticated user.

This target is a design proposal, not implemented schema. The current Flyway V1 migration is for a new unified database and does not transform the old plaintext-password database.
