# F-07: Waitlist
**Status:** Draft

## Goal
Every scan lands in a list the user can review before anything reaches the inventory. The user fixes mistakes, sets condition and quantity for many items at once, sees what the pile is worth, and then adds the good entries to the inventory (F-08) in one step. Scanning stays fast because nothing has to be decided at scan time.

## User stories
- As a user, I want each scan to appear in a list right away, so that I can keep scanning without stopping to save.
- As a user, I want to correct a wrong match from the list, so that a mistake never reaches my inventory.
- As a user, I want to set condition and quantity for many entries at once, so that sorting a pile is quick.
- As a user, I want to see a price per entry and a total, so that I know what the pile is worth.
- As a user, I want my waitlist to be there when I come back, on my phone or on my computer.
- As a user, I want to add selected entries or all of them to my inventory in one step.

## Behavior

### One waitlist per user
Each user has one waitlist. It is a staging area: entries stay there until the user adds them to the inventory or deletes them. There are no separate scan sessions.

### Entries
- A scan with a match is added to the waitlist automatically, as its own entry, using the top match (F-01). A scan with no match is not added (F-05).
- Every scan is its own entry, even when the same item and color are scanned again. Entries are not merged in the list, so each one can be corrected on its own.
- Each recognized item in a multi-part photo (F-04) or in live scan (F-03) becomes its own entry in the same way.
- New entries get quantity 1 and the default condition from Settings (F-12). Until Settings exist, the default is used.
- Once the waitlist exists, "Upload another" (F-01) leaves the previous scan in the waitlist instead of discarding it.

