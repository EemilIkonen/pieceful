# Pricing rules

**Status:** Draft

Prices come from the BrickLink price guide, fetched by the backend.

## Decided
- **Shown for every item:** new and used, each as **sold** (average of the last 6 months) and **listed** (current items for sale).
- **Headline price:** the 6-month sold average for the condition chosen in Settings.
- **Warnings** on the headline price when:
  - the sold average differs strongly from the listing average, or
  - too few items were sold for the average to be reliable. Rare parts may sell rarely but list high.
- **Defaults:** region EU, currency EUR. Region, currency, and VAT handling are user settings.
- **Caching:** price guide results are cached on the server and shared across users, keyed by item, color, condition, guide type, region, and currency. This keeps BrickLink load low.

## To be specified
- Warning thresholds (difference %, minimum sold quantity).
- Cache lifetime (proposal: 24 h) and refresh behavior.
- VAT options and how they are displayed.
- What happens when there is no price data at all.
