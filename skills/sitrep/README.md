# wk-sitrep

**Version:** `2026.08.13-180622`

Unified daily ops log backed by a SilverBullet workspace. Replaces
the former morning and evening standalone skills — no standalone HTML files,
no per-day live directories, and dated snapshots at close.

## Sub-commands

- `/wk-sitrep start` — workday start: gathers the current inbox and
  previous-workday contribution evidence via 5 parallel agents. If the prior
  live page was never closed, `start` first runs the complete dated `end` flow;
  a failed close blocks today's overwrite. It then carries open items forward,
  compiles `$SITREP_REPO/$EMPLOYER/live.md`, verifies the 3-column layout,
  opens it in the browser, and auto-launches a
  `/wk-pr-review` subagent (via `git wta` worktree) for each PR awaiting your
  review in a locally-cloned `$GITC_ROOT/$EMPLOYER/<repo>`. Those reviews are
  left as unsubmitted drafts, so every run re-sweeps your own `PENDING` reviews
  org-wide and re-surfaces them until you submit or discard them.
- `/wk-sitrep end` — optional workday close: runs 7 parallel agents, writes a
  historical snapshot to `$EMPLOYER/YYYY/MM/DD/snapshot.md` (completed
  items + notes only), then rewrites `live.md` to hold all pending work for
  tomorrow and includes `end_completed_at` in the final close commit.
- `/wk-sitrep` (no arg) — defaults to `start`.

No interactive triage — the user resolves items directly in SilverBullet.

## Key Design

- **Live page** (`$EMPLOYER/live.md`) — persistent checkbox page you edit in
  the browser; owns **all pending work**. Open items carry forward
  automatically; done items are stripped to the snapshot at end-of-day. The
  `date:` frontmatter identifies the working day; `end_completed_at:` records a
  completed close. No separate state file is used.
- **Snapshot** (`$EMPLOYER/YYYY/MM/DD/snapshot.md`) — **historical record
  only**: completed items, achievements, meeting notes, feedback, DX
  metrics. Never holds pending `[ ]` items. Feeds
  [wk-self-perf](../self-perf/README.md).
- **SilverBullet formatting** — `#` in link text is escaped (`repo\#N`),
  links use full PR titles, items sort by urgency (🔴/🟡/🟢) with
  `**📅 date**` due-dates.
- **SilverBullet rendering** — no standalone HTML files are generated;
  `live.md` contains SilverBullet HTML blocks that the browser renders.
- **Standup copy** — copies rich HTML to preserve the three-level list
  hierarchy, falls back to plain text, and reports `Copied ✓` or
  `Copy failed` visibly.
- **SilverBullet server** — the skill verifies the server is running and
  starts it (`silverbullet $SITREP_REPO`) if not.
- **Yesterday synthesis** — validates evidence inside the previous-workday
  window across every available work source, then ranks outcomes, decisions,
  progress, and unblockings without preferring terminal tracker events.
- **Unavailable gathering domain** — replay its complete prompt in the main
  context, including query windows, outputs, and dependent actions before
  compiling. Calendar fallback records the five-day interview scan plus created
  block links or a no-slot/write-access result.

## Environment

| Var | Purpose | Default |
|-----|---------|---------|
| `$SITREP_REPO` | Path to SilverBullet workspace repo | required |
| `$EMPLOYER` | Org slug for path scoping | required |
| `$SITREP_PORT` | SilverBullet server port | `3000` |
| `$GITHUB_ORG` | GitHub org scope for `gh` commands | required |
| `$GITC_ROOT` | Local clone root for auto-launched PR reviews | `$HOME/gitc` |

## Integrations

- Data gathering delegates to the same 5 (start) / 7 (end) parallel agents
  as the former morning and evening standalone skills.
- QPR-worthy achievements are appended to
  `$SITREP_REPO/$EMPLOYER/QPR/brag-log.md` — consumed by
  [wk-self-perf](../self-perf/README.md).
- When SilverBullet runs via Docker, a `docker-compose.yml` change is
  followed by `docker compose down && up -d` after push.
