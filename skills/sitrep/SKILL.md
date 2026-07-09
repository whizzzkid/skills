---
name: wk-sitrep
description: >-
  Unified daily ops log backed by a SilverBullet workspace — replaces the
  former morning and evening standalone skills. `start` gathers the day's inbox,
  carries forward open items, and writes a live 3-column dashboard you edit in
  the browser. `end` snapshots the day, scrubs done items, and updates brag
  docs. No standalone HTML files — SilverBullet renders everything.
argument-hint: 'start|end'
env-vars:
  - SITREP_REPO
  - EMPLOYER
allowed-tools:
  - Skill
  - Agent
  - Read
  - Write
  - "Bash(date:*)"
  - "Bash(mkdir:*)"
  - "Bash(test:*)"
  - "Bash(ls:*)"
  - "Bash(find:*)"
  - "Bash(command:*)"
  - "Bash(jq:*)"
  - "Bash(sed:*)"
  - "Bash(printf:*)"
  - "Bash(open:*)"
  - "Bash(pgrep:*)"
  - "Bash(silverbullet:*)"
  - "Bash(docker compose:*)"
  - "Bash(gh pr view:*)"
  - "Bash(git rev-parse:*)"
  - "Bash(git add:*)"
  - "Bash(git commit:*)"
  - "Bash(git push:*)"
  - "Bash(git log:*)"
  - "Bash(gh search prs:*)"
  - "Bash(gh search issues:*)"
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
  version: '2026.07.09-172450'
---

# Sitrep

Unified daily ops log backed by a SilverBullet workspace. One persistent live
page → replaces former morning/evening skills. No standalone HTML files, no
per-day live directories; dated snapshots at close.

```
start ──► Bootstrap ──► 5 agents ──► auto-transition ──► live.md (+ standup) ──► open ──► commit/push
end   ──► Read live.md ──► 7 agents ──► snapshot + pending live.md ──► open ──► commit/push
```

## Sub-commands

- `/wk-sitrep start` — workday start routine.
- `/wk-sitrep end` — workday end routine.
- `/wk-sitrep` (no argument) — defaults to `start`; emits:
  > "Running wk-sitrep:start (default — no sub-command specified)"

## Core hard rules

- **HARD RULE — never write outside `$SITREP_REPO/$EMPLOYER/`.** All output is
  scoped to the SilverBullet workspace. Never write `morning.md`, `evening.md`,
  or any sitrep file into cwd or `$WK_SKILLS_HOME`.
- **HARD RULE — no interactive triage.** User resolves items in SilverBullet,
  not chat. Never call `AskUserQuestion` to keep/skip/resolve. Both sub-commands
  are compile-only: gather → render → write → open. Write surfaced items
  unconditionally as `data-done="false"` checkbox spans; user edits the browser
  page directly.
- **HARD RULE — never assert missing without checking.** Before saying "no
  snapshot" or "X not found", run `Read`/`ls`/`find` on the path. If you did not
  check, say "I have not read X", not "X is missing."

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
- Non-actionable content (meeting lines, headers, standup block) is plain text
  or inline markdown.
- Sort by priority/severity, staleness, due date, then undated. Lead with 🔴
  overdue/ASAP, 🟡 due ≤3 days, or 🟢 later/no hard date; append `⏳ {N}d`
  after 7 days pending. Format due dates as `**📅 YYYY-MM-DD**`.
- Keep CSS/Lua in `$EMPLOYER/sitrep-style.md`; never regenerate it daily. After
  style edits, force reload and verify before finishing.

### Checkbox-span format

```html
<span class="st-item"><span class="st-cb" data-t="tN" data-done="false" onclick="var d=this.dataset.done==='true',t=this.dataset.t,q=String.fromCharCode(34);this.dataset.done=String(!d);window.client.space.readPage('$EMPLOYER/live').then(function(pg){var c=pg.text,s='data-t='+q+t+q+' data-done='+q+(d?'true':'false')+q,n='data-t='+q+t+q+' data-done='+q+String(!d)+q;return window.client.space.writePage('$EMPLOYER/live',c.replace(s,n))})"></span> Item text [link](url)</span>
```

## Dismissed registry (cross-run de-dup)

User-resolved items vanish from `live.md` at `end` but the next `start` sweep
can rediscover them. A week-scoped JSONL registry suppresses those keys.

