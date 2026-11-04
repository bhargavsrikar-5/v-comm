# Admin interface status

The active backend provides a role-protected faculty provisioning API at `POST /api/admin/users` and a list endpoint at `GET /api/admin/users`. These routes require a JWT whose account has the `ADMIN` role.

There is **no integrated admin web application** in this candidate. The old `ADMIN/index.html` page from the Firebase generation is not compatible with the Spring Boot/MySQL backend and is intentionally not copied into the active `admin/` directory. Rebuild the admin experience against the protected API; do not reconnect the legacy Firebase panel or put privileged credentials in browser code.

The first administrator is provisioned at backend startup only when `VCOMM_ADMIN_EMAIL` and `VCOMM_ADMIN_PASSWORD` are configured. See the root README and `docs/API_CURRENT.md`.
