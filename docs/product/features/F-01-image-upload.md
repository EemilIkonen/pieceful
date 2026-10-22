# F-01: Image upload → price card
**Status:** Draft

## Goal
The user picks a photo of one LEGO item and sees what it is and what it is worth, with as few taps as possible. This is the first increment: it exercises recognition (Brickognize) and pricing (BrickLink) end to end without camera access.

## User stories
- As a collector, I want to upload a photo of a loose part and see its name and price, so that I can decide what to do with it.
- As a seller, I want a quick price check of a minifigure or set before listing it.
- As a user, I want to see when a match is uncertain, so that I don't trust a wrong price.
- As a user, I want to switch to another candidate in one tap when the top match is wrong.

## Behavior

### Flow
1. **Pick:** one "Upload image" button opens the file picker for a single image. The same control works on phones and desktop browsers.
2. **Prepare:** the browser decodes the image, scales it so the long edge is at most 1024 px (never upscaled), and re-encodes it as JPEG (quality about 0.85). The visual orientation is kept. Re-encoding drops all metadata, including EXIF and GPS location. The 1024 px value is a starting point, tuned with real photos.
3. **Recognize:** the browser sends the prepared image to Brickognize `POST /predict/` with color prediction enabled. A local preview of the image and a loading state are shown. The upload control is disabled while the request is in flight.
4. **Select:** candidates are kept in Brickognize's order. All item types are accepted: part, minifigure, set, and sticker. The top candidate is selected automatically.
5. **Price:** the browser requests the price for the selected candidate: item type, item number, and, for parts, the top predicted color. The price card appears as soon as the price arrives.
6. **Swap:** the other candidates are listed below the card (catalog thumbnail, name, score). Tapping one selects it and requests its price. No new recognition request is made; the stored candidate list is reused.
7. **Again:** "Upload another" starts over. The previous result is discarded.

### Price card
- Catalog thumbnail (Brickognize catalog image), name, item number, item type, and color name for parts.
- **Headline:** 6-month sold average (`avg_price`) for **used** condition.
- Also shown: sold average for new; listed average for new and used; the number of sales behind each sold average.
- Labels: "Uncertain" when the top score is below 0.7; "Any color" when a part was priced without a color.
- "Prices as of <time>": when the price data was fetched from BrickLink.
- A link to the item on BrickLink (from the Brickognize response).
- The fixed M1 parameters shown in small text: EU sellers, EUR, excluding VAT.

### Fixed parameters until Settings (F-12)
| Parameter | M1 value | BrickLink parameter |
|---|---|---|
| Region | EU | `region=eu` |
| Currency | EUR | `currency_code=EUR` |
| VAT | Excluded | `vat=N` |
| Headline condition | Used | `new_or_used=U` |

### States and edge cases
| State | Trigger | Shown |
|---|---|---|
| Recognizing | Request in flight | Preview, loading indicator; upload disabled |
| Unsupported image | The browser cannot decode the file (e.g. HEIC on some desktop browsers) | "This image format can't be read here. Try JPEG or PNG." No Brickognize request |
| No match | Brickognize returns no candidates (its default minimum score is 0.5) | "No match found. Try a sharp photo of a single item on a plain background." and "Try another image" |
| Uncertain | Top candidate score below 0.7 | Price card with the "Uncertain" label |
| Image rejected | Brickognize returns `422` | "This image couldn't be processed." and "Try another image" |
| Recognition unavailable | Network error, `5xx`, or `429` | "Recognition is unavailable right now." A retry button, enabled after a backoff delay. No automatic retries |
| No color predicted | A part candidate with no color | Price for all colors, with the "Any color" label |
| No price data | BrickLink has no sales or listings for a figure | "No sales in the last 6 months" (or "None listed") for that figure; the other figures are still shown |
| Unknown to BrickLink | BrickLink does not know the item number | "No BrickLink price for this item" and the BrickLink link if available |
| Pricing unavailable, cached data exists | BrickLink error or quota exhausted | The cached price with "Prices as of <time>" and a notice that it may be outdated |
| Pricing unavailable, no cached data | Same | "Price unavailable right now." The recognition result is still shown |

The score thresholds (0.5 and 0.7) are configuration values.

