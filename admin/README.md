# Admin interface

This directory is reserved for a web-based administrative interface integrated with the Spring Boot backend.

**Not yet migrated:** the legacy Firebase-connected admin page is not included here, and this directory is not a working admin portal.

The intended interface must:

- Authenticate administrators through the backend.
- Rely on server-side role checks for every privileged operation.
- Use backend APIs rather than writing directly to Firebase.
- Validate manual and CSV-based account operations on the server.
- Provide safe error reporting and audit sensitive administrative actions.

Do not treat client-side hidden controls as a security boundary.
