---
name: wk-sitrep
description: >-
  Unified daily ops log backed by a SilverBullet workspace — replaces the
  former morning and evening standalone skills. `start` gathers the day's inbox,
  carries forward open items, and writes a live 3-column dashboard you edit in
  the browser. Optional `end` closes the day; the next `start` closes any
  unfinished prior day first. No standalone HTML files — SilverBullet renders
  everything.
argument-hint: '[start|end]'
env-vars:
  - SITREP_REPO
  - EMPLOYER
  - GITC_ROOT
allowed-tools:
  - Skill
  - Agent
  - Read
  - Write
  - "Bash(date:*)"
  - "Bash(mkdir:*)"
  - "Bash(test:*)"
  - "Bash(ls:*)"
  - "Bash(command:*)"
  - "Bash(jq:*)"
  - "Bash(sed:*)"
  - "Bash(printf:*)"
  - "Bash(open:*)"
  - "Bash(pgrep:*)"
  - "Bash(silverbullet:*)"
  - "Bash(docker compose:*)"
  - "Bash(docker ps:*)"
  - "Bash(gh pr view:*)"
  - "Bash(git rev-parse:*)"
  - "Bash(git status:*)"
  - "Bash(git add:*)"
  - "Bash(git commit:*)"
  - "Bash(git push:*)"
  - "Bash(git log:*)"
  - "Bash(gh search prs:*)"
  - "Bash(gh search issues:*)"
  - "mcp__*playwright*__browser_*"
  - "mcp__claude_ai_Slack_*__*"
  - "mcp__claude_ai_Gmail_*__*"
  - "mcp__claude_ai_Gcal_*__*"
  - "mcp__claude_ai_Granola_*__*"
  - "mcp__claude_ai_Gdrive_*__*"
  - "mcp__claude_ai_Gdocs_*__*"
  - "mcp__claude_ai_Github_*__*"
  - "mcp__claude_ai_Jira_*__*"
  - "mcp__claude_ai_Lattice_*__*"
model: sonnet
effort: high
model-invocable: false
user-invocable: true
license: MIT
group: rituals
metadata:
  author: whizzzkid
  version: "2026.08.18-201645"
  model:
    openai: gpt-5.6-terra
---

# Sitrep

Unified daily ops log backed by a SilverBullet workspace. One persistent live
page → replaces former morning/evening skills. No standalone HTML files, no
per-day live directories; dated snapshots at close.

## Sub-commands

- `/wk-sitrep start` — workday start routine.
- `/wk-sitrep end` — optional workday close routine.
- `/wk-sitrep` (no argument) — defaults to `start`; emits:
  > "Running wk-sitrep:start (default — no sub-command specified)"

## Core hard rules

- **HARD RULE — never write outside `$SITREP_REPO/$EMPLOYER/`.** All output is
  scoped to the SilverBullet workspace. Never write `morning.md`, `evening.md`,
  or any sitrep file into cwd or `$WK_SKILLS_HOME`.
- **HARD RULE — no interactive triage.** User resolves items in SilverBullet,
  not chat. Never call `AskUserQuestion` to keep/skip/resolve. Both sub-commands
  are compile-only — gather → render → write → open — with one exception: the
  required-connector abort below stops before the write and reports instead.
  Write surfaced items unconditionally as `data-done="false"` checkbox spans; user
  edits the browser page directly.
- **HARD RULE — never assert missing without checking.** Before saying "no
  snapshot" or "X not found", run `Read`/`ls` on the path. If you did not
  check, say "I have not read X", not "X is missing."
- **HARD RULE — a missing required evidence connector aborts publication.**
  Required = the company-data evidence domains (messaging, mail, calendar/meeting
  notes, tracker); source control alone is never sufficient evidence. Any one
  unavailable → stop before writing: leave the live page byte-unchanged, accrue no
  rollover marker or brag entry, make no commit or push, then name every missing
  connector in the response and await instruction — report in-response, never via
  `AskUserQuestion`. Never publish a partial page in place of a complete one — this
  case aborts, it does not degrade.
