# 0003: Recognition is called from the browser

**Status:** Accepted
**Date:** 2026-10-20

## Context
Pieceful recognizes items with the Brickognize API. User photos may contain private surroundings and metadata, and the project aims to store no user images. Brickognize sends `Access-Control-Allow-Origin: *`, so a browser can call it directly. BrickLink, in contrast, has no CORS support and uses OAuth 1.0a with IP-bound tokens, so it is called only from the backend.

## Options
1. **Browser → Brickognize directly:** images never reach our server; no upload bandwidth or storage for us. Recognition depends on Brickognize allowing third-party browser clients, and rate limits apply per user rather than per server.
2. **Backend proxy:** central throttling and caching, but every image passes through our server, which adds privacy obligations, bandwidth, and latency.

## Decision
**Option 1.** The browser sends images straight to Brickognize. The backend receives only item IDs, colors, and user data.

## Consequences
- **Privacy:** images go to Brickognize, a third party. The client resizes images and re-encodes them before upload, which also strips EXIF and location data. The privacy policy must state that images are sent to Brickognize.
- **Third-party load:** throttling, backoff, and deduplication happen in the client. Each crop is recognized once; swapping candidates reuses the stored list. Catalog images are cached by the service worker.
- **Security:** no secrets are needed for Brickognize in the client.
- **Reversibility:** moderate. Moving to a proxy later changes the scan flow but not the data model.

### To verify (risk R-04 in the [architecture](../architecture.md#risks-and-assumptions))
- Brickognize's terms allow production use from a third-party browser client.
- Rate limits and any attribution requirements.
- Confirmation from Brickognize before closed alpha 1.
