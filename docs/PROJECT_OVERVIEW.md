# Project overview

## Problem

Faculty coordination can be fragmented across direct messages, email, informal status checks, timetable links and separate calendars. V-COMM is intended to consolidate common faculty coordination tasks into one faculty-focused application.

## Users

The intended primary users are faculty members. Administrative users provision accounts and manage campus-level access. Student-facing access is outside the current prototype scope unless the team later agrees to expand it.

## Product areas

1. **Identity and profile:** sign-in, profile information, contact details and timetable reference.
2. **Faculty directory:** search by faculty information, inspect a profile and start a conversation.
3. **Availability:** let a faculty member set a visible Present, Absent, Available, Busy or In Class label.
4. **Scheduling:** maintain dated events with descriptions, local start/end times, visibility and reminder metadata, and browse weekly timetable slots alongside the calendar/dashboard.
5. **Communication:** direct and group text messages are implemented in the active source with server-side membership checks and polling-based refresh; rich message actions remain outside the active scope.
6. **Administration:** a protected faculty-provisioning API exists; an integrated admin UI and audit workflow remain planned.

## Design principles

- Faculty-focused rather than a general-purpose social network.
- Minimize fragmented workflows by bringing directory, status, schedule and communication together.
- Protect personal data through server-enforced access controls.
- Maintain separation between Flutter UI, REST APIs, business services and persistence.
- Document exact implementation status; do not equate a design/presentation claim with a working feature.

## Scope boundary

The current active source is a prototype/migration candidate. The current local migration changes add group messaging, structured timetable slots, event details and reminders, token revocation and configurable domain restrictions. Those changes have not been built, tested or verified against a deployed database/API. Do not use real faculty data until the remaining security and verification gates are closed.