- **Gaps inside an available domain** (fallbacks exhausted, one stalled agent)
  still render: label each unavailable source, preserve `data-done` and carry-over,
  drop stale dated meeting lines, keep the standup hierarchy, emit no unverified
  outcome claim, and withhold accrual artifacts (rollover marker, brag log) until
  full-evidence reconciliation.

## Rendering contract

- Invoke [`wk-silverbullet`](../silverbullet/README.md) for layout mechanics. It
  owns HTML-block blank-line rules, span-checkbox pattern, onclick handler,
  `window.client` API, `space-style` CSS, force-reload. This skill owns content
  selection.
- SilverBullet parses inline hashtags in link text → escape every `#` as `\#`,
  use full PR/issue titles (`repo\#N: commit-style title`), omit items with no
  canonical URL.
- `live.md` is an HTML flexbox 3-column layout, not a Markdown table. Both
  `start` and `end` write frontmatter + `# Live — {DATE}` + one
  `<div class="sitrep-row">` containing three `<div class="sitrep-col">`.
- Actionable items use `<span class="st-item">` with a nested
  `<span class="st-cb" data-t="tN" data-done="false" onclick="HANDLER">`.
- `data-t` is unique and sequential per page (`t1`…`tN`).
- Auto-action items already done at generation start `data-done="true"`; nested
  sub-items use `class="st-item st-nested"`.
- **Mark done only what is terminal.** An auto-action leaving an artifact the
  user must still act on (unsubmitted draft, unsent reply) renders its launch
  done but stays open work — re-query and re-surface it every run until the
  artifact is terminal.
- Group items only via the flat `st-item`/`st-nested` span pattern already in the
  file. **Important — never freelance a new tag or nesting shape**; only a
  documented classed `<div>` (the standup copy block) may nest inside
  `.sitrep-col`, and never with a blank line before or after it — a blank line
  anywhere in a column body ends that column's HTML block and ejects the rest
  full-width below the row, at any nesting depth.
- Non-actionable content (meeting lines, headers, standup block) is plain text
  or inline markdown.
- Sort by priority/severity, staleness, due date, then undated. Lead with 🔴
  overdue/ASAP, 🟡 due ≤3 days, or 🟢 later/no hard date; append `⏳ {N}d`
  after 7 days pending. Format due dates as `**📅 YYYY-MM-DD**`.
- Keep CSS/Lua in `$EMPLOYER/sitrep-style.md`; never regenerate it daily. After
  style edits, force reload and verify before finishing.

### Checkbox-span format

Canonical span + concrete toggle-handler recipe:
[`references/checkbox-span-handler.md`](references/checkbox-span-handler.md).

## Dismissed registry (cross-run de-dup)

User-resolved items vanish from `live.md` at `end` but the next `start` sweep
can rediscover them. A week-scoped JSONL registry suppresses those keys.

- Use one action-specific key per record; `start` drops gathered and carry-over
  matches from the current ISO week.
- Path, key, safe-write, validation, and `is_dismissed` recipes:
  [`references/dismissed-registry.md`](references/dismissed-registry.md).

## Step 0: Bootstrap (both sub-commands)

Resolve config → env → default for `$SITREP_REPO`, `$EMPLOYER`, `$SITREP_PORT`
(`.sitrep.yml` at the working repo root wins), export `$TODAY`, `$LIVE_FILE`,
`$SNAPSHOT_FILE`, `$SNAPSHOT_URL`, `$WEEK_MEM_FILE`, `mkdir -p` their parents,
then ensure SilverBullet is serving `$SITREP_REPO` (docker deployment counts as
running; auto-start the CLI; hard-fail when neither exists). Canonical probe +
start recipes: [`references/bootstrap.md`](references/bootstrap.md).

## Sub-command: start

### Stage 0.5: Close unfinished prior day

