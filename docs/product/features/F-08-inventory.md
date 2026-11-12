# F-08: Inventory
**Status:** Draft

## Goal
The inventory is the user's collection: one list of what they own, with how many, in which condition, and a note. Items arrive from the waitlist (F-07) after the user has reviewed them. The user can find, sort, and correct entries later without scanning again.

## User stories
- As a user, I want one row per kind of piece, so that I can see how many of each I own.
- As a user, I want to add a note to an entry (for example where the piece is stored), so that I can find it again.
- As a user, I want to search, filter, and sort my inventory, so that I can find a piece in a long list.
- As a user, I want to fix a wrong entry without rebuilding it, so that mistakes don't stay in my collection.
- As a user, I want to see a price for what is on screen, so that I know what a piece is worth when I look at it.

## Behavior

### Entries
An inventory entry is one kind of piece: an **item** (part, minifigure, set, or sticker), a **color** (parts only), and a **condition** (New or Used). It has a **quantity** and a **notes** field.
- **Unique per item + color + condition.** The inventory never holds two entries with the same item, color, and condition. Adding the same kind of piece again increases the quantity of the existing entry.
- Quantity is a whole number of at least 1. To remove an entry, delete it.
- Notes are free text, up to a length set in the architecture.
- An entry keeps the item's type, number, and name, and the catalog image address from the scan, so that the list can be shown and searched without a catalog lookup. Where this data comes from may be limited by the terms of the source (see [Open questions](#open-questions)).
- A part whose color was unknown when it was scanned ("Any color") is stored with **no color set** and shown as "Color not set". The user can set the color later (see [Correcting an entry](#correcting-an-entry)).
- An entry keeps **no scan data and no price**: no candidate list, no predicted colors, no photo, and no "Uncertain" or "Chosen by you" label. Those belong to waitlist entries (F-07).

### Adding from the waitlist
"Add to inventory" in F-07 moves waitlist entries here.
- For each distinct item + color + condition among the added entries, the quantities are summed. If the inventory already has an entry for it, its quantity increases by that sum and its notes stay unchanged. Otherwise a new entry is created.
- The operation is all or nothing. It carries an operation ID created by the client, so a repeated request (for example after a lost response) has no further effect and never adds a quantity twice.
- The entry's created time is set when it is first added; it is not changed by later additions.

### The list
Each row shows the catalog thumbnail, name, item number, color swatch and name (parts), condition, quantity, a marker when the entry has notes, and the price (see [Prices](#prices)). The header shows the number of entries and the total number of pieces (the sum of the quantities). Neither needs any BrickLink data.

The list is loaded from the server in pages, and sorting, searching, and filtering are done on the server, so it stays fast for a large inventory.

- **Sort:** name, date added, or quantity, ascending or descending. Default: date added, newest first.
- **Search:** by name or item number, within the user's own inventory. Search makes no catalog or BrickLink request.
- **Filter:** by item type, condition, and color. Filters combine, and a search applies within the filters.
- Sorting by price is not offered, because prices are not stored (see [Prices](#prices)).

### Editing
- Condition and quantity can be edited inline on each row, and notes in the entry's detail view.
- Deleting an entry removes it, with a short undo that restores it with its notes. There is no confirmation dialog.
- **Select** turns on checkboxes, as in the waitlist, with "Select all" (all entries that match the current search and filters, with the count shown). The bulk actions are **Set condition**, **Set quantity**, and **Delete**, applied to the selection.

### Correcting an entry
An inventory entry has no candidate list, so it is corrected with **Change item**:
1. The user enters a BrickLink item number and type, as in [item number entry](F-05-match-correction.md#item-number-entry), and the backend checks it against the BrickLink catalog.
2. For a part, the user picks a color from the part's known BrickLink colors ("Other color" in F-05). The color of the entry is kept if the new part came in that color.
3. The entry now describes the new item. It keeps its quantity, condition, and notes.

Alternatively, the user deletes the entry and scans again. Changing the color of a part, and setting a color on an entry with "Color not set", use the same color list.

### When a change makes two entries the same
Changing an entry's item, color, or condition (by editing, **Change item**, or **Set condition** in bulk) can give it the same item + color + condition as another entry. The two entries are merged: the quantities are added, and the notes of both are kept, joined with a line break. The app shows what will happen ("Merges with an existing entry: 5 + 3 = 8") before the change is applied, and the merge can be undone.

### Prices
- A row's price is the headline price for its condition: the 6-month sold average ([pricing rules](../pricing.md)). The row shows the price for one piece and the line price (price × quantity).
- **Prices are not stored with an entry.** They are looked up through the shared price cache when a row is shown.
- **Only rows that are on screen are priced**, in a paced way: a small fixed number of requests in flight, rows already in the cache cost nothing, and identical lookups are merged. Scrolling past a row does not request its price.
- There is **no inventory total, no collection value, and no sort by price.** A price for every entry would need far more BrickLink calls than the [usage budget](../../architecture.md#bricklink-usage-budget) allows for a large inventory.
- The list shows "Prices as of <time>" for the oldest price on screen.

### Saving
Like the waitlist (F-07): saved on the server for the user, with every change saved as it happens, client-created IDs, and write requests that are safe to repeat. A failed save marks the row "Not saved" with a retry, and leaving the page with an unsaved change shows a warning. Entries are owned by a user from the start; before accounts exist (F-13), a single local user owns them.

### States and edge cases
| State | Trigger | Shown |
|---|---|---|
| Empty | No entries | "Your inventory is empty. Scan something and add it from the waitlist." |
| No results | Search or filters match nothing | "No entries match." with a way to clear the filters |
| Price loading | Row on screen, price requested | A placeholder where the price goes; the row is fully usable |
| Price unavailable | BrickLink error or quota exhausted | "Price unavailable" on the row |
| No price data | The item has no sales or listings | "No price data" on the row |
| Color not set | Part added with "Any color" | "Color not set"; priced for all colors |
| Item not found | Change item: BrickLink has no such item | "BrickLink has no <type> with number <no>." Input kept; entry unchanged |
| Item lookup unavailable | Change item: BrickLink error or quota exhausted | "Item lookup is unavailable right now." Entry unchanged |
| Merge on edit | A change makes two entries the same | The merge is shown before it is applied, and can be undone |
| Not saved | A change could not be saved | The row is marked "Not saved" with a retry; leaving warns |

## Acceptance criteria
- [ ] The inventory never contains two entries with the same item, color, and condition.
- [ ] Adding waitlist entries with a kind of piece that already exists increases that entry's quantity and leaves its notes unchanged; otherwise a new entry is created.
- [ ] Repeating an "Add to inventory" request with the same operation ID does not change quantities a second time.
- [ ] A part added with "Any color" is shown as "Color not set", and a color can be set later from the part's known colors.
- [ ] Entries store no scan data and no price.
- [ ] The header shows the number of entries and the total number of pieces.
- [ ] Sorting by name, date added, and quantity works in both directions. Search by name or item number and filters by type, condition, and color work together, and none makes a BrickLink or catalog request.
- [ ] The list is paged, and a large inventory (several thousand entries) loads the first page without loading the rest.
- [ ] Quantity below 1 is rejected. Condition and quantity are editable inline; notes in the detail view.
- [ ] Bulk "Set condition", "Set quantity", and "Delete" apply to the selected entries only, and "Select all" selects the entries matching the current search and filters.
- [ ] A deleted entry can be restored, with its notes, until the undo expires.
- [ ] "Change item" accepts a known part, minifigure, and set, shows the not-found message for an unknown number without changing the entry, and keeps quantity, condition, and notes.
- [ ] When an edit makes an entry the same as another, the merge is previewed, the quantities are added, the notes of both are kept, and the merge can be undone.
- [ ] Only rows on screen request a price; scrolling past rows requests none, and at most a small fixed number of requests are in flight.
- [ ] No inventory total value and no sort by price is offered.
- [ ] A failed save marks the row "Not saved", and leaving the page with an unsaved change shows a warning.
- [ ] All tests use recorded fixtures; none call Brickognize or BrickLink.

## Third-party load
- **Brickognize:** none. The inventory never calls it. Catalog thumbnails are cached in the browser as set in the [architecture](../../architecture.md#cross-cutting-constraints).
- **BrickLink, prices:** only for rows on screen, through the shared price cache (see [F-01](F-01-image-upload.md#third-party-load)), paced, with identical lookups merged. There is no whole-inventory pricing, so a large inventory cannot exhaust the daily limit by being opened.
- **BrickLink, catalog:** "Change item" costs one item lookup per number entered and one known-colors lookup per part, as in F-05, cached the same way. See the [BrickLink usage budget](../../architecture.md#bricklink-usage-budget).

## Out of scope
- Groups: user-named collections and grouping the list by them (F-09). The list has no group-by view.
- Which entries are used for which minifigure or set, and any "allocated" or "free" quantity (F-10). Quantity is the total owned.
- A separate storage location field. Notes cover it for now.
- Inventory total, collection value, price history, and sorting by price.
- Export (F-11) and import from other services.
- Set contents and set completion.
- Offline use.
- Purchase price, source, and acquisition date.

## Open questions
- **Which item details an entry stores.** Name and catalog image address from a Brickognize scan are stored so the list can be shown and searched. For an item entered by number, the name and thumbnail come from BrickLink, whose API terms limit how long such data may be stored. Whether those entries store a name, or show only the item number until a lookup is made when displayed, is settled with the BrickLink terms review. Brickognize's terms for its catalog data are also still to be confirmed.
- **Undo after adding from the waitlist.** Whether the user can take entries back out of the inventory after "Add to inventory" (F-07 asks the same question) is not decided. Quantities merged into an existing entry make a clean undo harder.
- **Maximum sizes.** The notes length, the page size, and the maximum quantity are set in the architecture.
