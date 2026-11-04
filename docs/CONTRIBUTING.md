# Contributing

V-COMM is a three-member university group project. Contributions and project history should be represented accurately; do not remove or rewrite another member's authorship.

## Development expectations

- Work on a feature branch and open a pull request for review.
- Keep changes focused and explain the reason for the change.
- Add or update tests for behavior changes.
- Update the relevant README/API/architecture documentation.
- Never commit secrets, credentials, private data, signing keys, or generated build output.
- Do not claim a feature works until it has been tested against the current code.

## Suggested commit format

`type(area): concise description`

Examples: `feat(chat): add group membership endpoint`, `fix(auth): hash passwords`, `docs(setup): clarify local database configuration`.

## Before requesting review

- Run the relevant formatter, static analysis and tests.
- Check `git diff` for unrelated changes and accidental secrets.
- Include test results and known limitations in the pull request description.