- **HARD RULE — close before overwrite.** Prior `date:` + no valid completed-end
  state → run the full `end` flow for that date before Stage 1; failure stops
  `start`.
- Marker, legacy detection, date rebinding, retry, and restoration:
  [`references/missed-end-rollover.md`](references/missed-end-rollover.md).

### Stage 1: Load previous live.md

- Read `$LIVE_FILE` if it exists. Extract open `data-done="false"` spans as
  carry-over, completed `data-done="true"` spans as a count only.
- Legacy `⬜` / `[ ]` / `✅` / `[x]` forms are read-only compatibility
  fallbacks; canonical state is `data-done`.
- Resolve previous working day from existing `date:` frontmatter. Cross-check
  carry-overs against live external state in Stage 2.
- Resolve and read `$PREV_SNAPSHOT_FILE`; treat every `## Achievements`
  subsection as candidate Stage 4b evidence, never a freshness waiver.

### Stage 2: Parallel data gathering

Launch 5 agents in parallel. Prepend
[`references/subagent-contract.md`](references/subagent-contract.md); append
[`references/yesterday-synthesis.md`](references/yesterday-synthesis.md) to
every available-domain prompt. Separate previous-workday evidence from today's
items.

Agent roster:

- **Slack:** unread DMs/mentions needing response; open threads awaiting reply;
  announcements. ToolSearch: `"slack"`.
- **Gmail:** unread emails needing response; sent emails without reply;
  announcements. ToolSearch: `"gmail"`.
- **Calendar + Granola + Google Drive:** today's meetings with agenda docs and
  last-session Granola notes; interviews lacking a prep/scorecard block (data
  only — orchestrator creates them in Stage 2c, per
  [`wk-cal`](../cal/README.md) §Interview Prep Scan).
  ToolSearch: `"gcal"`, `"granola"`, `"gdrive"`.
- **GitHub:** PRs needing review (`--draft=false`); your open PRs with failing
  CI or review comments; assigned issues; mentions. All `gh` commands require
  `--owner="$GITHUB_ORG"`. ToolSearch: `"github"`.
  - **HARD RULE — verify authorship, never infer it** (see the canonical
    Authorship filter in Stage 4 §Code & PRs). A PR enters "Your PRs" only after
    `gh pr view --json author` confirms it; route review-requested / mentions /
    involvement to other buckets. Prevents teammate/bot PRs surfacing as own.
  - **Sweep your own unsubmitted reviews** — reviews you authored in `state:
    PENDING`, org-wide every run, never only re-checking known PRs; surface each
    as ASAP until submitted or discarded.
- **Jira + Confluence:** assigned tickets needing action; ticket mentions;
  Confluence mentions. ToolSearch: `"jira"`, `"confluence"`.

Soft/hard block handling per canonical subagent contract: OAuth soft blocks
degrade with an authorization CTA. A `tool_unavailable` return =
capability-inheritance failure — replay that domain in the main context: every
query window, output field, and downstream orchestrator action before compile.
Only a domain still toolless *after* that replay counts as a missing connector:
on a required evidence domain it aborts publication per Core hard rules, on any
other domain it degrades.

#### Jira full open-ticket sweep

Always run a third JQL for all open assigned tickets:

```
assignee = currentUser() AND statusCategory != Done ORDER BY updated DESC
```

Surface `In Review` / `Ready for Review` / `Blocked` / `On Deck`, past-due
tickets, and merged-PR-but-open transition candidates. Collapse no-activity /
no-due-date tickets into one `## 🗂 Jira backlog` section.

#### Cross-tracker pending-on-me sweep

Fold assigned items from every connected tracker into one pending-on-me view:

- Compare carry-over current status against the status recorded in the previous
  `live.md`; prefix changes with `🔁 {old}→{new}`.
- Append `⏳ {N}d` to items pending beyond 7 days.
- Read native priority/severity; items without priority sort lowest.
- Apply to every connected tracker; skip only when its MCP is absent.

