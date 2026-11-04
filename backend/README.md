# Spring Boot backend

Java 21 · Spring Boot 3.5.16 · Spring Security · Spring Data JPA · Flyway.

## Run locally

Set `JWT_SECRET` to a random value of at least 32 UTF-8 bytes. To bootstrap the first administrator, also set `VCOMM_ADMIN_EMAIL` and `VCOMM_ADMIN_PASSWORD` (at least 14 characters). Then run:

```bash
mvn spring-boot:run
```

The API listens on `http://localhost:8080/api`. Local default persistence is in-memory H2 and resets when the service stops. Set `DB_URL`, `DB_DRIVER`, `DB_USERNAME` and `DB_PASSWORD` to use MySQL. Never commit real values.

See `../README.md`, `../docs/API_CURRENT.md` and `../docs/SECURITY_AUDIT.md` for setup, routes and known limitations.

## Verification

```bash
mvn test
```

The build and test command has not yet been run in the preparation environment because Maven is not installed there.
