# Security policy

## Current status

The unified candidate contains a first security-remediation pass: BCrypt credential hashing, stateless JWT authentication, DTO-based user responses, authenticated routes, role-protected admin APIs, owner checks, environment-supplied secrets and a disabled-by-default H2 console. This is based on static source inspection only; it has not been penetration-tested or verified by automated integration tests. It is not yet approved for production or real faculty data.

See [docs/SECURITY_AUDIT.md](docs/SECURITY_AUDIT.md) for remaining blockers and release gates.

## Reporting a vulnerability

Please do not publish credentials, tokens, personal data, or a working exploit in a public issue. Contact the repository maintainer privately through the GitHub profile contact method and include:

- A concise description of the issue.
- Affected component and source path.
- Preconditions and reproducible steps using test data only.
- Potential impact and, where possible, a suggested mitigation.

Do not test against a live university system or real faculty accounts without explicit authorization.

## Secret handling

- Keep local `.env` files out of Git; `.env.example` files contain placeholders only.
- Never commit Firebase service-account JSON, database passwords, JWT signing secrets, private keys, Android signing keystores or release credentials.
- Treat previously committed signing keys as exposed and rotate/reissue release signing material where applicable.
- Firebase client configuration is not a substitute for Firestore/Storage security rules.