### Stage 2b: Auto-transition merged-PR tickets

After agents return and before writing `live.md`, close tickets already finished
(`start` only; during `end`, render merged-but-open tickets as carry-forward,
never transition):

- For each Agent 5 ticket in `In Review` / `Ready for Review` with a linked PR,
  check merge state: `gh pr view <url> --json state,merged,mergedAt`.
- If merged within last 14 days, transition to `Done`. Denial is deterministic, so
  block-register the key on first denial and skip the re-attempt on later runs:
  re-verify merge, render `🔁 blocked N days` pinned in ASAP until a manual
  transition. Never retry or fail the run.
- Render as a `data-done="true"` `⚙️ Auto-Actions` item with
  `✅ auto-transitioned to Done by agent`; never render as an open TODO.

### Stage 2c: Create missing interview prep blocks (`start` only)

Orchestrator action after agents return, before writing `live.md`. A referenced
sibling-skill flow is an action to run, not framing to describe — subagents
gather read-only; the orchestrator owns every write.

- For each interview the Calendar domain reports lacking a prep/scorecard block,
  call [`wk-cal`](../cal/README.md)'s block-creation flow: a 15-min prep block
  before, a 30-min scorecard block after (scan forward in 30-min increments when
  the immediate slot is busy).
- Before Stage 3, record the five-day interview-scan result and either created
  block links or the no-slot/write-access fallback.

### Stage 3: Compile open items

- Merge agent results with carry-over. Drop carry-overs whose external record
  shows completion; drop any item whose key `is_dismissed` for the current week.
- Write every surviving item as a `data-done="false"` checkbox span in the
  correct column. No prompts.

Content inventory, skip empty:

1. Carry-over from previous `live.md`
2. Today's Meeting Prep
3. Slack — Needs Response / Follow-ups
4. Email — Needs Response / Follow-ups
5. GitHub — PRs to Review / Your PRs / Issues
6. Jira — Tickets / Mentions
7. Confluence — Mentions

Sort and mark urgency per the rendering contract.

### Stage 4: Write live.md

- Re-read `$LIVE_FILE` immediately before writing. Preserve every
  `data-done="true"` span; never overwrite a done item with pending. Prefer
  `Edit` over full `Write` when structure allows.
- Write today's live page as one `<div class="sitrep-row">` of three
  `<div class="sitrep-col">`; no blank lines inside any `<div>`. Assign unique
  sequential `data-t` IDs.

```markdown
---
date: {TODAY}
employer: {EMPLOYER}
generated_with: {SKILL_VERSION}
generated_at: {ISO_8601_UTC}
---

# Live — {TODAY}

<div class="sitrep-row">
<div class="sitrep-col">
{col1}
</div>
<div class="sitrep-col">
{col2}
</div>
<div class="sitrep-col">
{col3}
</div>
</div>
```

- **col1 — Calendar + Slack + Email:** calendar meeting lines, prep spans,
  Slack needs-response/follow-ups, announcements, email needs-response.
- **col2 — ASAP + Auto-Actions + GitHub + Jira:** ASAP spans, auto-actions as
  `data-done="true"`, PRs-to-review/your-PRs, tickets/mentions.
- **col3 — Meta + Standup + This Week + Notes + Backlog:** meta line, standup
  copy block, this-week goal spans, notes placeholder, backlog from the
  previous working day.

### Stage 4b: Standup snippet

Render standup in col3 as a copy block:

Use the canonical rich-copy block verbatim from
[`references/standup-copy-block.md`](references/standup-copy-block.md).

Delegate formatting to [`wk-slack`](../slack/README.md) §Standup Snippet; this
skill owns selection.

- **HARD RULE — Yesterday is date-bounded multi-source synthesis.** Apply
  [`references/yesterday-synthesis.md`](references/yesterday-synthesis.md) to
  verify candidates within the previous-workday window; reject prior
  standup/session memory as evidence and terminal-state bias.
