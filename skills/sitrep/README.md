# wk-sitrep

**Version:** `2026.07.20-155353`

Unified daily ops log backed by a SilverBullet workspace. Replaces
the former morning and evening standalone skills — no standalone HTML files,
no per-day live directories, and dated snapshots at close.

## Sub-commands

- `/wk-sitrep start` — workday start: gathers inbox via 5 parallel agents,
  carries forward open items from the previous live page, compiles every
  item into `$SITREP_REPO/$EMPLOYER/live.md`, verifies the 3-column layout
  actually rendered, then opens it in the browser.
- `/wk-sitrep end` — workday end: runs 7 parallel agents, writes a
  historical snapshot to `$EMPLOYER/YYYY/MM/DD/snapshot.md` (completed
  items + notes only), then rewrites `live.md` to hold all pending work for
  tomorrow.
- `/wk-sitrep` (no arg) — defaults to `start`.

No interactive triage — the user resolves items directly in SilverBullet.

## Key Design

- **Live page** (`$EMPLOYER/live.md`) — persistent checkbox page you edit in
  the browser; owns **all pending work**. Open items carry forward
  automatically; done items are stripped to the snapshot at end-of-day. The
  `date:` frontmatter is the sole working-day marker (no separate file).
- **Snapshot** (`$EMPLOYER/YYYY/MM/DD/snapshot.md`) — **historical record
  only**: completed items, achievements, meeting notes, feedback, DX
  metrics. Never holds pending `[ ]` items. Feeds
  [wk-self-perf](../self-perf/README.md).
- **SilverBullet formatting** — `#` in link text is escaped (`repo\#N`),
  links use full PR titles, items sort by urgency (🔴/🟡/🟢) with
  `**📅 date**` due-dates.
- **SilverBullet rendering** — no standalone HTML files are generated;
  `live.md` contains SilverBullet HTML blocks that the browser renders.
- **SilverBullet server** — the skill verifies the server is running and
  starts it (`silverbullet $SITREP_REPO`) if not.

## Environment

| Var | Purpose | Default |
|-----|---------|---------|
| `$SITREP_REPO` | Path to SilverBullet workspace repo | required |
| `$EMPLOYER` | Org slug for path scoping | required |
| `$SITREP_PORT` | SilverBullet server port | `3000` |
| `$GITHUB_ORG` | GitHub org scope for `gh` commands | required |

## Integrations

- Data gathering delegates to the same 5 (start) / 7 (end) parallel agents
  as the former morning and evening standalone skills.
- QPR-worthy achievements are appended to
  `$SITREP_REPO/$EMPLOYER/QPR/brag-log.md` — consumed by
  [wk-self-perf](../self-perf/README.md).
- When SilverBullet runs via Docker, a `docker-compose.yml` change is
  followed by `docker compose down && up -d` after push.
