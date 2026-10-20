# Architecture Decision Records

**Status:** Living

An ADR records **one** significant decision: the context, the options considered, the choice, and its consequences. ADRs are never rewritten after acceptance. A changed decision gets a new ADR that supersedes the old one. Clarifications that don't change the decision may be appended as a dated **Addendum**.

## Index
| # | Decision | Status |
|---|---|---|
| [0001](0001-license.md) | License: PolyForm Noncommercial 1.0.0 | Accepted |
| [0002](0002-baseline-stack.md) | Baseline stack and tooling | Accepted |
| [0003](0003-browser-side-recognition.md) | Recognition is called from the browser | Accepted |

## Lifecycle
1. **Proposed:** drafted with `/adr` from [the template](0000-template.md). Open questions go to the owner.
2. **Accepted:** the owner approves it. Linked docs are updated in the same change.
3. **Superseded by NNNN:** replaced by a later ADR; kept for history.

## When to write one
- Choosing or replacing a technology, library, or external service.
- Anything that changes the data model, the API contract, or security.
- Anything that adds load on a third-party service.
- Anything that is hard to reverse.

## Design review checklist
Use this for every ADR and for design-relevant tasks.
- [ ] Does it match the requirements and the feature spec it serves?
- [ ] **Third-party load:** what calls to Brickognize or BrickLink does it cause, and how are they cached, deduplicated, or throttled?
- [ ] **Privacy:** what user data does it touch? User images must stay off the server.
- [ ] **Security:** are secrets server-side? Is auth and permission per user?
- [ ] **Mobile-first:** does it work on a phone and with a desktop webcam?
- [ ] **Testability:** how is it tested?
- [ ] **Reversibility:** what would it cost to undo?
- [ ] **Risky assumptions:** do they need a spike (a small throwaway experiment) first?
