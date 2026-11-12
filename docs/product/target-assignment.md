# Target assignment

**Status:** Draft

The rules for targets, allocations, and the suggestion that points a scanned part at the minifigure (and later set) it helps complete. The screens and flows are in [F-10](features/F-10-minifigure-targets.md).

## Composition model (decided)
- A **target** is any catalog item with a part list: a minifigure first, later collectible series and sets.
- A target has **slots**: its required components, each with an item, a color, and a quantity. The slots are read from the catalog part list; they are not stored with the target.
- A slot can be filled by a part **or by a whole item**. Example: an assembled minifigure fills the figure slot of its collectible series.
- A target has a status: **in progress**, **complete** (every slot filled), or **built** (the user has assembled it, see [F-10](features/F-10-minifigure-targets.md#mark-as-built)).

## Allocation (decided)
- The inventory ([F-08](features/F-08-inventory.md)) is one pool. An entry's quantity is the total owned.
- An **allocation** assigns a quantity of one inventory entry to one slot of one target. It is stored with the entry, the target, the slot (item and color), and the quantity.
- An entry's **free** quantity is its quantity minus its allocations. Free pieces are not used by any target.
- A target's **progress** counts allocations only: the allocated pieces out of the pieces needed, with each slot capped at its quantity.
- An allocation never exceeds the slot's remaining need or the entry's free quantity, and a slot is filled only by an entry of the **same item and the same color**.
- Groups (F-09) are separate from targets and do not affect allocation.

## Auto-assignment (decided)
When a part is scanned, the app suggests one target for it. The suggestion is shown on the waitlist entry ([F-07](features/F-07-waitlist.md)) and can be changed or cleared there.

**Candidates.** An **in-progress** target is a candidate when it has a slot with the same item and the same color that is not yet full, counting the pieces that other waitlist entries are already suggested for as if they were allocated. A part with no color set is never suggested.

**Choosing.** The strategy is a user setting (F-12). The default is:
1. **Closest to completion:** among candidates the user has started, the one with the highest share of its needed pieces allocated. A target is **started** when at least one piece is allocated to it.
2. Otherwise, the candidate with the **highest completed value**.
3. Remaining ties go to the target created first.

**Value.** The completed value of a target is the price of the target's own catalog item (the figure, not the sum of its parts), for the condition set in Settings. It costs one price lookup per candidate target, through the shared price cache. A target whose price is unavailable ranks last on value.

**Quantity.** An entry with quantity above 1 is suggested to one target for at most that target's remaining need. The rest of the quantity stays free; it is not split across several targets.

**Not in the first version.** Alternate parts that the catalog lists for a slot are ignored: only the listed part itself fills a slot.

## Still to be specified
- Collectible series and set targets (same model, later increment).
- Alternate parts, if they turn out to matter in practice.
