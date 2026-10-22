# Pricing rules

**Status:** Draft

Prices come from the BrickLink price guide, fetched by the backend.

## Decided
- **Shown for every item:** new and used, each as **sold** (average of the last 6 months) and **listed** (current items for sale).
- **Headline price:** the 6-month sold average for the condition chosen in Settings (used until Settings exist). It uses BrickLink's `avg_price`, where each sale counts once, so a single bulk lot cannot dominate it. `qty_avg_price` is not used.
- **Warnings** on the headline price when:
  - the sold average differs strongly from the listing average, or
  - too few items were sold for the average to be reliable. Rare parts may sell rarely but list high.
- **Defaults:** region EU (`region=eu`), currency EUR (`currency_code=EUR`), VAT excluded (`vat=N`). Region, currency, and VAT handling become user settings with F-12.
- **Currency:** BrickLink returns prices in the requested currency, so every currency has data whenever the item has any (**to verify** in spike S-00).
- **No color:** when no color is known for a part, the price covers all colors and is labeled "Any color".
- **Caching:** price guide results are cached on the server and shared across users, keyed by item, color, condition, guide type, region, currency, and VAT mode. This keeps BrickLink load low.
  - Lifetime: 24 hours (configurable). An expired entry is refreshed on the next request; there is no background refresh.
  - Empty results ("no price data", "unknown item") are cached like any other result.
  - Concurrent requests for the same uncached key cause one BrickLink fetch.
  - When BrickLink is unavailable, an expired entry is served with a notice instead of an error.
- **Freshness:** every price shows when its data was fetched ("Prices as of <time>").
- **No price data:** a figure with no sales or listings is shown as such ("No sales in the last 6 months", "None listed"); the other figures are still shown.

## To be specified
- Warning thresholds (difference %, minimum sold quantity).
- VAT options and how they are displayed (with F-12).
