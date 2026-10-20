# Requirements

**Status:** Draft

## Problem
LEGO parts and minifigure pieces are hard to identify and price by hand. Collectors sorting loose parts want to know what each piece is, what it's worth, and which minifigures it could complete, without searching catalogs item by item.

## Users
- **Collector:** sorts loose parts and minifigures, wants identification and value at a glance, and wants to complete figures.
- **Seller:** wants quick price checks before listing. Selling workflows themselves are out of scope.

## Design principles
- **Easy and fast UX over fancy UI.** The fewest possible taps from scan to price, immediate feedback, and clear results. Visual polish never slows down the core flow.

## Release stages
1. **Local MVP increments:** development builds, adding features one at a time.
2. **Closed alpha 1:** deployed, used by the owner only. Requires accounts and hosting.
3. **Closed alpha 2:** opened to a small invited group. Requires a legal and privacy review first.
4. **Public:** open to anyone.

## Features
Each feature gets a spec in [`features/`](features/README.md). The order of milestones is set in the [roadmap](../roadmap.md).

| ID | Feature | Notes |
|---|---|---|
| F-01 | Image upload → price card | First MVP increment |
| F-02 | Manual capture ("Take image"), phone camera and desktop webcam | Camera picker |
| F-03 | Live scan (automatic) | Recognizes items from the camera feed without button presses, sending a frame only for a new, steady object. Feasibility: spike S-01 |
| F-04 | Several parts per photo | Each part in one photo is recognized and priced separately. Approach set by spike S-02 |
| F-05 | Match correction | Swap candidate, rescan, color chips, feedback to Brickognize |
| F-06 | Pricing | See [pricing rules](pricing.md) |
| F-07 | Waitlist | Review, bulk-edit condition/quantity, target shown inline |
| F-08 | Inventory | Condition, quantity, notes; sort and group |
| F-09 | Groups | User-named collections (design open) |
| F-10 | Minifigure targets and auto-assignment | See [target assignment](target-assignment.md) |
| F-11 | Export | Versioned JSON; BrickLink wanted-list XML of missing parts |
| F-12 | Settings | Region, currency, VAT, headline price, default condition |
| F-13 | Accounts | Email + password, Google sign-in; required from closed alpha 1 |

## Non-functional requirements
| ID | Requirement |
|---|---|
| NFR-01 | **Responsive and mobile-first:** fully usable on a phone, and on desktop with a webcam |
| NFR-02 | **Fast feedback:** the price is visible within 3 s at p95 on a 4G connection; a price-cache hit responds within 300 ms |
| NFR-03 | **No user images on the server:** images go from the browser straight to Brickognize |
| NFR-04 | **Third-party load:** Brickognize and BrickLink calls are cached, deduplicated, and throttled |
| NFR-05 | **API keys stay secret:** BrickLink credentials exist only on the backend |
| NFR-06 | **Data portability:** users can export all their data |
| NFR-07 | **Quality baseline:** automated tests, linting, and type checks in CI from the first commit of code |
| NFR-08 | **Supported browsers:** current iOS Safari and Android Chrome, and current desktop browsers (versions set in the architecture doc before M0) |
| NFR-09 | **Accessibility:** WCAG 2.2 AA (scope set in the architecture doc before M0) |
| NFR-10 | **Security baseline:** authentication method for the PWA and CSRF protection (set in the architecture doc before M0) |
| NFR-11 | **Observability:** errors and third-party call volumes are visible (set in the architecture doc before M0) |

## Out of scope (for now)
Selling and store management, set completion, imports from other services, offline scanning, native apps. These are tracked in the roadmap backlog.