### Price endpoint (backend)
- **Input:** item type, item number, optional color ID. The input is validated (known item type, item number format, integer color ID). Invalid input is rejected without a BrickLink call.
- **Output:** the four price figures (new/used × sold/listed) with their sale or listing counts, the fetch time, and whether the data is stale.
- **Cache:** results are cached in the shared price cache for **24 hours** (configurable), keyed by item type, item number, color, condition, guide type, region, currency, and VAT mode.
- **One fetch per key:** concurrent requests for the same uncached key cause one set of BrickLink calls.
- **Empty results are cached:** "no price data" and "unknown item" results are cached like any other result.
- Per-client throttling is added with the Deploy + accounts milestone (see the [roadmap](../../roadmap.md)).

### Persistence
Nothing about a scan is stored. The image never reaches the backend. The only server-side state is the shared price cache. Saving scans starts with the waitlist (F-07).

## Acceptance criteria
- [ ] One "Upload image" control opens a single-image file picker on the browsers listed in NFR-08.
- [ ] The image sent to Brickognize is a JPEG with a long edge of at most 1024 px and no EXIF data. A fixture photo with GPS metadata proves it.
- [ ] Exactly one Brickognize request is made per uploaded image. Selecting another candidate makes none.
- [ ] The top candidate is selected and priced without extra taps.
- [ ] Candidates of type part, minifigure, set, and sticker can be selected and priced.
- [ ] A top score below 0.7 shows the "Uncertain" label. An empty result shows the no-match state.
- [ ] Network errors, `5xx`, and `429` from Brickognize show the unavailable state. No request is retried automatically, and retry is possible only after the backoff delay.
- [ ] The price card shows the headline (used, sold `avg_price`, EUR, `region=eu`, `vat=N`), the other three figures, the sales counts, the "Prices as of" time, and the BrickLink link.
- [ ] A part with no predicted color is priced without a color filter and labeled "Any color".
- [ ] A repeated price request within 24 hours makes no BrickLink call and responds within 300 ms (NFR-02).
- [ ] Two concurrent requests for the same uncached key cause one set of BrickLink calls.
- [ ] A "no price data" result is cached; repeating the request makes no BrickLink call.
- [ ] Invalid item type, item number, or color ID returns `400` without a BrickLink call.
- [ ] When BrickLink fails, a cached price is shown with the outdated notice; without one, "Price unavailable right now" is shown together with the recognition result.
- [ ] The backend never receives image data and stores nothing about the scan.
- [ ] The end-to-end time from upload to price is measured once on a throttled 4G profile and recorded against NFR-02.
- [ ] All tests use recorded fixtures; none call Brickognize or BrickLink.

## Third-party load
- **Brickognize:** one `POST /predict/` per uploaded image, with a JPEG of at most 1024 px. At most one request in flight per user. No automatic retries; backoff after errors and `429`. Swapping candidates reuses the stored list. Catalog thumbnails are cached in the browser as set in the [architecture](../../architecture.md#cross-cutting-constraints).
- **BrickLink:** only the selected candidate is priced. A cache miss costs up to 4 price-guide calls (new/used × sold/listed); a cache hit costs none. Other candidates cost calls only when the user selects them. Results are shared across users and cached for 24 hours, empty results included, with one fetch per key. See the [BrickLink usage budget](../../architecture.md#bricklink-usage-budget).

## Out of scope
- Camera capture (F-02), live scan (F-03), several items per photo (F-04).
- Color correction, feedback to Brickognize, and rescan (F-05).
- Pricing warnings (F-06; thresholds still open).
- Saving scans, waitlist, inventory (F-07, F-08).
- User settings (F-12) and accounts (F-13).
- Per-client throttling of the price endpoint (Deploy + accounts milestone).
- Selecting several files at once; drag and drop.

## Open questions
None blocking. The items below are **to verify** in spike S-00 and the API terms review (risks R-01 and R-04 in the [architecture](../../architecture.md#risks-and-assumptions)):
- How Brickognize item types and IDs map to BrickLink, especially sets (item number format) and stickers (BrickLink item type).
- How BrickLink reports an unknown item and a price guide with no sales.
- That BrickLink's `color_id` is optional and averages across all colors when left out.
- That `currency_code` converts prices rather than filtering by the seller's currency.
- Whether Brickognize sends `Retry-After` with `429`.
- HEIC: whether the iOS photo picker hands over JPEG, and which desktop browsers can decode HEIC.
- The status of the Brickognize endpoints, which its OpenAPI spec marks as deprecated.