- Emit 3–4 highest-impact outcomes, decisions, progress, or unblockings, one
  per bullet; append bare PR URLs. If all domains return none, emit
  `No verified accomplishments found`.
- **Today:** top 3–4 🔴 ASAP items, deadline-first.
- **Blockers:** `BLOCKED` or dependency conflicts; always present — `None` when
  empty (per [`wk-slack`](../slack/README.md) §Standup Snippet).
- Apply [`wk-slack`](../slack/README.md) §Standup privacy filter — drop
  hiring/interview/candidate, personal HR/performance, or non-public items.
- Use the plaintext fallback exactly: top-level `•` day markers with indented
  `  •` item bullets, one item per line. The emoji leads each day marker —
  `• 👈🏽 Yesterday`, `• 👉🏽 Today`, `• ✋🏽 Blockers` — never trailing.
- Render the rich body as one root `<ul>` with exactly three top-level `<li>`
  branches in that same order. Each branch owns its nested item `<ul>`; never
  serialize the three sections as sibling lists or flatten their children.
- Verify `👈🏽` and `👉🏽` survive the write; re-emit via Write if either is
  missing.

### Stage 5: Verify render, then open

- **HARD RULE — gate the "Live page ready" announcement on a verified render.**
  `open` launches a tab; it does not confirm the DOM. Before announcing,
  `browser_navigate` to the live URL and `browser_evaluate`:

  ```javascript
  document.querySelectorAll('.sitrep-col').length===3 &&
    [...document.querySelectorAll('.sitrep-col')].every(c=>c.textContent.trim()) &&
    ['.st-copy-block','.st-item'].every(s=>document.querySelectorAll('.sitrep-col '+s).length===document.querySelectorAll(s).length)
  ```

  Must return `true` — 3 non-empty columns AND every nested marker still inside a
  column. **Assert containment, not presence:** a count/non-empty check passes while
  an ejected block sits full-width below the row. On `false`, fix the HTML per
  [`wk-silverbullet`](../silverbullet/README.md) Step 6 and re-verify — never
  announce a broken layout. A screenshot is not a substitute for the assertion.
- Verify the standup hierarchy and copy interaction using
  [`references/standup-copy-block.md`](references/standup-copy-block.md). A
  mocked `navigator.clipboard` call alone is not proof: use a browser gesture,
  wait for visible success/failure feedback, and confirm copied plain text when
  clipboard readback is available.
- `browser_close` the automation window after the assertion, before `open` — it and
  the user-facing tab have distinct lifecycles; a leftover window clutters the desktop.

```bash
open "http://localhost:$SITREP_PORT/$EMPLOYER/live.md"
```

Announce only after the assertion passes:

> "Live page ready: http://localhost:$SITREP_PORT/$EMPLOYER/live.md
>
> {X} items to action, {Y} meetings today, {Z} carry-overs from yesterday.
> Check off items in the browser as you go — they sync to `$LIVE_FILE`."

### Stage 6: Commit and push

Commit and push without prompt:

```bash
git -C "$SITREP_REPO" add "$LIVE_FILE"
git -C "$SITREP_REPO" commit -m "chore(sitrep): 📋 start $TODAY — {N} items, {M} meetings"
git -C "$SITREP_REPO" push
```

Fold auto-actions into the same commit, or a follow-up
`chore(sitrep): ✅ {action}`.

### Stage 7: Auto-launch PR reviews (`start` only)

Auto-action after the live page commits — one review worktree per PR awaiting
your review, rendered as a done ⚙️ Auto-Action.

- **Pending draft only.** Subagent follows wk-pr-review Phase 5; never submit,
  approve, or request changes — live reviews are irreversible (only PENDING is
  deletable). A launched draft is not terminal — the Stage 2 PENDING sweep
  re-surfaces it until submitted or discarded.
- Mechanics (source bucket, allowlist, local clone, concurrency cap, per-PR
  worktree flow): [`references/auto-review.md`](references/auto-review.md).

