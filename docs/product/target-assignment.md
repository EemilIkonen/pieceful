# Target assignment

**Status:** Draft

How scanned parts are suggested toward the minifigures (and later sets) they complete.

## Composition model (decided)
- A **target** is any catalog item with a part list: a minifigure first, later CMF sets and sets.
- A target has **slots**: its required components, each with color and quantity.
- A slot can be filled by a part **or by a whole item**. Example: an assembled minifig fills the fig slot of its CMF set.

## Auto-assignment (decided)
When a part is scanned, the app finds the targets that contain it and pre-selects one:
1. **Closest to completion:** a target the user has already started (most slots filled / highest % complete).
2. Otherwise, **highest completed value:** the target worth most when complete.

The strategy is a user setting. The suggestion is shown on the scan result and can be changed there.

## To be specified
- Tie-breaks; what "started" means exactly.
- Edge cases: color-specific slots, quantity > 1, a part that fits several slots of the same target, reassignment.
- How groups relate to targets (open design question).