- **File:** `$WEEK_MEM_FILE = $SITREP_REPO/$EMPLOYER/.dismissed/$YEAR-W$WEEK.jsonl`,
  scoped to ISO week (`date +%V`). Defined in Step 0.
- **Key:** one logical action, not one resource. Prefer the most specific URL
  (event, direct scorecard, sub-path anchor). If stages share a URL, append
  `{url}#action=<slug>` so dismissing prep does not suppress follow-up.
- **Write:** `jq`-constructed JSON only; never raw interpolation. Strip
  markdown escapes, validate the file still parses, and remove the last line on
  failure.

```bash
title=$(printf '%s' "$raw_title" | sed 's/\\#/#/g')   # strip markdown escapes
jq -nc --arg key "$key" --arg type "$type" --arg title "$title" \
   --arg at "$TODAY" --arg because "$reason" --arg week "$YEAR-W$WEEK" \
   '{key:$key,type:$type,title:$title,dismissed_at:$at,dismissed_because:$because,week:$week}' \
   >> "$WEEK_MEM_FILE"
if ! jq -r '.key' "$WEEK_MEM_FILE" >/dev/null 2>&1; then
  echo "ERROR: $WEEK_MEM_FILE failed to parse after write — removing last line"
  sed -i '' '$d' "$WEEK_MEM_FILE"
fi
```

- **Filter (`start`):** drop any gathered or carry-over item whose key is in
  this week's registry.

```bash
is_dismissed() { [ -f "$WEEK_MEM_FILE" ] && jq -e --arg k "$1" \
  'select(.key==$k)' "$WEEK_MEM_FILE" >/dev/null 2>&1; }
```

## Step 0: Bootstrap (both sub-commands)

### Verify environment and paths

Resolution order for each key: `.sitrep.yml` at the working repo root → env
var → skill default. The config probe runs first so per-project config can
supply the vars without shell-profile exports.

```bash
# Per-project overrides: .sitrep.yml at the working repo root wins over env/defaults.
_CFG="$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null)/.sitrep.yml"
if [ -f "$_CFG" ]; then
  _yml() { sed -n "s/^$1:[[:space:]]*\"\{0,1\}\([^\"]*\)\"\{0,1\}[[:space:]]*\$/\1/p" "$_CFG"; }
  _v=$(_yml sitrep_repo); [ -n "$_v" ] && SITREP_REPO="$_v"
  _v=$(_yml employer);    [ -n "$_v" ] && EMPLOYER="$_v"
  _v=$(_yml sitrep_port); [ -n "$_v" ] && SITREP_PORT="$_v"
fi

test -n "$SITREP_REPO" || { echo "SITREP_REPO is not set"; exit 1; }
test -n "$EMPLOYER"    || { echo "EMPLOYER is not set"; exit 1; }
SITREP_PORT="${SITREP_PORT:-3000}"

TODAY=$(date +%Y-%m-%d)
YEAR=$(date +%Y); WEEK=$(date +%V)
LIVE_FILE="$SITREP_REPO/$EMPLOYER/live.md"
SNAPSHOT_DIR="$SITREP_REPO/$EMPLOYER/$(date +%Y)/$(date +%m)/$(date +%d)"
SNAPSHOT_FILE="$SNAPSHOT_DIR/snapshot.md"
WEEK_MEM_FILE="$SITREP_REPO/$EMPLOYER/.dismissed/$YEAR-W$WEEK.jsonl"

mkdir -p "$SITREP_REPO/$EMPLOYER" "$SNAPSHOT_DIR" "$(dirname "$WEEK_MEM_FILE")"
```

### Verify SilverBullet is running

```bash
if ! pgrep -f "silverbullet" > /dev/null 2>&1; then
  if command -v silverbullet >/dev/null 2>&1; then
    silverbullet "$SITREP_REPO" &
    sleep 2
  else
    echo "SilverBullet is not installed. Install it, run: silverbullet $SITREP_REPO, then re-run."
    exit 1
  fi
fi
```

## Sub-command: start

### Stage 1: Load previous live.md

- Read `$LIVE_FILE` if it exists. Extract open `data-done="false"` spans as
  carry-over, completed `data-done="true"` spans as a count only.