Then invoke [`wk-learn sitrep`](../learn/README.md).

## Sub-command: end

### Stage 1: Read live.md

- Read `$LIVE_FILE`. Extract completed `data-done="true"` spans, open
  `data-done="false"` spans, notes under `## Notes`, standup data. Legacy
  checkbox glyphs are compatibility fallbacks only.
- If `$LIVE_FILE` absent, continue from agents.

### Stage 2: Parallel data gathering

Launch 7 agents in parallel. Include the gathering-subagent contract
(`references/subagent-contract.md`) verbatim.

Agent roster:

- **GitHub/git:** today's commits, PRs created/merged/reviewed, issues closed.
  Requires `$GITHUB_ORG`.
- **Calendar + Granola:** today's meetings with decisions, action items, open
  questions; tomorrow's meetings flagged for prep.
- **Slack:** unanswered DMs/mentions; notable contributions.
- **Gmail:** unreplied emails; notable outgoing emails.
- **Lattice:** pending feedback requests with deadlines; new feedback.
- **Jira + Confluence:** Jira activity; unanswered Jira comments; Confluence
  mentions. Run the full open-ticket sweep:
  `assignee = currentUser() AND statusCategory != Done`.
- **DX:** review turnaround, cycle time, deploy frequency vs team/org averages;
  improvement actions.

### Stage 3: Compile

Merge into two buckets:

- **Historical → snapshot:** user-checked done items, externally confirmed done
  items, meeting notes, achievements, feedback, DX metrics, day stats.
- **Pending → live.md:** tomorrow's prep, untracked actions, unanswered
  Slack/email/Jira/Confluence, Lattice requests, peer feedback opportunities,
  DX improvements, every externally-confirmed pending span.

Detect state by `data-done`, not glyphs. Cross-validate pending spans before
carry-over:

- GitHub: PR/issue merged or closed.
- Jira: linked ticket moved to Done.
- Calendar: prep item's meeting already occurred.
- Slack: referenced thread replied to.

Report detected-done vs user-checked-done separately. Ambiguous evidence stays
pending. Drop items with no link.

### Stage 4: Write snapshot.md

Snapshot is historical only; never write pending items into it. If
`$SNAPSHOT_FILE` exists, re-read and merge — append newly completed items and
meeting notes rather than overwriting.

**Authorship filter (canonical):** include a PR as the user's only when
`gh pr view <pr> --json author` confirms author / co-author / primary approving
reviewer — carry-over lists, review queues, and prior agent reports are NOT
proof. Enumerate own PRs via `gh search prs --author @me` (add
`--merged --merged-at <range>` for wins). Applies to "Your PRs", snapshot wins,
and standup alike.

Snapshot template (front-matter + Achievements / Meeting Notes / Issues / DX /
Day Stats): [`references/snapshot-template.md`](references/snapshot-template.md).

Append QPR-worthy items to `$SITREP_REPO/$EMPLOYER/QPR/brag-log.md` with `🌟`.

### Stage 5: Rewrite live.md

- Re-read `$LIVE_FILE` before rewriting; merge completed spans into the snapshot
  done set, don't re-surface them.
- Before scrubbing, write each completed span's action-specific key to
  `$WEEK_MEM_FILE` via the Dismissed registry pattern.
- Rewrite `$LIVE_FILE` with every pending item; drop completed spans and
  date-specific FYI (Calendar, Announcements, standup). Fold pending spans +
  tomorrow's prep, unresolved follow-ups, Lattice/peer feedback, DX improvements.
  Re-number `data-t` from `t1`; sort and mark urgency per the rendering contract.

Reuse the Stage 3 `sitrep-row`/`sitrep-col` skeleton; frontmatter `date: {TODAY}` +
`note: "Scrubbed {N} completed items — full record in snapshot"`, heading
`# Live — carry-forward from {TODAY}`.

