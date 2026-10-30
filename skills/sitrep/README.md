# wk-sitrep

**Version:** `2026.10.30-194506`

Unified daily ops log backed by a SilverBullet workspace. Replaces
the former morning and evening standalone skills — no standalone HTML files,
no per-day live directories, and dated snapshots at close.

## Sub-commands

- `/wk-sitrep start` — workday start: gathers the current inbox and
  previous-workday contribution evidence via 5 parallel agents. If the prior
  live page was never closed, `start` first runs the complete dated `end` flow
  (one shared agent fleet serves both when the closed day is the previous
  workday); a failed close blocks today's overwrite. It then carries open items forward,
  compiles `$SITREP_REPO/$EMPLOYER/live.md`, verifies the 3-column layout,
  opens it in the browser, and auto-launches a
  `/wk-pr-review` subagent (via `git wta` worktree) for each PR awaiting your
  review in a locally-cloned `$GITC_ROOT/$EMPLOYER/<repo>`. Those reviews are
  left as unsubmitted drafts, so every run re-sweeps your own `PENDING` reviews
  org-wide and re-surfaces them until you submit or discard them. Reviews run in
  `light` mode, skip PRs already merged, closed or approved (re-checked before
  dispatch and again at publish), and each posted draft is opened for you; drafts
  on merged or closed PRs are never listed.
- `/wk-sitrep end` — optional workday close: runs 7 parallel agents, writes a
  historical snapshot to `$EMPLOYER/YYYY/MM/DD/snapshot.md` (completed
  items + notes only), then rewrites `live.md` to hold all pending work for
  tomorrow and includes `end_completed_at` in the final close commit.
- `/wk-sitrep` (no arg) — defaults to `start`.

No interactive triage — the user resolves items directly in SilverBullet. Connector
gaps never interrupt the compile-only flow: the page publishes first and the gaps are
reported afterwards in the response.

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
  `**📅 date**` due-dates. Every weekday label is recomputed from its date
  before writing; a source or agent weekday that disagrees is corrected and
  the correction noted.
- **Actionable means checkbox** — every item you must act on, each link in a
  list included, is its own checkbox item; action sections (such as the
  GitHub Inbox of merges, review requests and pending drafts on open PRs) sit
  directly under ASAP, one short line per item. Non-actionable lines are
  checkbox-less `st-info` spans, never raw text. The render check fails on any
  checkbox-less item that is not `st-info`.
- **Layout-geometry render gate** — before "Live page ready", the check asserts
  the three columns are direct children of the row with distinct, increasing
  left edges (containment alone passes on nested columns), and takes a
  screenshot. A same-day re-run regathers or says the earlier gather was reused.
- **SilverBullet rendering** — no standalone HTML files are generated;
  `live.md` contains SilverBullet HTML blocks that the browser renders.
- **Standup copy** — copies rich HTML to preserve the three-level list
  hierarchy, falls back to plain text, and reports `Copied ✓` or
  `Copy failed` visibly.
- **SilverBullet server** — the skill verifies the server is running and
  starts it (`silverbullet $SITREP_REPO`) if not.
- **Yesterday synthesis** — validates evidence inside the previous-workday
  window across every available work source, then ranks outcomes, decisions,
  progress, and unblockings without preferring terminal tracker events. A Jira
  ticket counts as the user's work only when the changelog or comment author is
  the user — an `updated` stamp moves on anyone's edit, including bulk edits.
- **Unavailable gathering domain** — replay its complete prompt in the main
  context, including query windows, outputs, and dependent actions before
  compiling. Calendar fallback records the five-day interview scan plus created
  block links or a no-slot/write-access result.
- **Interview blocks** — a 15-min prep block before and a 45-min scorecard block
  after each interview (a user-stated length wins), created via [`wk-cal`](../cal/README.md); a block
  renders as done only after the calendar is re-listed and the block's duration
  and zero overlap are confirmed.
- **Safe in-place patches** — line patches use shell parameter substitution (never
  `sed`/`awk`, which strip `\#` escapes); multi-line patches put the newline in a
  variable first, then the page is checked for stray literal `\n` text and
  unique, line-separated item IDs.
- **Publish first, report gaps after** — a missing, unauthenticated,
  permission-denied, or blocked connector never stops the run. The page is written,
  verified, and committed from the domains that answered; each gap is labelled in
  Meta and in the affected section, and the final response ends with a
  `Connector gaps` report (failure kind, affected sections, re-auth CTA).
- **Optional connectors** — DX is optional: when unavailable its sections are
  omitted and it appears in the report only as `(optional)`.
- **User waivers** — a connector the user waives (for all runs via
  `waived_connectors:` in `.sitrep.yml`, or for this run) drops out of the gap
  report, and a stale page the user declares closed skips rollover. Every waiver is
  echoed in the page's Meta section; the agent never infers one.
- **Connector migration** — when a gap connector's domain is covered by another
  available connector, the report also offers "migrate roster"; on user
  confirmation the skill's roster, ToolSearch hint, allowed-tools, and
  requirements list are edited together.
- **Push-destination gate** — commits always land locally, but `git push` runs
  only when the workspace repo's `origin` owner is in the approved set
  (`push_owners:` in `.sitrep.yml`, else `$GITHUB_ORG`). A missing list, missing
  remote, or any other owner — including a private repo under a personal
  account — skips the push and tells the user to move the repo to an
  employer-managed org. Confidential figures (spend, forecasts) stay out of the
  page and snapshots.
- **Degraded run** — gaps *inside* an available domain still render: every
  unavailable source is labelled, checkbox state and carry-over survive, stale
  dated meeting lines are dropped, no unverified outcome is claimed, and accrual
  artifacts are withheld until full evidence can be reconciled.

## Environment

| Var | Purpose | Default |
|-----|---------|---------|
| `$SITREP_REPO` | Path to SilverBullet workspace repo | required |
| `$EMPLOYER` | Org slug for path scoping | required |
| `$SITREP_PORT` | SilverBullet server port | `3000` |
| `$GITHUB_ORG` | GitHub org scope for `gh` commands; fallback approved push owner | required |
| `$GITC_ROOT` | Local clone root for auto-launched PR reviews | `$HOME/gitc` |

## Integrations

- Data gathering delegates to the same 5 (start) / 7 (end) parallel agents
  as the former morning and evening standalone skills.
- QPR-worthy achievements are appended to
  `$SITREP_REPO/$EMPLOYER/QPR/brag-log.md` — consumed by
  [wk-self-perf](../self-perf/README.md).
- When SilverBullet runs via Docker, a `docker-compose.yml` change is
  followed by `docker compose down && up -d` after push.
