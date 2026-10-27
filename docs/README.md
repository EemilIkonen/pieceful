# Pieceful documentation

## Index
| Area | Document | Status |
|---|---|---|
| Product | [Requirements](product/requirements.md) | Draft |
| Product | [Feature specs](product/features/README.md) | Living |
| Product | [Pricing rules](product/pricing.md) | Draft |
| Product | [Target assignment](product/target-assignment.md) | Draft |
| Architecture | [Architecture](architecture.md) | Draft |
| Decisions | [Architecture Decision Records](decisions/README.md) | Living |
| Planning | [Roadmap](roadmap.md) | Draft |
| Planning | [Tasks](tasks/README.md) | Living |
| Process | [Engineering conventions](process/engineering.md) | Draft |
| Process | [Definition of Done](process/definition-of-done.md) | Draft |
| Process | [AI-assisted workflow](process/ai-workflow.md) | Draft |

## Status convention
Every document starts with a status line:
- **Draft:** being written; anything may change.
- **In review:** complete, waiting for approval.
- **Accepted:** settled. Changes go through a spec update or an ADR.
- **Living:** an index or log, updated continuously.

## Glossary
| Term | Meaning |
|---|---|
| **Part (design)** | A LEGO element design, identified by item type + item number (e.g. part `3001`, Brick 2 × 4). Color is not part of the identity |
| **Color** | A separate attribute of an item, using BrickLink color IDs |
| **Inventory key** | Item type + item number + color + condition: the unit that is priced and counted |
| **Minifigure (fig)** | An assembled figure; in BrickLink's catalog it is an item with its own part list |
| **CMF** | Collectible Minifigures. Each has both a fig entry and a set entry in the catalog |
| **Catalog item** | Any BrickLink catalog entry: part, minifig, set, … |
| **Scan** | One recognition of one item from an image or camera frame |
| **Candidate** | One of the ranked matches Brickognize returns for a scan |
| **Waitlist** | Scanned items waiting for review before they enter the inventory |
| **Inventory entry** | An owned item, identified by its inventory key, with quantity and notes |
| **Group** | A user-named collection of inventory entries |
| **Target** | A catalog item the user is completing (e.g. a minifig) |
| **Slot** | One required component of a target, filled by a part *or a whole item* (e.g. a fig filling a CMF set) |
| **Sold / listed price** | BrickLink price guide: average of sales in the last 6 months / of items currently for sale |
| **ADR** | Architecture Decision Record: a short document recording one decision and why |
