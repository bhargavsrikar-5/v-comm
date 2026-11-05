# Data model

## Current relational entities

| Entity/table | Current purpose | Main fields |
|---|---|---|
| `User` / `users` | Faculty identity/profile | id, name, email, `password_hash`, role, department, custom ID, phone, photo URL, timetable URL, legacy present flag, availability status, token version, createdAt |
| `Event` / `events` | User-owned calendar event | id, userId, title, legacy time text, eventDate, description, local start/end time, PRIVATE/FACULTY visibility, reminder minutes, createdAt |
| `Message` / `messages` | One-to-one text message | id, senderId, receiverId, content, sentAt, isRead |
| `SearchHistory` / `search_history` | Recent faculty searches | id, userId, searchedUserId, searched-user snapshot fields, searchedAt |
| `TimetableSlot` / `timetable_slots` | Structured weekly course/activity entry | id, userId, weekday, local start/end time, course/activity, details, location, updatedAt |
| `GroupChat` / `group_chats` | Group text conversation metadata | id, name, description, ownerId, createdAt |
| `GroupMembership` / `group_memberships` | Membership, group role and read marker | id, groupId, userId, role, joinedAt, lastReadAt |
| `GroupMessage` / `group_messages` | Group text message | id, groupId, senderId, content, sentAt |

Password hashes are never intended to be returned to clients. The API uses `UserResponse` DTOs; the entity's password-hash property is also marked `@JsonIgnore` as defense in depth.

## Current model limitations

- Direct-message records remain one sender/one receiver; group chats use separate group tables rather than a unified conversation model.
- Message content has no type or attachment metadata.
- Replies, forwarding, reactions, per-user pins/stars, archive state and delete-for-me state are absent.
- Event start/end are `LocalTime` values with a separate `LocalDate`; no explicit time-zone policy is stored. Backend date queries use the server/database zone while Flutter reminders use the device zone, so these must be aligned operationally until an institution-approved zone-aware model is designed. Legacy `time` text remains for compatibility and historical rows may lack structured start/end values until edited.
- Timetable data supports both the existing HTTPS URL reference and structured weekly slots; controlled upload/storage is not implemented.
- Group read state is one per-member timestamp; per-message delivery receipts, message edits/deletes and pagination are absent.
- Message history and conversation queries do not yet expose pagination.

## Target domain model to design and migrate

- `users`, `roles`, and role assignments.
- A unified `conversations` model with `DIRECT` / `GROUP` type could replace the current separate direct-message and group tables if a future migration is approved.
- `conversation_members` with joined/left timestamps, archive state and last-read marker could generalize current group membership.
- `messages` linked to a conversation and authenticated sender.
- `message_attachments` for object-storage keys, media type, size and checksum.
- `message_reactions` keyed by message/user/reaction.
- `message_pins` and `message_stars` as per-user or conversation-level state, according to agreed product rules.
- `events` with owner, title, description, structured start/end date-time and an institution-approved time-zone policy.
- `timetables` or profile timetable metadata pointing to controlled storage, not arbitrary public URLs.
- `search_history` tied to the authenticated user.

This target is a design proposal, not implemented schema. The current Flyway V1 migration is for a new unified database and does not transform the old plaintext-password database.
