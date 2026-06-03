# wk-sitrep

Unified daily ops log backed by a SilverBullet workspace. Replaces
[wk-goodmorning](../goodmorning/README.md) and
[wk-goodevening](../goodevening/README.md) — no HTML generation, no
per-day output directories.

## Sub-commands

- `/wk-sitrep start` — workday start: gathers inbox via 5 parallel agents,
  carries forward open items from the previous live page, triages
  interactively, writes `$SITREP_REPO/$EMPLOYER/live.md`, opens it in
  the browser.
- `/wk-sitrep end` — workday end: runs 7 parallel agents, snapshots the day
  to `$EMPLOYER/YYYY/MM/DD/snapshot.md`, scrubs completed items from `live.md`,
  writes the last-working-day marker.
- `/wk-sitrep` (no arg) — defaults to `start`.

## Key Design

- **Live page** (`$EMPLOYER/live.md`) — persistent checkbox page you edit in
  the browser throughout the day. Open items carry forward automatically;
  done items are stripped at end-of-day.
- **Snapshot** (`$EMPLOYER/YYYY/MM/DD/snapshot.md`) — full daily capture:
  achievements, brag doc, meeting notes, feedback, DX metrics. Feeds
  [wk-self-perf](../self-perf/README.md).
- **No HTML** — SilverBullet renders the markdown in the browser; no
  `morning.html` or `evening.html` is generated.
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
  as [wk-goodmorning](../goodmorning/README.md) /
  [wk-goodevening](../goodevening/README.md).
- QPR-worthy achievements are appended to
  `$EMPLOYER/QPR/brag-log.md` — consumed by
  [wk-self-perf](../self-perf/README.md).
- Weekly memory stored at `$EMPLOYER/.weekly_memory.md` — same `+m`
  modifier pattern as goodmorning/goodevening.