- **col1 — Tomorrow's Meeting Prep:** meeting lines and prep spans.
- **col2 — Carry-forward + Follow-ups & Feedback + DX:** carry-forward,
  unanswered Slack/email/Jira, Lattice requests, DX actions.
- **col3 — Notes:** preserved free-form notes.

No separate state file; `date:` identifies the working day and
`end_completed_at:` records a completed close.

### Stage 6: Open snapshot in browser

```bash
open "$SNAPSHOT_URL"
```

Announce:

> "Snapshot written: $SNAPSHOT_URL
>
> Today: {N} done ({U} you checked + {D} detected from
> GitHub/Jira/Calendar/Slack), {M} carried forward, {P} meetings documented.
> {brag_highlight — single most impactful item}
>
> live.md scrubbed — {N} open items remain for tomorrow."

### Stage 7: Distill accumulated learnings

If `$WK_SKILLS_HOME` is set and unprocessed learning files exist: process
highest severity first, cap at 5 per run, carry the rest. Invoke
[`wk-sharpen`](../sharpen/README.md) with each file as input. Do not rename
files here; [`wk-sharpen`](../sharpen/README.md) owns `.learned.md` renames.

### Stage 8: Mark complete, commit, and push

Invoke [`wk-learn sitrep`](../learn/README.md). After Stages 1–7 and learning
capture succeed, add `end_completed_at: {ISO_8601_UTC}` to `$LIVE_FILE`; a
missing marker makes the next `start` retry the close. Commit and push without
prompt:

```bash
BRAG_LOG="$SITREP_REPO/$EMPLOYER/QPR/brag-log.md"
git -C "$SITREP_REPO" add "$LIVE_FILE" "$SNAPSHOT_FILE"
test ! -f "$WEEK_MEM_FILE" || git -C "$SITREP_REPO" add "$WEEK_MEM_FILE"
test ! -f "$BRAG_LOG" || git -C "$SITREP_REPO" add "$BRAG_LOG"
git -C "$SITREP_REPO" commit -m "chore(sitrep): 📸 end $TODAY — {N} done, {M} carried forward"
git -C "$SITREP_REPO" push
```

## QPR season awareness

Once-per-day quarterly-review nudge, never blocking: banner windows, placement,
and brag-log accrual — [`references/qpr-nudge.md`](references/qpr-nudge.md).

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| `/wk-sitrep start` | Gather → compile → verify live.md → commit/push → launch review drafts. |
| Unfinished prior day | `start` runs its full dated `end` flow first; failure blocks today's overwrite. |
| `/wk-sitrep end` | Optional: snapshot → scrub → learn → mark complete → commit/push. |
| `/wk-sitrep` (no arg) | Defaults to `start`. |
| Writes | Re-read target first; preserve `data-done`; prefer `Edit` over full overwrite. |
| End of day | Invoke [`wk-sharpen`](../sharpen/README.md) on up to 5 highest-severity unprocessed learnings. |
| QPR | `📋` banner on live.md (start) / snapshot (end); brag-log accrues 🌟. |
| SilverBullet stopped | Auto-start via `silverbullet $SITREP_REPO &`. |
| Service auth fails | OAuth soft block degrades with CTA; missing required connector aborts + prompts. |
| No previous live.md | Skip carry-over; start fresh. |
| `docker-compose.yml` changed | Restart after push: `docker compose down && docker compose up -d`. |

## Requirements

- Env: `$SITREP_REPO` (workspace repo path), `$EMPLOYER` (org slug for path
  scoping), `$SITREP_PORT` (SilverBullet port, default `3000`), `$GITHUB_ORG`
  (`gh` org scope), `$GITC_ROOT` (local clone root for Stage 7 reviews, default
  `$HOME/gitc`).
- `jq` (dismissed-registry JSON); `silverbullet` CLI able to serve `$SITREP_REPO`.
- MCP servers for Slack, Gmail, Calendar, Granola, Drive, Docs, GitHub, Jira, Lattice.
