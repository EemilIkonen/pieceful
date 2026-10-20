# 0002: Baseline stack and tooling

**Status:** Accepted
**Date:** 2026-10-20

## Context
The stack and tooling were chosen during planning, before the ADR process existed. This ADR records those baseline decisions in one place, so that later changes can supersede them explicitly. Browser-side recognition is a separate decision: see [ADR 0003](0003-browser-side-recognition.md).

## Options
Alternatives were not compared in depth. The choices favour well-known, well-documented tools that a single developer can run locally and in CI.

## Decision
| Area | Choice |
|---|---|
| Backend | Django + Django REST Framework |
| Database | PostgreSQL, also used for the BrickLink price cache (TTL columns) |
| Frontend | React + TypeScript (Vite), installable PWA |
| API contract | OpenAPI schema generated from DRF; typed TypeScript client generated from it |
| Backend checks | pytest, ruff, mypy |
| Frontend checks | Vitest, ESLint + Prettier, TypeScript strict, Playwright E2E on a phone viewport |
| Shared | Docker Compose for local development, pre-commit hooks, GitHub Actions CI |

## Consequences
- One database service and no separate cache service for the MVP. Redis can be added later through a new ADR if the price cache needs it.
- The generated client keeps frontend and backend types in sync, at the cost of a generation step in the build.
- **Third-party load:** none directly. Caching of BrickLink calls is described in the [architecture](../architecture.md).
- **Privacy:** none directly.
- Exact versions and commands are set at M0 in [engineering conventions](../process/engineering.md).
