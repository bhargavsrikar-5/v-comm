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

The consolidated implementation is merged into `main`. GitHub Actions Run #9 passed the configured backend tests, Flutter analysis/tests, Android debug build, and iOS simulator build on PR #2's head commit. CI success does not establish a production deployment, physical-device walkthrough, complete end-to-end verification, or penetration-test result. Do not use real faculty data until the remaining security and operational verification gates are closed.
