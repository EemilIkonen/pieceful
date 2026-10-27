# F-05: Match correction
**Status:** Draft

## Goal
When recognition gets an item or its color wrong, the user fixes it in one or two taps and sees the correct price. The fix never costs another recognition request unless the user asks for a rescan. This keeps the scan-to-price flow fast even when the top match is wrong, and it keeps saved scans (F-07) accurate.

## User stories
- As a user, I want to switch to another candidate in one tap when the top match is wrong. (The basic swap is part of F-01.)
- As a user, I want to correct the color of a part, so that I see the price for the color I actually have.
- As a user, I want to rescan in one tap when the photo was poor, without starting over somewhere else.
- As a user, I want to enter a BrickLink item number when recognition can't find my item, so that I still get a price.

## Behavior

### Where corrections apply
Corrections act on one scan result: the price card in F-01, and later each waitlist entry (F-07) and each part in a multi-part photo (F-04). The same controls and rules apply everywhere. Until scans are saved (F-07), the corrected result lives only in the browser.

### Candidates
F-01 defines the basic swap: tapping another candidate selects it and prices it, reusing the stored candidate list. F-05 adds:
- Up to 3 alternatives are shown below the price card. "Show all" reveals the rest of the list Brickognize returned (10 by default).
- Once the user has picked an item or color, the "Uncertain" label is replaced by a "Chosen by you" marker.
- "Not in the list? Enter item number" closes the list (see [Item number entry](#item-number-entry)).

### Color
Colors apply to parts only. Minifigures and sets are priced without a color, and their card shows no color controls.
- **Chips:** the colors Brickognize predicted for the photo, in its order (up to 5), each with name and swatch. The top color is selected automatically, as in F-01.
- **Any color:** a chip that prices the part across all colors, labeled "Any color" as in F-01.
- **Other color:** opens a list of the colors BrickLink knows the part in, with name and swatch. Only these colors can be picked, so the user can't select a color the part never came in.
- Picking a color selects it and requests the price for the new item and color. No recognition request is made.
- When the user swaps to another part candidate, the selected color is kept. If that color is not among the part's known colors, the price shows the "no price data" state from F-01.

Color names and swatches come from the BrickLink color list. Brickognize color predictions are mapped to BrickLink color IDs (see [Open questions](#open-questions)).

### Rescan
- One "Rescan" button on the result. It opens the same input the scan came from: the file picker in F-01, the camera once F-02 exists.
- The new photo is prepared and recognized exactly as in F-01, with one `POST /predict/` request.
- On success, the new result **replaces** the current one: candidates, colors, and selection, including any corrections the user made.
- On failure (no match, image rejected, recognition unavailable), the previous result stays visible, and the failure is shown inline using the F-01 messages.
- Cancelling the picker changes nothing.
- Before scans are saved, Rescan and "Upload another" lead to the same screen. They differ once scans are saved (F-07): a rescan updates the same scan (same ID, same place in the waitlist), while "Upload another" creates a new one.

### Item number entry
For items Brickognize can't find, and for cases where the user knows the number:
1. "Enter item number" is offered at the end of the candidate list and in the no-match state.
2. The user picks a type (Part, Minifigure, or Set) and types the BrickLink item number, e.g. `3001`, `sw0001`, `75192-1`.
3. The backend looks the item up in the BrickLink catalog.
   - **Found:** the item becomes the selected item, marked "Chosen by you", and is priced. Parts get the color controls above; the photo's predicted colors stay available as chips.
   - **Not found:** "BrickLink has no <type> with number <no>." The form stays open with the input kept.
4. The item card uses BrickLink's thumbnail for an entered item, since Brickognize has no image for it.

The entered item does not join the candidate list. A rescan replaces it like any other selection.

### Prices after a correction
- Every change of item or color requests the price for the new selection, using the shared price cache from F-01.
- The request is sent once the selection has been stable for about 300 ms, so tapping through candidates quickly causes no requests for the ones passed over.
- Only the latest selection's price is shown. Responses for earlier selections are ignored.
- A price already fetched for this scan is reused without a new request.

### What a scan keeps
For corrections to work later from the waitlist (F-07) without a new recognition request, a scan keeps:
- Brickognize's `listing_id` (kept so that feedback can be added later; see [Out of scope](#out-of-scope));
- the candidate list: item ID, name, type, score, catalog image URL, BrickLink link;
- the predicted colors: ID, name, score;
- the selected item, and for parts the selected color or "Any color";
- how the selection was made: automatic, candidate picked, color picked, or item number entered.

The photo is not kept: it never reaches the backend, and a rescan needs a new one.

### Catalog lookups (backend)
Item lookups, known colors, and the color list come from the BrickLink catalog through the backend, like prices.
| Lookup | BrickLink call | Used for |
|---|---|---|
| Item | `GET /items/{type}/{no}` | Item number entry: name, thumbnail, existence check |
| Known colors | `GET /items/{type}/{no}/colors` | "Other color" list for one part |
| Color list | `GET /colors` | Color names and swatches (`color_code`) |

- Results are cached server-side and shared across users for **30 days** (configurable). Catalog data changes rarely.
- "Not found" results are cached for 24 hours, so a newly added catalog item becomes available within a day.
- Concurrent requests for the same uncached key cause one BrickLink call.
- Input is validated as for prices (known item type, item number format). Invalid input is rejected without a BrickLink call.

### States and edge cases
| State | Trigger | Shown |
|---|---|---|
| Known colors loading | "Other color" opened, list not cached | The chips stay usable; the list shows a loading indicator |
| Known colors unavailable | BrickLink error or quota exhausted, nothing cached | "Colors can't be loaded right now." The predicted chips and "Any color" still work |
| No known colors | BrickLink lists no colors for the part | Only "Any color" is offered |
| Item not found | Item number entry, BrickLink has no such item | "BrickLink has no <type> with number <no>." Input kept |
| Item lookup unavailable | BrickLink error or quota exhausted | "Item lookup is unavailable right now." The current selection is unchanged |
| Rescan failed | No match, `422`, network error, `5xx`, or `429` on a rescan | The previous result stays; the F-01 message is shown inline, with retry after backoff where F-01 has one |
| Color without price data | Selected color has no sales or listings | The F-01 "no price data" state for each figure |
| Predicted color not mappable | A Brickognize color has no BrickLink equivalent | The chip is not shown; if no chip remains, the part starts at "Any color" |

## Acceptance criteria
- [ ] Up to 3 alternatives are shown below the price card; "Show all" reveals every candidate Brickognize returned.
- [ ] After the user picks an item or color, "Uncertain" is replaced by "Chosen by you".
- [ ] For a part, the predicted colors appear as chips with names and swatches, plus "Any color" and "Other color".
- [ ] "Other color" lists only the part's known BrickLink colors; picking one re-prices the scan.
- [ ] Minifigures and sets show no color controls and are priced without a color.
- [ ] Swapping candidates, changing color, and entering an item number make no Brickognize request.
- [ ] Rescan makes exactly one `POST /predict/` request and replaces candidates, colors, and selection on success.
- [ ] A failed rescan keeps the previous result visible and shows the F-01 message inline.
- [ ] Item number entry finds a known part, minifigure, and set, and shows the not-found message for an unknown number without changing the selection.
- [ ] Selecting several candidates within 300 ms of each other requests a price only for the last one.
- [ ] Returning to a selection already priced in this scan makes no price request.
- [ ] A repeated catalog lookup (item, known colors, color list) within 30 days makes no BrickLink call; a repeated "not found" within 24 hours makes none.
- [ ] Two concurrent catalog lookups for the same uncached key cause one BrickLink call.
- [ ] Invalid item type or item number in a lookup returns `400` without a BrickLink call.
- [ ] The scan result in the browser holds the fields listed under [What a scan keeps](#what-a-scan-keeps).
- [ ] All tests use recorded fixtures; none call Brickognize or BrickLink.

## Third-party load
- **Brickognize:** corrections cost nothing. Only Rescan makes a request: one `POST /predict/` per rescan, under the F-01 rules (one request in flight, no automatic retries, backoff after errors and `429`). No feedback requests are sent.
- **BrickLink, prices:** each newly selected item and color is one price lookup through the shared cache (up to 4 calls on a miss, none on a hit). Debouncing and per-scan reuse keep quick swapping from causing calls for items the user passed over.
- **BrickLink, catalog:** "Other color" costs one known-colors call per part, only when the list is opened and not cached. Item number entry costs one item call per number on a miss. The color list is one call per 30 days for all users. All catalog results are cached for 30 days, "not found" for 24 hours, with one fetch per key. See the [BrickLink usage budget](../../architecture.md#bricklink-usage-budget).

## Out of scope
- **Feedback to Brickognize.** Deferred until risk R-04 is settled (terms and the deprecated `/feedback/` endpoints). The scan keeps `listing_id`, so feedback can be added without a data migration.
- Adding a second photo of the same item to one recognition request ("add an angle"); to be tested in spike S-00.
- Searching the catalog by name: BrickLink's API has no search endpoint, so this would need another catalog service.
- Stickers in item number entry (see open questions).
- Saving scans and editing them from the waitlist (F-07).
- Live scan (F-03) and several items per photo (F-04).

## Open questions
None blocking. The items below are **to verify** in spike S-00 (risk R-01 in the [architecture](../../architecture.md#risks-and-assumptions)):
- **Color IDs:** Brickognize's OpenAPI example pairs color ID `4` with "Red", while BrickLink's Red is `5` (its `4` is Orange). Brickognize color IDs may come from another catalog and need a mapping to BrickLink color IDs.
- Whether Brickognize predicts colors for the photo as a whole or per candidate. This decides whether keeping the color on a swap is right.
- Whether BrickLink item numbers for sets need the variant suffix (`-1`), and whether the app should add it when the user leaves it out.
- How stickers map to BrickLink item types, before they are offered in item number entry.
- Whether BrickLink's known-colors list covers all colors the price guide has data for.
