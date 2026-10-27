# Pieceful

Pieceful is a web app for identifying LEGO® parts and minifigures and seeing what they're worth. Scan a part, and its BrickLink price shows up right away. It works on phones and on computers with a webcam.

> **Status:** design phase. The documentation in [`docs/`](docs/README.md) describes the planned system. No application code yet.

## Planned features
- **Three ways to scan:** upload an image, take a photo manually, or use automatic *Live scan* from a camera feed.
- **Instant pricing** from the BrickLink price guide: new and used, sold and listed, with warnings when price data is thin.
- **Several parts per photo:** each part in one photo is recognized and priced separately.
- **Inventory and minifigure completion:** scanned parts are suggested toward the figures they complete, and missing parts can be exported as a BrickLink wanted list.

## Tech stack
| Layer | Technology |
|---|---|
| Frontend | React + TypeScript (Vite), installable PWA, mobile-first |
| Backend | Django + Django REST Framework |
| Recognition | [Brickognize API](https://brickognize.com), called from the browser |
| Prices and catalog | [BrickLink API](https://www.bricklink.com/v3/api.page), via the backend |
| Infrastructure | Docker |

## Documentation
- [Docs index](docs/README.md)
- [Requirements](docs/product/requirements.md)
- [Architecture](docs/architecture.md)
- [Decisions (ADRs)](docs/decisions/README.md)
- [Roadmap](docs/roadmap.md)

## License
[PolyForm Noncommercial 1.0.0](LICENSE): free for any noncommercial use.

LEGO® is a trademark of the LEGO Group, which does not sponsor, authorize, or endorse this project.
