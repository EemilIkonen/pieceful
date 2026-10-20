# Feature specs

**Status:** Living

One file per feature: `F-xx-short-name.md`, using the template below. Features are listed in [requirements](../requirements.md). Specs describe **what and why**. The **how** goes to the [architecture](../../architecture.md), and buildable slices go to [tasks](../../tasks/README.md).

| ID | Spec | Status |
|---|---|---|
| F-01 | Image upload → price card | not written |
| F-02 | Manual capture | not written |
| F-03 | Live scan | not written |
| F-04 | Several parts per photo | not written |
| F-05 | Match correction | not written |
| F-06 | Pricing | see [pricing rules](../pricing.md) |
| F-07 | Waitlist | not written |
| F-08 | Inventory | not written |
| F-09 | Groups | not written |
| F-10 | Minifigure targets | see [target assignment](../target-assignment.md) |
| F-11 | Export | not written |
| F-12 | Settings | not written |
| F-13 | Accounts | not written |

## Template
```markdown
# F-xx: <name>
**Status:** Draft

## Goal
What the user achieves and why it matters.

## User stories
- As a <user>, I want <action> so that <outcome>.

## Behavior
Step-by-step flow, states, and edge cases. Phone-sized sketch if UI.

## Acceptance criteria
- [ ] Testable statement…

## Third-party load
Which external calls this causes, and how they are cached, deduplicated, or throttled.

## Out of scope
## Open questions
```
