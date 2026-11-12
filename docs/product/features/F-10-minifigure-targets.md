# F-10: Minifigure targets
**Status:** Draft

## Goal
The user picks minifigures they want to build. The app shows how close each one is, points scanned parts at the figure they help complete, lists what is still missing, and, when a figure is complete, turns its parts into a finished minifigure in the inventory. The rules behind this are in [target assignment](../target-assignment.md); this spec covers what the user sees and does.

## User stories
- As a collector, I want to track the minifigures I want to build, so that I can see my progress on each.
- As a collector, I want a scanned part to be suggested toward the figure it helps complete, so that sorting a pile also advances my builds.
- As a collector, I want to change that suggestion, so that I decide which figure gets the part.
- As a collector, I want to use pieces I already own when I start a target, so that I don't have to rescan them.
- As a collector, I want to see which parts a figure still needs, so that I know what to look for or buy.
- As a collector, I want to mark a figure as built, so that my inventory matches what is on my shelf.

## Behavior

### Targets
A target is a minifigure the user wants to build. Each has a status: **in progress**, **complete** (every part allocated), or **built**. This version covers **minifigures only**; collectible series and sets use the same model in a later increment (see [Out of scope](#out-of-scope)).

- At most one in-progress target exists per minifigure. To build two copies, finish one and add the figure again.
- A target keeps the figure (item type and number), its status, and when it was created and built. Its part list is read from the catalog when needed and is not stored with the target.
- Targets are owned by a user from the start, with client-created IDs and write requests that are safe to repeat, as for the waitlist (F-07).

### Adding a target
Two ways, both for minifigures:
1. **By item number:** the user enters a BrickLink minifigure number (for example `sw0001`). The backend checks it against the BrickLink catalog, as in [item number entry](F-05-match-correction.md#item-number-entry). Not found: "BrickLink has no minifigure with number <no>."
2. **From a scan:** when a scan result is a minifigure, "Track this" on its price card adds it as a target.

If the figure is already an in-progress target, the app says so and opens it.

After adding, the app offers **"Use pieces you already own"**: it lists the free pieces in the inventory that match the figure's parts exactly (same item, same color), up to what the figure needs, and the user confirms or skips. Confirming creates the allocations.

### The target list
Each row shows the figure's name and thumbnail, its status, and its progress ("4 of 6 parts"). The list can be sorted by progress or by date added; there is no price and no sort by price. Targets are shown in three groups: in progress, complete, and built.

### Target detail
- A list of the figure's parts, each with thumbnail, name, color, the quantity needed, and the quantity allocated. Missing parts are highlighted.
- **Allocate** on a missing part: pick from the free inventory entries that match (same item and color). The allocation is the smaller of the free quantity and the remaining need.
- **Release** on an allocated part: the pieces become free again. Releasing and allocating to another target moves them.
- A **missing parts** list for the figure, which export (F-11) uses.
- **Mark as built** when the target is complete.
- **Delete target:** removes the target and releases its allocations, with a short undo.

### Suggestions on the waitlist
When a part is scanned, the waitlist entry (F-07) gets a **suggested target** by the rules in [target assignment](../target-assignment.md#auto-assignment-decided): only in-progress targets that still need that part in that color, the closest-to-completion target first, then the highest completed value.
- The row shows "Fits: <figure>" and its progress ("3 of 6").
- The user can change the suggestion to any in-progress target that still needs the piece, or clear it. The row records whether the target was suggested or chosen by the user.
- Pieces already suggested for a target by other waitlist entries count as filled, so two scanned copies of a part that a target needs once are not both suggested to it.
- A part with no color set gets no suggestion.
- A suggestion changes nothing in the inventory by itself.

### Allocation when adding to the inventory
When waitlist entries are added to the inventory (F-07), each entry that has a target creates an allocation for that target, for the smaller of its quantity and the target's remaining need. If the need has been met in the meantime, the rest stays free, and the summary says how many pieces stayed free.

### Effects on the inventory
- **Reducing a quantity** below the allocated amount, or **deleting an entry**, releases the allocations that no longer fit (the most recent first). The app shows which targets are affected before the change is applied.
- **Changing an entry's item** (F-08) releases its allocations, with the same preview.
- **Merging** two entries (F-08) moves their allocations to the surviving entry.
- Condition and notes do not affect allocations.
- Free and allocated quantities are shown on the inventory entry ("3 allocated").

### Mark as built
Available when a target is complete.
1. The app shows what will happen: the allocated pieces leave the inventory, and the minifigure is added to it.
2. The user confirms the figure's condition. The default is **Used** if any consumed piece is Used, and **New** if all of them are New.
3. The allocated quantities are removed from their entries. An entry left with no pieces is removed.
4. The minifigure is added as an inventory entry (quantity 1; if the inventory already has that figure in that condition, its quantity increases).
5. The target becomes **built** and stays in the list as history, with its built date.
6. A short undo restores the pieces, removes the figure, and reopens the target. After the undo expires, reversing a build is done by hand.

The operation is all or nothing and safe to repeat.

### Prices
Targets show **no prices**. The only price used is the figure's own price, to rank candidates when a part is scanned ([target assignment](../target-assignment.md#auto-assignment-decided)), and it is not shown on the target screens.

### Saving
Saved on the server, change by change, as for the waitlist (F-07). A failed save marks the row "Not saved" with a retry, and leaving the page with an unsaved change shows a warning.

### States and edge cases
| State | Trigger | Shown |
|---|---|---|
| No targets | The user tracks nothing | "Pick a minifigure to build." with "Add by item number" |
| Figure not found | Item number entry, BrickLink has no such figure | "BrickLink has no minifigure with number <no>." Input kept |
| Already tracked | The figure is an in-progress target | "Already tracking this figure." The target opens |
| Part list loading | Target opened, list not cached | A loading indicator; the target's status and progress still show |
| Part list unavailable | BrickLink error or quota exhausted, nothing cached | "The part list can't be loaded right now." Allocations are kept; no suggestions for this target until it loads |
| Nothing to use | "Use pieces you already own", no free matching pieces | "No free matching pieces." Skip |
| Part already full | Allocate on a part whose need is met | Not offered; the part shows as complete |
| Not enough free | The chosen entry has fewer free pieces than needed | The smaller quantity is allocated, and the part stays missing |
| Release affects targets | A quantity reduction or delete would release allocations | The affected targets are listed before the change is applied |
| Build failed | "Mark as built" could not be saved | A message; nothing changes |
| Not saved | A change could not be saved | The row is marked "Not saved" with a retry; leaving warns |

## Acceptance criteria
- [ ] A minifigure can be added as a target by item number and from a scan result; an unknown number shows the not-found message and creates nothing.
- [ ] Adding a figure that is already an in-progress target opens that target instead of creating a second one.
- [ ] "Use pieces you already own" lists only free pieces with the same item and color, and confirming creates allocations that never exceed the figure's need or the entry's free quantity.
- [ ] A target's progress counts only allocations, with each part capped at the quantity needed.
- [ ] A scanned part with a color is suggested to a target only if that target has a part with the same item and color that is not yet full; a part with no color gets no suggestion.
- [ ] The suggestion follows the closest-to-completion then highest-value rule, with ties going to the older target, and counts other waitlist entries' pending suggestions as filled.
- [ ] The suggestion can be changed to any in-progress target that still needs the piece, or cleared, and the choice is recorded as suggested or chosen by the user.
- [ ] Adding entries to the inventory creates allocations for their targets, never more than the remaining need, and reports pieces that stayed free.
- [ ] Reducing a quantity below its allocated amount, or deleting an entry, shows the affected targets first and releases the allocations that no longer fit.
- [ ] Changing an entry's item releases its allocations after a preview; merging two entries moves their allocations.
- [ ] "Mark as built" is offered only for a complete target, removes the allocated quantities, adds the minifigure with the confirmed condition, marks the target built, and can be undone for a short time.
- [ ] "Mark as built" changes nothing if it fails and has no further effect when repeated.
- [ ] No price is shown on the target screens, and none is stored.
- [ ] Opening a target with a cached part list makes no BrickLink call.
- [ ] All tests use recorded fixtures; none call Brickognize or BrickLink.

## Third-party load
- **Brickognize:** none.
- **BrickLink, part lists:** one catalog call per target part list, cached on the server and shared across users, with one fetch per key. A scan needs the part lists of all in-progress targets to find the ones that need the piece, so the number of calls grows with the number of targets, once per cache lifetime. Part lists load lazily and identical requests are merged.
- **BrickLink, prices:** the figure's own price, only to rank candidate targets that tie on progress, through the shared price cache. One lookup per candidate target, none on a cache hit.
- **BrickLink, catalog:** one item lookup per item number entered, as in F-05.
- See the [BrickLink usage budget](../../architecture.md#bricklink-usage-budget), which gains the part-list calls when this feature is built.

## Out of scope
- Collectible series and set targets, and a figure filling a slot of a series. The data model already allows it (a slot is filled by a part or a whole item), and a built figure is a regular inventory entry that can fill such a slot later.
- Suggesting figures for a scanned part ("this part is in 12 minifigures"). It needs an extra BrickLink lookup per scanned part.
- Alternate parts that the catalog lists for a slot.
- More than one in-progress target for the same figure, and a target priority order or pinning.
- Filing targets in groups (F-09), a collection or target value, and price history.
- Export of the missing parts (F-11).
- Settings for the suggestion strategy (F-12).

## Open questions
- **Part list shape (to verify in spike S-00):** how BrickLink lists the parts of a minifigure (torso, legs, and head assemblies versus single parts), and whether that matches what recognition returns for a scanned part. If it does not, parts of an assembly would never match a slot.
- **Storage limits for part lists and names.** The part list and figure name come from BrickLink, whose API terms limit how long such data may be stored. This spec reads them from the catalog cache and stores only item numbers, colors, and quantities. The cache lifetime is set with the BrickLink freshness rules, and a short lifetime means more catalog calls and no suggestions while BrickLink is unavailable.
- **Alternate parts.** Whether ignoring them leaves too many figures unfinishable in practice.
- **Two copies of one figure.** Whether one in-progress target per figure is too limiting.
- **Reversing a build** after the undo has expired.
