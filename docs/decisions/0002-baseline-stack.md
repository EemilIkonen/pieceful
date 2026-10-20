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

## Addendum (2026-10-20): alternatives considered during planning
This records the planning-time reasoning. The decision above is unchanged.
- **Browser-only app with no server:** rejected. The BrickLink API sends no CORS headers and needs OAuth 1.0a with IP-bound tokens, so it can't be called from a browser and its credentials must stay server-side.
- **FastAPI instead of Django:** Django + DRF chosen for the maintainer's existing Django experience, the built-in admin, and its mature auth ecosystem.
- **Django templates + HTMX instead of React:** React chosen because the camera and live-scan UI is highly interactive, and it keeps a path open to a React Native app.
- **Next.js:** rejected. It would add a second (Node) server next to Django for no MVP benefit.
- **Redis for the price cache:** deferred. A PostgreSQL table with TTL columns is enough for the MVP.
