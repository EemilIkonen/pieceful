# Pieceful

Pieceful is a web app (installable PWA, phone and desktop) that recognizes LEGO® parts and minifigures with the [Brickognize](https://brickognize.com) API and shows their [BrickLink](https://www.bricklink.com) price right after each scan. Input modes: image upload, manual "Take image", and automatic "Live scan". Stack: Django + DRF backend, React + TypeScript frontend, Docker.

**Status:** design phase. No application code yet.

## Read order (every session)
1. `CLAUDE.local.md`, if present: private notes and the **current state / next step**.
2. The task spec you were given (`docs/tasks/M?-xxx-*.md`), or run `/next` if none.
3. The docs, ADRs, and feature specs the task links to. Don't read everything.

## Repo map
| Path | What |
|---|---|
| `docs/README.md` | Index of all docs, the status convention, and the glossary |
| `docs/product/` | Requirements and feature specs (`features/F-xx-*.md`), domain specs (pricing, target assignment) |
| `docs/architecture.md` | System design |
| `docs/decisions/` | ADRs: settled decisions and why |
| `docs/roadmap.md` | Release stages and milestones |
| `docs/tasks/` | Refined, buildable task specs (IDs per milestone: `M1-001`) |
| `docs/process/` | Engineering conventions, Definition of Done, the AI workflow guide |
| `.claude/` | Project skills (`/next`, `/idea`, …), review agents (`design-reviewer`, `tech-lead`), hooks |
| `backend/`, `frontend/` | Created at M0 |

## Commands
Defined at M0 (install / run / test / lint).

## Working rules
- **Never commit or push without the owner's review.** After changes, summarize them and stop. Commit only when asked. Commits go to `main` and use [Conventional Commits](https://www.conventionalcommits.org) (`docs: add F-01 spec`, `feat(pricing): cache price guide`). **No `Co-Authored-By` lines.**
- **No destructive actions without asking:** don't delete files or data, rewrite git history, or force-push.
- **Secrets never appear** in files, docs, chat, or commits. Only variable names go in `.env.example`.
- **Verify, don't guess.** Facts about external APIs, limits, terms, or library behavior need a source. Otherwise mark them **To verify**.
- **Source of truth:** accepted ADRs > public docs > private plan and notes. When they disagree, flag it and ask; don't pick one silently.
- **The owner is the architect.** Don't make design decisions silently. Ask with options, trade-offs, and a recommendation. At checkpoints, give a **summary + questions in chat**.
- **Public docs are settled content.** Change them only on purpose, through a spec update or an ADR, and say so first. Raw ideas, drafts, and personal context belong in the private notes (see `CLAUDE.local.md`), never in this repo.
- Public docs use a neutral, professional voice, in English.
- Stay inside the task's scope. Write unrelated findings to the idea inbox (`/idea`) instead of fixing them.
- **Be a good API citizen:** any change that calls Brickognize or BrickLink must say how the load is cached, deduplicated, or throttled.
- User images never go to our backend. Brickognize is called from the browser.
- **New dependencies need the owner's OK.** Adding a library or service needs approval first, and an ADR if it's significant.
- **Tests never call live Brickognize or BrickLink.** Use recorded fixtures (see `docs/process/engineering.md`).
- Follow `docs/process/engineering.md`. Finish every task with `docs/process/definition-of-done.md`.

## Habits
- **At the start of a session**, before anything else, give a short situation report (2–4 lines): current phase, what's next, open blockers. Use the SessionStart output / progress log.
- **Explain new concepts:** when introducing a tool, pattern, or technique the owner may not know, add a 1–2 line explanation.
- When the owner mentions a new idea in passing, offer to capture it with `/idea`.
- Before ending a session that changed anything, offer `/handoff`.
- Unsure what to do next? `/next`.
