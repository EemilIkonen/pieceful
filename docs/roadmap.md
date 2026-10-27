# Roadmap

**Status:** Draft

## Release stages
| Stage | Description | Requires |
|---|---|---|
| Local MVP increments | Development builds that add one feature at a time | — |
| Closed alpha 1 | Deployed, used by the owner only | Accounts, hosting |
| Closed alpha 2 | Opened to a small invited group | Legal and privacy review |
| Public | Open to anyone | Scaling of caches and quotas |

## Milestones
| Milestone | Content | Status |
|---|---|---|
| M0 | Walking skeleton. Exit: `docker compose up` runs backend and frontend; a health endpoint; the generated TypeScript client calls it; CI green with tests, lint, types, and one E2E test on a phone viewport | planned |
| M1 | F-01 Image upload → price card, local only. Starts after risks R-01 to R-03 in [architecture](architecture.md#risks-and-assumptions) are verified | planned |
| M2+ | To be ordered from the [feature list](product/requirements.md#features), after spikes S-01 and S-02 | — |
| Deploy + accounts | Hosting, F-13 Accounts, abuse controls on the price endpoint, and database backups (automated, off-site, with a tested restore). Gate for closed alpha 1 | — |
| Legal and privacy | Privacy policy and legal review. Gate for closed alpha 2 | — |

## Spikes
Small throwaway experiments that settle a risky assumption before work is planned on it.
| ID | Question | Needed before |
|---|---|---|
| S-00 | Brickognize → BrickLink ID and color mapping (risk R-01), including set numbers and stickers; also whether several photos of one item in one request improve recognition ([F-05](product/features/F-05-match-correction.md)) | M1 |
| S-01 | Live-scan trigger and camera access on iOS Safari (including installed PWA) and Android Chrome | Ordering F-03 |
| S-02 | Multi-part segmentation: bundle size, speed, and accuracy on a phone | Ordering F-04 |

## Backlog (not scheduled)
Set completion, imports (BrickLink, Rebrickable), collection value dashboard, scan sounds/haptics, storage locations, offline scanning, native mobile app.
