# Contributing to V-COMM

Thanks for helping improve V-COMM. This is a collaborative project; preserve the existing team attribution and discuss substantial architectural changes before implementation.

## Development workflow

1. Read the current feature matrix and migration plan before changing a module.
2. Create a focused branch from the latest `main` branch.
3. Keep changes scoped to one feature or fix where practical.
4. Add or update tests for behavior changes.
5. Run Flutter analysis/tests and Maven tests locally.
6. Update documentation when API contracts, configuration, or behavior changes.
7. Open a pull request with the problem, implementation summary, verification steps and any known limitations.

## Commit messages

Use clear, action-oriented messages, for example:

- `feat(chat): add group conversation API`
- `fix(auth): hash passwords before persistence`
- `test(events): cover date filtering`
- `docs(setup): clarify Android emulator API URL`

## Code expectations

- Never commit API keys, database credentials, signing keys, Firebase service accounts, tokens or user data.
- Never return a JPA entity that contains a password or another sensitive field directly from an API.
- Derive the acting user from the authenticated server-side principal; never trust a sender/user ID supplied by the client as proof of identity.
- Validate request bodies and enforce authorization at the service/API boundary.
- Keep network, storage and business logic out of Flutter widgets where practical.
- Mark features as implemented only after the relevant code and tests support the claim.

## Before opening a pull request

```bash
cd mobile && flutter analyze && flutter test
cd ../backend && mvn test
```

If a toolchain or external service is unavailable, state that clearly in the pull request instead of claiming the check passed.