### The list
Newest entries first. Each row shows:
- the catalog thumbnail (for an item entered by number, BrickLink's thumbnail, see F-05), name, and item number;
- for a part: the color swatch and name, or "Any color";
- the labels from the price card: "Uncertain" or "Chosen by you";
- the condition (New / Used) and a quantity stepper;
- the price for one item, and the line price (price × quantity);
- the suggested target, if any (see [Targets](#targets)).

Tapping a row opens its price card with the "Wrong item?" control, so the full [correction sheet](F-05-match-correction.md#correction-sheet) is available from the list. No new recognition request is made.

```
┌────────────────────────────┐
│ Waitlist (12)       Select │
├────────────────────────────┤
│ [img] Brick 2 x 4     ×3   │
│       Red · Used  [-][+]   │
│       €0.08 each   €0.24   │
│       Uncertain            │
├────────────────────────────┤
│ [img] Minifig, Pilot  ×1   │
│       New  [-][+]  €4.10   │
│       → Fits: Series 5     │
├────────────────────────────┤
│ …                          │
├────────────────────────────┤
│ Total €18.40 · as of 14:02 │
│ [ Add all to inventory ]   │
└────────────────────────────┘
```

### Editing
- Condition and quantity are edited inline on each row. Quantity is a whole number of at least 1.
- Deleting an entry removes it and shows a short undo. There is no confirmation dialog.
- Changing the item or color goes through the correction sheet (F-05).

### Selecting and bulk actions
"Select" turns on checkboxes, with "Select all". With one or more rows selected, the bulk actions are:
- **Set condition** (New or Used) for all selected rows.
- **Set quantity** to a chosen number for all selected rows.
- **Delete**, with undo.
- **Add to inventory** for the selection. Without a selection, "Add all to inventory" is offered.

Changing a target or a group in bulk is not part of F-07 (see [Out of scope](#out-of-scope)).

### Prices
- A row's price is the headline price for its condition: the 6-month sold average ([pricing rules](../pricing.md)). The line price is that price times the quantity.
- The total adds up the line prices of all rows that have a price. Rows without a price are left out, and the total says how many.
- The list shows "Prices as of <time>" for the oldest price it uses.
- **Prices are not stored with an entry.** An entry keeps the item, color, and condition; its price is looked up through the shared price cache whenever it is shown. Saved data never goes out of date, and the price source stays an implementation detail.
- Changing an entry's condition makes no new request: one price lookup already covers new and used.
- Price requests for a long list are paced: visible rows first, a small fixed number in flight at once, and rows already in the cache cost nothing.

### Saving
- The waitlist is saved on the server for the user. Every change (add, edit, delete) is saved as it happens, with an ID created by the client, and write requests are safe to repeat.
- When a save fails, the row is marked "Not saved" with a retry. Leaving the page, or closing the app, while a change is unsaved shows a warning. Nothing else triggers a warning, because everything else is already saved.
- Entries are owned by a user from the start. Before accounts exist (F-13), a single local user owns them.
- Offline use is not supported (see [Out of scope](#out-of-scope)).

### Adding to the inventory
- "Add to inventory" moves the selected or all entries into the inventory in one operation: all of them, or none.
- Entries with the same item, color, and condition become **one inventory entry** with the quantities added. The entry format and how a merge treats an existing inventory entry are defined in F-08.
- Added entries leave the waitlist. A summary says how many entries were added.
- If the operation fails, nothing changes and the entries stay in the waitlist.

### Targets
Each row has a slot for a **suggested target**: the minifigure (and later set) that the entry could help complete. The slot is empty when there is none.
- F-07 shows the suggestion and lets the user replace it or clear it. It stores the target and whether it was suggested or chosen by the user.
- How suggestions are made, and how a part or a minifigure fills a target, is defined by [target assignment](../target-assignment.md) and F-10.
- Until F-10 exists, the slot is not shown.

### What an entry keeps
- the entry ID (created by the client) and the owner;
- everything a scan keeps ([F-05](F-05-match-correction.md#what-a-scan-keeps)): `listing_id`, the candidate list, the predicted colors, the selected item and color or "Any color", and how the selection was made;
- the condition and the quantity;
- the target and whether it was suggested or chosen by the user, once F-10 exists;
- when the entry was created.

An entry keeps no photo and no price.

### States and edge cases
| State | Trigger | Shown |
|---|---|---|
| Empty | No entries | "Nothing here yet. Scan something to get started." with the scan actions |
| Price loading | Price requested, not yet answered | A placeholder where the price goes; the row is fully usable |
| Price unavailable | BrickLink error or quota exhausted | "Price unavailable" on the row; the row is left out of the total |
| No price data | The item has no sales or listings | "No price data" on the row; left out of the total |
| Color without price data | The selected color has none (F-01) | As above |
| Not saved | A change could not be saved | The row is marked "Not saved" with a retry; leaving warns |
| Add failed | The add-to-inventory operation failed | A message; entries stay in the waitlist |
| Undo | Right after a delete | A short undo is offered; after it expires the delete is final |

## Acceptance criteria
- [ ] A scan with a match adds one entry to the waitlist without extra taps; a scan with no match adds none.
- [ ] Scanning the same item and color twice creates two entries.
- [ ] New entries have quantity 1 and the default condition.
- [ ] Condition and quantity can be edited inline; quantity below 1 is rejected.
- [ ] With several rows selected, "Set condition", "Set quantity", and "Delete" each apply to every selected row and to no others.
- [ ] A deleted entry can be restored with the undo until it expires.
- [ ] Tapping a row opens the price card, and the F-05 correction sheet works from it without a Brickognize request.
- [ ] Each row shows its condition's headline price and the line price; the total is the sum of the rows that have a price, and says how many rows have none.
- [ ] Changing an entry's condition makes no price request.
- [ ] A waitlist with many entries makes at most a small fixed number of price requests at once.
- [ ] Reloading the page, or opening the app on another device, shows the same waitlist.
- [ ] Repeating a save request (same entry ID) does not create a second entry.
- [ ] A failed save marks the row "Not saved", and leaving the page with an unsaved change shows a warning; leaving with everything saved does not.
- [ ] "Add to inventory" merges entries with the same item, color, and condition into one inventory entry with summed quantities, removes the added entries from the waitlist, and changes nothing if it fails.
- [ ] No price is stored with an entry.
- [ ] All tests use recorded fixtures; none call Brickognize or BrickLink.

## Third-party load
- **Brickognize:** none. The waitlist never calls it; entries keep the candidate list from the scan. Catalog thumbnails are cached in the browser as set in the [architecture](../../architecture.md#cross-cutting-constraints).
- **BrickLink:** prices only, through the shared price cache (see [F-01](F-01-image-upload.md#third-party-load)). Because prices are looked up when shown rather than stored, a long list can cause many lookups at once. They are paced (visible rows first, a small fixed number in flight), identical lookups are merged, and cached prices cost nothing. Changing condition or quantity costs no call. See the [BrickLink usage budget](../../architecture.md#bricklink-usage-budget).

## Out of scope
- The inventory itself: entry format, notes, sorting, grouping, and how a merge treats an existing entry (F-08).
- Groups (F-09) and changing a target or group in bulk. Bulk target and group actions come with F-10 and F-09.
- How targets are suggested (F-10).
- Sorting and filtering the waitlist.
- More than one waitlist, and sharing a waitlist.
- Offline scanning and queued saves.
- Export (F-11).
- Showing a collection value or price history.

## Open questions
- **When is an entry added?** The spec adds it as soon as the top match is selected, so the scan is never lost. The alternative is an explicit "Add to waitlist" tap on the price card.
- **Outdated prices.** When a price cannot be fetched, the row shows "Price unavailable". F-01 and the pricing rules currently show an expired cached price with a notice instead. Which one applies depends on the BrickLink freshness rules and is settled with them.
- **Undo after "Add to inventory".** Whether the user can take entries back out of the inventory is an F-08 question.
- **Minifigures as targets.** Whether a scanned minifigure row shows the set it could fill (for example a collectible minifigure series), as the composition model allows, is settled with collectible series targets, which are a later increment of F-10.
- **List size.** A maximum number of entries, and the number of price requests in flight at once, are set in the architecture.