- Legacy `⬜` / `[ ]` / `✅` / `[x]` forms are read-only compatibility
  fallbacks; canonical state is `data-done`.
- Resolve previous working day from existing `date:` frontmatter. Cross-check
  carry-overs against live external state in Stage 2.
- Read previous working day's snapshot before standup compilation. Resolve
  `$PREV_SNAPSHOT_FILE`; use its `## Achievements / ### Code & PRs` as primary
  Yesterday source. Fall back to session memory only when a filesystem check
  proves the file absent.

### Stage 2: Parallel data gathering

Launch 5 agents in parallel. Prepend this subagent contract verbatim to every
prompt — structured data only, no file writes, prompts, or browser opens:

```
SUBAGENT CONTRACT (mandatory):
- Return STRUCTURED DATA ONLY — do not write files, run git commands, or commit
- Do NOT invoke /skills or act as the orchestrator skill
- Do NOT prompt the user for input — the orchestrator handles all triage
- Do NOT open files in browsers or call `open`
- When research is complete, **actively send all results back** via `SendMessage({to: "main", summary: "<agent-name> results", message: "<your full markdown>"})`. Do NOT just go idle — the orchestrator does not poll; it only receives what you push.
- Your output is markdown text the orchestrator pastes into a section
- EVERY item you return MUST include a `url` field with a clickable
  link to the underlying artifact. Items without `url` are rejected at compile time.
- If no canonical URL resolves, return `link_unavailable: true` with a one-line
  `reason` and the best `{system}:{id}` reference.
- Inferred items still need a URL — link to the source artifact the
  inference came from and tag `(inferred)`.
- Tag each item `verified` (concrete artifact) or `claim` (single-source) — the
  orchestrator styles and conflict-detects by it.
- PROBE TOOLS FIRST: your domain's MCP tools may not be inherited (subagents do NOT reliably get the orchestrator's connectors). Missing → return `tool_unavailable: true` at once; never fail item-by-item.
```

Agent roster:

- **Slack:** unread DMs/mentions needing response; open threads awaiting reply;
  announcements. ToolSearch: `"slack"`.
- **Gmail:** unread emails needing response; sent emails without reply;
  announcements. ToolSearch: `"gmail"`.
- **Calendar + Granola + Google Drive:** today's meetings with agenda docs and
  last-session Granola notes; interview prep blocks. Invoke
  [`wk-cal`](../cal/README.md) §Interview Prep Scan before launching.
  ToolSearch: `"gcal"`, `"granola"`, `"gdrive"`.
- **GitHub:** PRs needing review (`--draft=false`); your open PRs with failing
  CI or review comments; assigned issues; mentions. All `gh` commands require
  `--owner="$GITHUB_ORG"`. ToolSearch: `"github"`.
  - **HARD RULE — verify authorship, never infer it** (see the canonical
    Authorship filter in Stage 4 §Code & PRs). A PR enters "Your PRs" only after
    `gh pr view --json author` confirms it; route review-requested / mentions /
    involvement to other buckets. Prevents teammate/bot PRs surfacing as own.
- **Jira + Confluence:** assigned tickets needing action; ticket mentions;
  Confluence mentions. ToolSearch: `"jira"`, `"confluence"`.

Soft/hard block handling per canonical subagent contract: OAuth soft blocks
degrade with an authorization CTA; missing MCPs are hard blocks. A
`tool_unavailable` return = capability-inheritance failure — re-run that
domain in the main context, not as "nothing found".

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

Every item needs a link or is omitted. FYI-only items render as read-only
bullets. Sort and mark urgency per the rendering contract.

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

Escape `#` in link text, lead each item with an urgency marker, and verify the
render in a browser per
[`wk-silverbullet`](../silverbullet/README.md) Step 6 before finishing.

### Stage 4b: Standup snippet

Render standup in col3 as a copy block:

```html
<div class="st-copy-block"><button class="st-copy-btn" onclick="navigator.clipboard.writeText(this.nextElementSibling.innerText)">Copy</button><pre class="st-standup">{standup text}</pre></div>
```

Delegate formatting to [`wk-slack`](../slack/README.md) §Standup Snippet; this
skill owns selection.

