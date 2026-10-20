# Definition of Done

**Status:** Draft

A task is done when all of these hold.

## Always
- [ ] Every acceptance criterion in the task spec is met.
- [ ] Nothing outside the task's scope was changed. Unrelated findings were captured as ideas.
- [ ] Docs, feature specs, and ADRs affected by the change are updated. A changed decision has a new ADR.
- [ ] The task status and board in `docs/tasks/` are updated.
- [ ] The design reviewer agent found no unresolved issues.
- [ ] The owner has reviewed the change before it is committed.

## For code (from M0)
- [ ] Tests added or updated, and all tests pass.
- [ ] Lint, format, and type checks are clean.
- [ ] CI is green.
- [ ] New third-party calls are cached, deduplicated, or throttled, as described in the task.
- [ ] UI works on a phone viewport and on desktop.
