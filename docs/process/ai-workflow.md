# AI-assisted workflow

**Status:** Draft

This project is developed with [Claude Code](https://claude.com/claude-code). This guide explains how the pieces fit together.

> **If you only remember one thing: type `/next`.** It checks where things stand and proposes the next step.

## Cheat sheet
| You want to… | Type |
|---|---|
| Continue where you left off / not sure what to do | `/next` |
| Write down an idea without discussing it | `/idea <text>` |
| Turn an idea or feature into a buildable task | `/new-task` |
| Build a task | `/start-task M1-001` |
| Record a design decision | `/adr` |
| Check docs and code still agree | `/sync-docs` |
| Get a senior tech lead's critical review of the design | `/tech-review [scope]` |
| Wrap up a session | `/handoff` |

## The lifecycle
```mermaid
flowchart LR
  idea["/idea → inbox"] --> draft[draft in private backlog]
  draft --> spec["/new-task → docs/tasks/M?-xxx"]
  spec --> build["/start-task"]
  build --> review[design-reviewer agent + owner review]
  review --> commit[owner commits]
  commit --> handoff["/handoff → progress log"]
```

1. **Capture:** ideas go into a private inbox right away, with no discussion needed.
2. **Refine:** an idea becomes a draft, then a public task spec with scope, acceptance criteria, and a test plan. Claude asks about anything unclear.
3. **Build:** Claude reads the spec and linked docs, implements, tests, and runs the reviewer agent. Then it **stops** for review.
4. **Review & commit:** the owner reviews the diff. Claude commits only when asked.
5. **Handoff:** the progress log records what was done and what's next. The next session starts from there.

## From private notes to public docs
Things stay in the private notes while they're being thought through. They move to the public docs **just in time**, once they're decided and the next step needs them. Most ideas stay private until their turn comes, so the public docs only hold what is settled.

| Private (raw) | Becomes public when… | Goes to |
|---|---|---|
| Idea in the inbox | The owner decides it belongs in the product | A row in `requirements.md`, and a feature spec when it is next in line |
| Backlog draft | It is scheduled for a milestone and clear enough to build | A task spec in `docs/tasks/` (`/new-task`) |
| Research note or spike result | It settles a decision | An ADR, or a fact in `architecture.md` |
| Open question | The owner answers it | The spec or ADR it affects |
| Working plan, motivations | Never | Stay private; their decisions are already in the public docs |

**Why promote at all**, when Claude can read the private notes locally:
1. **Binding vs. brainstorming.** Public docs are decisions to follow. Private notes are background and possibilities (see the source-of-truth order in `AGENTS.md`).
2. **Visibility.** Readers of the repo see only public docs, and so do Claude sessions that run anywhere without the notes: the cloud, another machine, or a pull request review.
3. **Focus.** A clean spec is faster and less ambiguous to build from than raw notes.

Rule of thumb: **private while it's still being thought through; public once it's decided and ready to be built.**

## Where context lives
| Layer | Location | Contents |
|---|---|---|
| Public | `AGENTS.md`, `docs/` | Settled requirements, specs, architecture, ADRs, tasks |
| Private | separate notes repo, loaded through the gitignored `CLAUDE.local.md` | Raw ideas, drafts, research, session log |

### Without the private notes
The public repository is self-contained: every decision needed to build is in `docs/`. The notes add session state and a place for drafts. Without them, for example in a fresh clone or a cloud session:
- **Work as usual:** the docs, `AGENTS.md`, the `design-reviewer` and `tech-lead` agents, `/adr`, `/sync-docs`, `/start-task`, and `/new-task` from a feature spec.
- **Need the notes:** `/next` and `/handoff` (progress log), `/idea` (inbox), and `/tech-review` (it saves its report there).
- The SessionStart hook prints a hint to start from `AGENTS.md` and `docs/README.md` instead.

## Building blocks
- **Skills** (`.claude/skills/`): the slash commands above. Each is a short instruction file.
- **Agents** (`.claude/agents/`): read-only reviewers that start with a fresh context, so they judge the work as written.
  - `design-reviewer` checks a **code change** against the task spec, ADRs, conventions, and the [Definition of Done](definition-of-done.md). `/start-task` runs it.
  - `tech-lead` is a senior tech lead who critically reviews **design docs and plans**: gaps, contradictions, risky assumptions, MVP path. `/tech-review` runs it, ideally at every phase checkpoint before approval.
- **Hooks** (`.claude/settings.json`):
  - **SessionStart** (active): prints the current state from the progress log when a session starts.
  - **Quality gates** (planned for M0): run format/lint after edits and tests before Claude finishes.

## Good habits
- Start a **new session per task**. It keeps the context focused, and the progress log carries state over.
- Review the diff, not just the summary.
- If Claude starts deciding design questions on its own, point it to the working rules in `AGENTS.md`.