- **Yesterday:** previous snapshot `## Achievements`, top 3–4 wins; never
  reconstruct from memory when the file exists. Apply the canonical Authorship
  filter.
  - Re-confirm each PR's `author.login` via `gh` at compile
    (`gh search prs --author @me --merged --merged-at <range>`) — never trust
    carryover tracking or agent-reported attribution (ships another's merge as
    the user's own).
  - One bullet per win, not a comma-joined line; append each PR's bare URL
    (`<pre>` copy block renders no markdown links; bare URLs auto-link in Slack).
- **Today:** top 3–4 🔴 ASAP items, deadline-first.
- **Blockers:** `BLOCKED` or dependency conflicts; always present — `None` when empty (per [`wk-slack`](../slack/README.md) §Standup Snippet).
- Apply [`wk-slack`](../slack/README.md) §Standup privacy filter — drop
  hiring/interview/candidate, personal HR/performance, or non-public items.
- Use the plaintext fallback exactly: top-level `•` day markers with indented
  `  •` item bullets, one item per line. The emoji leads each day marker —
  `• 👈🏽 Yesterday`, `• 👉🏽 Today`, `• ✋🏽 Blockers` — never trailing.
- Verify `👈🏽` and `👉🏽` survive the write; re-emit via Write if either is
  missing.

### Stage 5: Open in browser

```bash
open "http://localhost:$SITREP_PORT/$EMPLOYER/live.md"
```

Announce:

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

## Sub-command: end

### Stage 1: Read live.md

- Read `$LIVE_FILE`. Extract completed `data-done="true"` spans, open
  `data-done="false"` spans, notes under `## Notes`, standup data. Legacy
  checkbox glyphs are compatibility fallbacks only.
- If `$LIVE_FILE` absent, continue from agents.

### Stage 2: Parallel data gathering

Launch 7 agents in parallel. Include the subagent contract from Stage 2 verbatim.

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

```markdown
---
date: {TODAY}
employer: {EMPLOYER}
generated_with: {SKILL_VERSION}
generated_at: {ISO_8601_UTC}
---

# Snapshot — {TODAY}

## Achievements

### Code & PRs
- {shipped, reviewed, unblocked — strong verbs, with links}

**Authorship filter (canonical):** include a PR as the user's only when
`gh pr view <pr> --json author` confirms author / co-author / primary approving
reviewer — carry-over lists, review queues, and prior agent reports are NOT
proof. Enumerate own PRs via `gh search prs --author @me` (add
`--merged --merged-at <range>` for wins). Applies to "Your PRs", snapshot wins,
and standup alike.

### Meetings & Collaboration
- {decisions led, context shared, people unblocked}

### Communication
- {threads closed, announcements, knowledge shared}

### Feedback
- {given / received}

## Meeting Notes
{per-meeting summaries — decisions made, action items, open questions}

## Issues Created Today
- [{repo}\#{N}: {title}](url)

## DX Metrics
| Metric | You | Team | Org | Trend |
|--------|-----|------|-----|-------|
| Review turnaround | | | | |
| PR cycle time | | | | |
| Deploy frequency | | | | |

## Day Stats
- Completed: {N} items · Meetings: {N} · PRs: {created}/{reviewed}/{merged} · Commits: {N}
```

Append QPR-worthy items to `$SITREP_REPO/$EMPLOYER/QPR/brag-log.md` with `🌟`.

### Stage 5: Rewrite live.md

- Re-read `$LIVE_FILE` immediately before rewriting. Merge completed spans into
  the snapshot done set rather than re-surfacing them.
- Record dismissed keys before scrubbing: for each completed span, write its
  action-specific key to `$WEEK_MEM_FILE` via the Dismissed registry pattern.
- Rewrite `$LIVE_FILE` to hold every pending item. Drop completed spans and
  date-specific FYI content (Calendar, Announcements, standup). Fold pending
  spans plus tomorrow's prep, unresolved follow-ups, Lattice feedback, peer
  feedback opportunities, DX improvements. Re-number `data-t` from `t1`; sort and
  mark urgency per the rendering contract.

```markdown
---
date: {TODAY}
note: "Scrubbed {N} completed items — full record in snapshot"
---

# Live — carry-forward from {TODAY}

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

- **col1 — Tomorrow's Meeting Prep:** meeting lines and prep spans.
- **col2 — Carry-forward + Follow-ups & Feedback + DX:** carry-forward,
  unanswered Slack/email/Jira, Lattice requests, DX actions.
- **col3 — Notes:** preserved free-form notes.

No `.last_working_day` file; `date:` frontmatter is the sole marker.

### Stage 6: Open snapshot in browser

```bash
open "http://localhost:$SITREP_PORT/$EMPLOYER/$(date +%Y)/$(date +%m)/$(date +%d)/snapshot"
```

Announce:

> "Snapshot written: http://localhost:$SITREP_PORT/$EMPLOYER/$(date +%Y)/$(date +%m)/$(date +%d)/snapshot
>
> Today: {N} done ({U} you checked + {D} detected from GitHub/Jira/Calendar/Slack), {M} carried forward, {P} meetings documented.
> {brag_highlight — single most impactful item}
>
> live.md scrubbed — {N} open items remain for tomorrow."

### Stage 7: Commit and push

Commit and push without prompt:

```bash
git -C "$SITREP_REPO" add "$LIVE_FILE" "$SNAPSHOT_FILE" "$WEEK_MEM_FILE"
git -C "$SITREP_REPO" commit -m "chore(sitrep): 📸 end $TODAY — {N} done, {M} carried forward"
git -C "$SITREP_REPO" push
```

### Stage 8: Distill accumulated learnings

If `$WK_SKILLS_HOME` is set and unprocessed learning files exist: process
highest severity first, cap at 5 per run, carry the rest. Invoke
[`wk-sharpen`](../sharpen/README.md) with each file as input. Do not rename
files here; [`wk-sharpen`](../sharpen/README.md) owns `.learned.md` renames.

## QPR season awareness

Surface a quarterly-review nudge once per day; never block on it.

- **`start`:** in QPR prep windows (last 2 weeks of Jan/Apr/Jul/Oct) with recent
  `$SITREP_REPO/$EMPLOYER/QPR/brag-log.md` entries, add a `📋 QPR Prep` banner
  atop `live.md` → [`/wk-self-perf quarter`](../self-perf/README.md).
- **`end`:** in QPR season (Feb/Aug), add a `📋 QPR Season` banner to the
  snapshot → [`/wk-self-perf quarter`](../self-perf/README.md).
- QPR-worthy achievements accrue to `QPR/brag-log.md` with `🌟` year-round.

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| `/wk-sitrep start` | Gather → auto-transition merged PR tickets → compile → write live.md + standup → open → commit/push |
| `/wk-sitrep end` | Gather → write snapshot → rewrite live.md with pending work → open → commit/push |
| `/wk-sitrep` (no arg) | Defaults to `start`. |
| Writes | Re-read target first; preserve `data-done`; prefer `Edit` over full overwrite. |
| Jira | Full open-ticket sweep; collapse inactive/no-due backlog. |
| Pending-on-me | Flag 🔁 status changes + ⏳ staleness; sort priority → age → due-date. |
| Merged PR + open ticket | Auto-transition to Done; render as done auto-action. |
| Resolved item re-discovered | Dismissed registry filters it; `jq`-write + validate; action-specific key. |
| End of day | Invoke [`wk-sharpen`](../sharpen/README.md) on up to 5 highest-severity unprocessed learnings. |
| QPR | `📋` banner on live.md (start) / snapshot (end); brag-log accrues 🌟. |
| SilverBullet stopped | Auto-start via `silverbullet $SITREP_REPO &`. |
| Service auth fails | OAuth soft block degrades with CTA; missing MCP hard-blocks. |
| No previous live.md | Skip carry-over; start fresh. |
| `docker-compose.yml` changed | Restart after push: `docker compose down && docker compose up -d`. |

## Requirements

- Env: `$SITREP_REPO` (workspace repo path), `$EMPLOYER` (org slug for path
  scoping), `$SITREP_PORT` (SilverBullet port, default `3000`), `$GITHUB_ORG`
  (`gh` org scope).
- `jq` (dismissed-registry JSON); `silverbullet` CLI able to serve `$SITREP_REPO`.
- MCP servers for Slack, Gmail, Calendar, Granola, Drive, Docs, GitHub, Jira, Lattice.

## Post-Completion

Invoke [`wk-learn`](../learn/README.md) with this skill's short name as the
argument (for example, [`wk-learn sitrep`](../learn/README.md)).
