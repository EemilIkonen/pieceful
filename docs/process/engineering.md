# Engineering conventions

**Status:** Draft (to be completed at M0)

## Repository layout (planned)
```
backend/     Django project + DRF apps
frontend/    React + TypeScript (Vite) PWA
docs/        documentation
.claude/     AI workflow: skills, agents, hooks
```

## Tooling (decided, see [ADR 0002](../decisions/0002-baseline-stack.md))
| Area | Backend | Frontend |
|---|---|---|
| Tests | pytest | Vitest; Playwright E2E on a phone viewport |
| Lint / format | ruff | ESLint + Prettier |
| Types | mypy | TypeScript strict |
| API contract | OpenAPI schema from DRF | Generated typed client |

Shared tooling: pre-commit hooks, GitHub Actions CI running all checks, Docker Compose for local development.

## Testing third-party calls
- Tests and CI never call live Brickognize or BrickLink. BrickLink tokens are IP-bound, so CI could not call it anyway.
- Backend tests use recorded fixtures (`responses` or `vcrpy`); frontend tests use MSW.
- A contract test pins the Brickognize response shape, so a change in that API fails loudly.

## Secrets
- Secrets live in a local `.env` file, which is gitignored. A committed `.env.example` lists the variable names with no values.
- BrickLink credentials exist only on the backend.

## Git
- Commit to `main` while the project is solo.
- Small commits using [Conventional Commits](https://www.conventionalcommits.org) (`type(scope): summary`; types: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`, `ci`), with a body stating why when it isn't obvious.
- Every change is reviewed by the owner before it is committed.

## To be specified at M0
Exact versions, commands, Django app layout, frontend folder structure, coding style details.
