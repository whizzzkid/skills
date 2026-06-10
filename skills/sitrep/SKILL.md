---
name: wk-sitrep
description: >-
  Unified daily ops log backed by a SilverBullet workspace — replaces
  wk-goodmorning and wk-goodevening. `start` gathers the day's inbox,
  carries forward open items, and writes a live 3-column dashboard you edit in
  the browser. `end` snapshots the day, scrubs done items, and updates brag
  docs. No HTML generation — SilverBullet renders everything.
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
  - "Bash(cat:*)"
  - "Bash(grep:*)"
  - "Bash(find:*)"
  - "Bash(test:*)"
  - "Bash(jq:*)"
  - "Bash(sed:*)"
  - "Bash(printf:*)"
  - "Bash(open:*)"
  - "Bash(pgrep:*)"
  - "Bash(silverbullet:*)"
  - "Bash(docker compose:*)"
  - "Bash(gh pr view:*)"
  - "Bash(git add:*)"
  - "Bash(git commit:*)"
  - "Bash(git push:*)"
  - "Bash(git log:*)"
  - "Bash(git config:*)"
  - "Bash(gh search prs:*)"
  - "Bash(gh search issues:*)"
  - "Bash(gh api:*)"
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
  version: '2026.06.10-222928'
  model:
    openai: gpt-4.1
    google: gemini-2.5-pro
    meta: llama-4-maverick
    kimi: k2
    qwen: qwen3-235b
    cursor: composer-2
---

# Sitrep

Unified daily operations log. Replaces `wk-goodmorning` + `wk-goodevening`
with a single persistent live page in a SilverBullet workspace — no HTML
generation, no per-day output directories, just a `live.md` page you edit
in the browser throughout the day and a `snapshot.md` at close.

```
start ──► Bootstrap ──► 5 agents ──► auto-transition ──► live.md (+standup) ──► open ──► commit/push
end   ──► Read live.md ──► 7 agents ──► Snapshot (history) + live.md (pending) ──► open ──► commit/push
```

## Sub-commands

- `/wk-sitrep start` — workday start routine (replaces `wk-goodmorning`)
- `/wk-sitrep end` — workday end routine (replaces `wk-goodevening`)
- `/wk-sitrep` (no argument) — defaults to `start`; emits:
  > "Running wk-sitrep:start (default — no sub-command specified)"

**HARD RULE — never write outside `$SITREP_REPO/$EMPLOYER/`.** All output
files are scoped to the SilverBullet workspace. Never write `morning.md`,
`evening.md`, or any sitrep file into the current working directory or
`$WK_SKILLS_HOME`.

## HARD RULE — no interactive triage

The user edits the live page directly in SilverBullet — triage happens in
the document, not in the agent conversation.

- Never call `AskUserQuestion` to keep/skip/resolve items. Write every
  surfaced item unconditionally as a `data-done="false"` checkbox span in
  the appropriate `live.md` column.
- Both sub-commands are compile-only: gather → render → write → open.
- The user resolves, annotates, or deletes items in the browser.

## HARD RULE — SilverBullet markdown formatting

SilverBullet extends CommonMark with inline hashtag parsing that runs over
link text, so unescaped `#` corrupts links.

- **Escape `#` in link text** with `\#` so it renders literally and does
  not trigger the hashtag parser: `[repo\#NNN: title](url)`. An unescaped
  `[repo#NNN](url)` gets mangled into a broken tag node.
- **Use the full PR/issue title** in link text, formatted
  `repo\#N: commit-style title` — never bare `repo\#N` (fragile and
  uninformative).
- **Every checklist item carries a link.** When no canonical URL exists,
  set `link_unavailable: true` in the agent output and omit the item —
  never surface a linkless checkbox.
- **Checkbox syntax (`- [ ]`, nested `  - [ ]`) is for `snapshot.md` and
  other normal pages only** — `live.md` uses HTML `<span>` checkboxes with
  `data-done` attributes per the HTML-layout HARD RULE below. In normal
  pages, indent `  - [ ]` sub-tasks under the parent (e.g., a meeting with
  prep sub-items).
- **Sort each section** by a composite key: priority/severity (highest
  first), then staleness (longest pending first), then due-date (soonest
  first), then undated. Lead each item with an urgency marker — 🔴
  (overdue/ASAP), 🟡 (due ≤3 days), 🟢 (later / no hard date) — and append
  `⏳ {N}d` when the item has been pending on the user beyond 7 days.
- **Format due-dates** as bold with a 📅 prefix: `**📅 2026-06-08**`.
  Never bury a date in prose — it must be scannable at a glance.

## HARD RULE — render live.md as an HTML div 3-column layout

`live.md` is an HTML flexbox layout with interactive `<span>` checkboxes —
NOT a markdown table. Markdown table cells cannot hold SilverBullet's
interactive task widgets, so the table format only ever yielded read-only
⬜/✅ glyphs. The HTML div layout supports `<span onclick>` checkboxes that
persist state to the file.

**Invoke [`wk-silverbullet`](../silverbullet/README.md) for the layout
mechanics** — HTML-block blank-line rule, span-checkbox pattern, onclick
handler, `window.client` API, `space-style` CSS, and force-reload. This
skill owns content selection; `wk-silverbullet` owns rendering.

Both `start` and `end` write `live.md` as frontmatter + `# Live — {DATE}` +
ONE `<div class="sitrep-row">` containing three `<div class="sitrep-col">`.

- **No blank lines inside any `<div>`** — CommonMark ends the HTML block at
  the first blank line, collapsing the layout to one column. Every line
  inside a column is contiguous.
- **Actionable items use `<span class="st-item">` with a nested
  `<span class="st-cb" data-t="tN" data-done="false" onclick="HANDLER">`** —
  never `- [ ]` (renders as literal text in an HTML block) and never
  `<input type="checkbox">` (SilverBullet disables it). See the checkbox-span
  format below.
- **`data-t` is a unique sequential ID per item per page** (`t1`…`tN`) — the
  onclick handler locates the item by this key, so collisions toggle the
  wrong item.
- **Auto-action items already done at generation** start `data-done="true"`.
  Nested sub-items use `class="st-item st-nested"`.
- **Non-actionable content** (meeting lines, section headers, the standup
  block) is plain text / inline markdown — no checkbox span.
- **Escape `#` as `\#` in link text** (already required above) — a broken
  link spills its raw URL and overlaps the column.
- **Styling is stable infra, not daily output.** Keep all CSS/Lua in a
  separate `#meta` page `$EMPLOYER/sitrep-style.md`; never regenerate it
  daily — only rewrite `live.md`. That page holds the `space-style` block
  (flexbox `.sitrep-row`/`.sitrep-col`, `.st-cb`/`.st-item` checkbox styling,
  `.st-item + br { display: none }`, `.sb-frontmatter { display: none }`,
  full-width `--editor-width`, neon-dark scoped to `html[data-theme="dark"]`)
  and a `space-lua` block forcing dark at boot.
- **After editing the style page, force a reload and screenshot to confirm**
  — never assume CSS applied (per `wk-silverbullet` Step 4 + Step 6).

### Checkbox-span format

```html
<span class="st-item"><span class="st-cb" data-t="tN" data-done="false" onclick="var d=this.dataset.done==='true',t=this.dataset.t,q=String.fromCharCode(34);this.dataset.done=String(!d);window.client.space.readPage('$EMPLOYER/live').then(function(pg){var c=pg.text,s='data-t='+q+t+q+' data-done='+q+(d?'true':'false')+q,n='data-t='+q+t+q+' data-done='+q+String(!d)+q;return window.client.space.writePage('$EMPLOYER/live',c.replace(s,n))})"></span> Item text [link](url)</span>
```

## HARD RULE — restart SilverBullet after a compose change

When this skill (or any run) edits `docker-compose.yml` in `$SITREP_REPO`,
restart the container immediately after `git push` succeeds so the running
service matches the committed config:

```bash
docker compose down && docker compose up -d
docker compose logs --tail=5   # confirm the new config is active
```

## Dismissed registry (cross-run de-dup)

Items the user resolves vanish from `live.md` at `end`, but the next
`start`'s fresh agent sweep re-discovers the same Slack thread, PR, or prep
block and re-surfaces it. A week-scoped `.jsonl` registry records dismissed
keys so `start` filters them out.

- **File:** `$WEEK_MEM_FILE` —
  `$SITREP_REPO/$EMPLOYER/.dismissed/$YEAR-W$WEEK.jsonl`, one JSON object per
  line, scoped to the ISO week (`date +%V`). Defined in Step 0.
- **Key — one logical action, not one resource.** Use the most
  action-specific URL available (calendar event, direct scorecard link,
  sub-path anchor) over a shared resource root. When distinct workflow stages
  share a resource URL (prep → attend → debrief → scorecard), append a
  deterministic action slug: `{url}#action=<slug>`.
  - A bare resource URL collapses separate stages into one entry — dismissing
    prep silently suppresses the still-open follow-up.
- **Write — `jq`-constructed only, never raw interpolation.** Strip markdown
  escapes, build the object with `jq -n`, then validate the file still parses;
  roll back the last line on failure.
  - Bash interpolation into JSON strings produces invalid JSON when a title
    carries a non-JSON escape (e.g. SilverBullet's `\#` link-text escape), and
    every subsequent `jq` read fails — silently disabling the whole filter.

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

- **Filter (`start`):** drop any gathered or carry-over item whose key is
  already in this week's registry.

```bash
is_dismissed() { [ -f "$WEEK_MEM_FILE" ] && jq -e --arg k "$1" \
  'select(.key==$k)' "$WEEK_MEM_FILE" >/dev/null 2>&1; }
```

## Step 0: Bootstrap (both sub-commands)

### Verify environment

```bash
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
pgrep -f "silverbullet" > /dev/null 2>&1 && echo "running" || echo "stopped"
```

- If stopped, start it:

  ```bash
  silverbullet "$SITREP_REPO" &
  sleep 2
  ```

- If `silverbullet` is not installed, stop and report:

  > "SilverBullet is not running at `$SITREP_REPO`. Install it and run
  > `silverbullet $SITREP_REPO`, then re-run."

---

## Sub-command: start

### Stage 1: Load previous live.md

Read `$LIVE_FILE` if it exists and extract:

- **Open items** — `data-done="false"` spans (or legacy ⬜ / `[ ]` lines);
  these become today's carry-over.
- **Completed items** — `data-done="true"` spans (or legacy ✅ / `[x]`
  lines); surface as a count ("X items done yesterday") but do not carry
  forward.

Resolve the previous working day from the existing `live.md` frontmatter
`date:` field (it still holds the last run's date until this run overwrites
it). There is no separate marker file. Cross-check open items against live
external state during Stage 2 (a checked PR or resolved Jira ticket drops
the carry-over).

### Stage 2: Parallel data gathering

Launch 5 agents in parallel. Include the **subagent contract** from
`skills/goodmorning/references/subagent-contract.md` verbatim at the start
of every agent prompt — subagents return structured data only; they do not
write files, prompt the user, or open browsers.

See `skills/goodmorning/SKILL.md` Stages 1–2 for the full agent specs.
The following is a summary of what each agent returns:

**Agent 1 — Slack:** unread DMs and mentions needing response; your open
threads awaiting reply; announcements (last 24h). ToolSearch: `"slack"`.

**Agent 2 — Gmail:** unread emails needing response; sent emails without
reply; org-wide announcements. ToolSearch: `"gmail"`.

**Agent 3 — Calendar + Granola + Google Drive:** today's meetings with
agenda docs and last-session Granola notes; interview prep blocks (invoke
`wk-cal §Interview Prep Scan` before launching). ToolSearch: `"gcal"`,
`"granola"`, `"gdrive"`.

**Agent 4 — GitHub:** PRs needing review (`--draft=false`); your open PRs
with failing CI or review comments; assigned issues; mentions. All `gh`
commands require `--owner="$GITHUB_ORG"`. ToolSearch: `"github"`.

**Agent 5 — Jira + Confluence:** assigned tickets needing action; ticket
mentions awaiting reply; Confluence mentions and announcements. ToolSearch:
`"jira"`, `"confluence"`. Run the **full open-ticket sweep** (below), not
just today's activity.

Soft/hard block handling: same rules as `wk-goodmorning` — OAuth soft
blocks degrade gracefully with an authorization CTA; missing MCP hard blocks
pause everything and require the user to fix before continuing.

#### Jira full open-ticket sweep

The today's-activity queries miss the ambient backlog. Always run a third
JQL for **all** open assigned tickets:

```
assignee = currentUser() AND statusCategory != Done ORDER BY updated DESC
```

- Surface in the daily checklist: tickets `In Review` / `Ready for Review`
  / `Blocked` / `On Deck`, any with a past-due date, and any whose linked
  PR merged but the ticket is still open (transition candidates).
- Collapse no-activity / no-due-date tickets into a `## 🗂 Jira backlog`
  section — present once, not as actionable checkboxes.

#### Cross-tracker pending-on-me sweep

The per-tracker agents (GitHub, Jira, and any other connected tracker —
e.g. Asana, Linear) each return assigned items. Fold them into one
pending-on-me view with status-change and staleness detection before
compiling:

- **Flag status changes since the last run.** Compare each carry-over
  item's current status against the status recorded in the previous
  `live.md` (Jira items carry `({status})`). Prefix changed items with
  `🔁 {old}→{new}` (e.g. `In Progress→Blocked`) so transitions are visible.
- **Flag staleness.** Compute `age = today − (assigned-date or
  last-status-change)`; append `⏳ {N}d` to any item pending on the user
  beyond 7 days so long-stalled work surfaces.
- **Read priority/severity** from each tracker's native field — Jira
  `priority`, GitHub `P0` / `severity:*` labels, the tracker's equivalent.
  Items with no priority field sort lowest.
- **Apply to every connected tracker**, not just Jira. Skip a tracker only
  when its MCP is absent (soft block — degrade with a CTA, never silently
  drop the tracker).

### Stage 2b: Auto-transition merged-PR tickets

Run after the agents return, before writing live.md — close the loop on
tickets the user already finished:

- For each Agent 5 ticket with `status` in `In Review` / `Ready for Review`
  and a linked PR, check merge state: `gh pr view <url> --json state,merged,mergedAt`.
- When the PR is `merged: true` within the last 14 days, fetch the
  project's transitions and `transitionJiraIssue` the ticket to `Done`.
- Render the result as a ✅ item under the **⚙️ Auto-Actions** sub-header
  (col2) with `✅ auto-transitioned to Done by agent` — never as an open
  ⬜ TODO. No prompt (per the no-triage HARD RULE).

### Stage 3: Compile open items (no triage)

Merge agent results with carry-over items from Stage 1. Cross-check
carry-overs against live state — drop any whose external record shows
completion (PR merged, Jira ticket resolved, email chain closed).

Then drop any gathered or carry-over item whose key `is_dismissed` for the
current week (per the Dismissed registry section) — this suppresses items the
user already resolved in a prior run that the fresh sweep re-discovered.

Write every surviving item as a `data-done="false"` checkbox span in the
appropriate column per the HTML-layout HARD RULE — no interactive prompts
(per the no-triage HARD RULE). The user triages in the browser.

Content inventory (gather all; map to columns per the HTML-layout HARD RULE;
skip empty):

1. Carry-over from previous live.md
2. Today's Meeting Prep (from Granola past notes + agenda docs)
3. Slack — Needs Response / Follow-ups
4. Email — Needs Response / Follow-ups
5. GitHub — PRs to Review / Your PRs / Issues
6. Jira — Tickets / Mentions
7. Confluence — Mentions

Every item MUST have a link or be omitted (`link_unavailable: true`).
FYI-only items (announcements, share-outs) render as read-only bullets.
Sort and mark urgency per the formatting HARD RULE.

### Stage 4: Write live.md

**Re-read `$LIVE_FILE` immediately before writing** — minutes elapsed while
agents ran, and the user may have toggled items in the browser. Preserve
every `data-done="true"` span; never overwrite a done item with a pending
one. Prefer `Edit` (anchored, fails loudly if the file moved) over a full
`Write` overwrite wherever the structure allows.

Write today's live page as ONE `<div class="sitrep-row">` of three
`<div class="sitrep-col">` per the HTML-layout HARD RULE. NO blank lines
inside any `<div>`. Assign each actionable item a unique sequential
`data-t` (`t1`…`tN`).

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

Use the checkbox-span format from the HARD RULE for every `⬜` item below
(`HANDLER` = the onclick from that section); section headers and meeting
lines are plain inline markdown.

- **col1 — Calendar + Slack + Email:** `**🗓 Calendar**` · meeting lines
  (plain) · `Prep` checkbox spans · `**💬 Slack**` needs-response checkbox
  spans + awaiting-reply follow-ups · `📣` announcements (plain) ·
  `**📧 Email**` needs-response checkbox spans.
- **col2 — ASAP + Auto-Actions + GitHub + Jira:** `**🔴 ASAP**` checkbox
  spans (urgency marker inline) · `**⚙️ Auto-Actions**` items as
  `data-done="true"` spans · `**🐙 GitHub**` PRs-to-review / your-PRs
  checkbox spans · `**📋 Jira**` ticket + mention checkbox spans.
- **col3 — Meta + Standup + This Week + Notes + Backlog:**
  `<div class="st-meta">📅 {DATE} · {EMPLOYER} · {SKILL_VERSION} · {HH:MM} UTC</div>`
  · `**📣 Standup Snippet**` copy block (see Stage 4b) · `**📆 This Week**`
  goal spans · `**📝 Notes**` placeholder · `**🗂 Backlog (carry-over from
  {PREV_WORKING_DAY})**` checkbox spans.

- Every item carries a link; escape `#` in link text (`repo\#N`).
- Lead each item with an urgency marker; sort per the formatting HARD RULE.
- Verify the render in a browser per `wk-silverbullet` Step 6 before finishing.

### Stage 4b: Standup snippet

Render the standup inside col3 as a copy block — a `<pre>` (selectable
monospace) with a Copy button. The `<pre>` renders inline in an HTML block;
a `<button>` is NOT disabled the way `<input>` is, so the copy onclick works.
Delegate snippet formatting to `wk-slack §Standup Snippet`; this skill owns
selection.

```html
<div class="st-copy-block"><button class="st-copy-btn" onclick="navigator.clipboard.writeText(this.nextElementSibling.innerText)">Copy</button><pre class="st-standup">{standup text}</pre></div>
```

- **Yesterday** → yesterday's snapshot `## Achievements`, top 3–4 wins.
  Apply the authorship filter (author / co-author / primary approving
  reviewer only — merging another's PR is not an achievement).
- **Today** → today's 🔴 ASAP items, top 3–4, deadline-first.
- **Blockers** → items flagged `BLOCKED` or a dependency conflict; omit the
  line entirely if none.
- Apply `wk-slack §Standup privacy filter` — drop hiring/interview/candidate
  items, personal HR/performance items, anything not publicly shareable.
- Standup text inside the `<pre>` follows `wk-slack §Standup Snippet`'s
  plaintext fallback exactly: day markers are top-level `•` bullets, every
  achievement/priority/blocker is its own indented `  •` sub-bullet. One item
  per line — never concatenate multiple items on one line with `·` or any
  separator, and never render a day marker as a bare label.

  ```
  • 👈🏽 Yesterday:
    • {achievement} {bare URL}
    • {achievement} {bare URL}
  • 👉🏽 Today:
    • {priority} {bare URL}
  • ✋🏽 Blockers:
    • {blocker} {bare URL}
  ```

- Verify `👈🏽` and `👉🏽` survive the write (multi-byte emoji loss check);
  re-emit via the Write tool if either is missing.

### Stage 5: Open in browser

```bash
open "http://localhost:$SITREP_PORT/$EMPLOYER/live.md"
```

This step is unconditional — runs in auto mode without exception.

Announce:

> "Live page ready: http://localhost:$SITREP_PORT/$EMPLOYER/live.md
>
> {X} items to action, {Y} meetings today, {Z} carry-overs from yesterday.
> Check off items in the browser as you go — they sync to `$LIVE_FILE`."

### Stage 6: Commit and push

Unconditional — same as the browser-open step, no prompt. The skill is
self-contained; do not rely on project-level CLAUDE.md to commit output.

```bash
git -C "$SITREP_REPO" add "$LIVE_FILE"
git -C "$SITREP_REPO" commit -m "chore(sitrep): 📋 start $TODAY — {N} items, {M} meetings"
git -C "$SITREP_REPO" push
```

Fold any auto-actions (Jira transitions) into the same commit, or a
follow-up `chore(sitrep): ✅ {action}`.

---

## Sub-command: end

### Stage 1: Read live.md

Read `$LIVE_FILE`. Extract:

- **Completed items** — `data-done="true"` spans (or legacy ✅ / `[x]`
  lines) across all columns.
- **Open items** — `data-done="false"` spans (or legacy ⬜ / `[ ]` lines);
  these become tomorrow's carry-over.
- **Notes** — free-form content under `## Notes`.
- **Standup data** — today's focus and meetings for the brag doc.

If `$LIVE_FILE` does not exist, note this; continue — data will come from
the parallel agents.

### Stage 2: Parallel data gathering

Launch 7 agents in parallel. Include the subagent contract from
`skills/goodmorning/references/subagent-contract.md` verbatim.

See `skills/goodevening/SKILL.md` Stage 1 for the full agent specs.
Summary of what each returns:

**Agent 1 — GitHub/git:** today's commits, PRs created/merged/reviewed,
issues closed. Requires `$GITHUB_ORG`.

**Agent 2 — Calendar + Granola:** today's meetings with key decisions,
action items, open questions; tomorrow's meetings flagged for prep.

**Agent 3 — Slack:** unanswered DMs/mentions from today; your notable
contributions (decisions communicated, threads unblocked).

**Agent 4 — Gmail:** unreplied emails; your notable outgoing emails.

**Agent 5 — Lattice:** pending feedback requests with deadlines; new
feedback received.

**Agent 6 — Jira + Confluence:** Jira activity today; unanswered Jira
comments; Confluence mentions. Also run the **full open-ticket sweep**
(`assignee = currentUser() AND statusCategory != Done`) — surface
actionable statuses (In Review / Blocked / On Deck), past-due tickets, and
merged-PR-but-open transition candidates; collapse the rest into a backlog
section.

**Agent 7 — DX:** engineering metrics (review turnaround, cycle time,
deploy frequency) vs team/org averages; improvement actions.

### Stage 3: Compile (no triage)

Merge agent results into two buckets — no interactive prompts (per the
no-triage HARD RULE):

- **Historical** (→ snapshot): done items — `data-done="true"` spans in
  `live.md` — plus meeting notes, achievements, feedback received, DX
  metrics, day stats.
- **Pending** (→ live.md): tomorrow's meeting prep, untracked action items,
  unanswered Slack/email/Jira/Confluence, Lattice feedback requests, peer
  feedback opportunities, DX improvement actions, and every pending
  (`data-done="false"`) span carried from today's `live.md`.

Detect done vs pending by the `data-done` attribute — NOT `✅`/`⬜` glyphs or
`[x]`/`[ ]` syntax (those no longer exist in this format). Extract each item's
display text from the span's trailing content.

**Cross-validate `data-done="false"` items against external state before
treating them as carry-over.** The user often actions an item without toggling
its checkbox in the browser, so `data-done` undercounts completions. For each
pending span, check whether the Stage 2 agents' data shows it already done:

- GitHub — the item's PR/issue is merged or closed.
- Jira — the linked ticket moved to a Done status category.
- Calendar — a prep item whose meeting already occurred (attended).
- Slack — the referenced thread was replied to.

Move every externally-confirmed item to the Historical bucket as done. In the
Stage 6 summary, report detected-done vs user-checked-done counts separately so
the user sees what was inferred. When evidence is ambiguous, leave the item
pending — never fabricate a completion.

The user resolves everything in the browser. Drop any item with no link.

### Stage 4: Write snapshot.md

**Snapshot is a historical record only** — completed `[x]` items, meeting
notes, achievements, DX metrics, day stats. **Never write a pending `[ ]`
item into the snapshot** — all pending work goes to live.md (Stage 5).

**Idempotency:** if `$SNAPSHOT_FILE` already exists (a second `end` run the
same day), re-read it and merge — append newly-completed items and meeting
notes rather than blindly overwriting. Never drop achievements captured by
the earlier run.

Write to `$SNAPSHOT_FILE`:

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

**Authorship filter:** include a PR only when the user is the author,
co-author, or primary approving reviewer. Merging another person's PR
is a maintenance action — omit it.

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

(DX improvement actions are pending work — they go to live.md, not here.)

## Day Stats
- Completed: {N} items  ·  Meetings: {N}  ·  PRs: {created}/{reviewed}/{merged}  ·  Commits: {N}
```

Append QPR-worthy items (feature ships, architectural decisions, cross-team
wins, peer recognition) to
`$SITREP_REPO/$EMPLOYER/QPR/brag-log.md` with a `🌟` marker.

### Stage 5: Rewrite live.md (owns all pending work)

**Re-read `$LIVE_FILE` immediately before rewriting** — the user may have
edited it in the browser since Stage 1. Merge `data-done="true"` spans into
the snapshot's done set rather than re-surfacing them as open.

**Record dismissed keys before scrubbing.** For each `data-done="true"` span
being dropped, write its key to `$WEEK_MEM_FILE` via the Dismissed registry
write pattern (action-specific key, `jq`-constructed, validate-on-write) so
the next `start`'s fresh sweep does not re-surface the resolved item.

Rewrite `$LIVE_FILE` so it holds **every** pending item — the snapshot keeps
none. Drop all `data-done="true"` spans and date-specific FYI content
(Calendar, Announcements, the standup block). Fold in every pending
(`data-done="false"`) span plus the pending buckets from Stage 3: tomorrow's
prep, unresolved follow-ups, Lattice feedback, peer feedback opportunities,
DX improvement actions. Re-number `data-t` sequentially from `t1`. Sort and
mark urgency per the formatting HARD RULE.

Rewrite as the same HTML div 3-column layout per the HTML-layout HARD RULE —
checkbox spans, NO blank lines inside any `<div>`:

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

- **col1 — Tomorrow's Meeting Prep:** `**🗓 Tomorrow's Meeting Prep**` ·
  meeting lines (plain) · prep checkbox spans.
- **col2 — Carry-forward + Follow-ups & Feedback + DX:** `**📌 Carry-forward**`
  checkbox spans · `**🔁 Follow-ups & Feedback**` checkbox spans (unanswered
  Slack/email/Jira, Lattice requests) · `**🛠 DX Improvement Actions**`
  checkbox spans.
- **col3 — Notes:** `**📝 Notes**` + preserved free-form notes (plain).

There is **no** `.last_working_day` file — the `date:` frontmatter is the
sole working-day marker.

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

Unconditional — no prompt; do not rely on project-level CLAUDE.md.

```bash
git -C "$SITREP_REPO" add "$LIVE_FILE" "$SNAPSHOT_FILE" "$WEEK_MEM_FILE"
git -C "$SITREP_REPO" commit -m "chore(sitrep): 📸 end $TODAY — {N} done, {M} carried forward"
git -C "$SITREP_REPO" push
```

### Stage 8: Distill accumulated learnings

End-of-day mirror of `wk-goodevening` Stage 5 — fold the day's skill
learnings before they pile up. Skip silently if `$WK_SKILLS_HOME` is unset
or no unprocessed files exist.

```bash
test -n "$WK_SKILLS_HOME" && \
  find "$WK_SKILLS_HOME/learnings/skills" -name "*.md" \
    ! -name "*.learned.md" -type f 2>/dev/null | head -20
```

- For each unprocessed learning, invoke `wk-sharpen` with the file as input.
- Process highest-severity first; cap at 5 per run, carry the rest.
- `wk-sharpen` renames each absorbed file to `.learned.md` — do not rename
  here.

## QPR season awareness

Surface a quarterly-review nudge once per day during QPR windows; never
block on it.

- **`start`** — when today is in a QPR prep window (the last two weeks of
  Jan / Apr / Jul / Oct) AND `$SITREP_REPO/$EMPLOYER/QPR/brag-log.md` has
  recent entries, add a `📋 QPR Prep` banner atop live.md pointing to
  `/wk-self-perf quarter`.
- **`end`** — during QPR seasons (Feb / Aug), add a `📋 QPR Season` banner
  to the snapshot reminding the user to capture the day's achievements via
  `/wk-self-perf quarter`.
- QPR-worthy achievements continue to accrue to `QPR/brag-log.md` with a
  `🌟` marker (Stage 4) regardless of season.

---

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| `/wk-sitrep start` | Gather → auto-transition merged-PR tickets → compile → write live.md (+ standup) → open → commit/push |
| `/wk-sitrep end` | Gather → snapshot (historical) → rewrite live.md (pending) → open → commit/push |
| `/wk-sitrep` (no arg) | Same as `start` (default) |
| Write live.md / snapshot | Re-read first; preserve completed items (✅ in live.md, `[x]` in snapshot); prefer `Edit` over `Write` |
| Jira agent | Full open-ticket sweep, not just today's activity; backlog collapsed |
| Assigned tickets | Cross-tracker sweep: flag 🔁 status changes + ⏳ staleness; sort by priority → age → due-date |
| Merged PR + open ticket | Auto-transition to Done, render as ✅ auto-action |
| Resolved item re-discovered | Dismissed registry filters it out; `jq`-write + validate, action-specific key |
| End of day | Distill unprocessed learnings via `wk-sharpen` (Stage 8) |
| QPR window/season | `📋` banner on live.md (start) / snapshot (end); brag-log accrues 🌟 |
| SilverBullet stopped | Auto-start via `silverbullet $SITREP_REPO &` |
| Service auth fails | OAuth soft block: degrade with CTA; MCP hard block: stop |
| No previous live.md | Skip carry-over; start fresh |
| docker-compose.yml changed | `docker compose down && up -d` after push |

## Requirements

- `$SITREP_REPO` — path to the SilverBullet workspace repo
- `$EMPLOYER` — org slug used for path scoping (e.g., `acme`)
- `$SITREP_PORT` — SilverBullet port (default: `3000`)
- `$GITHUB_ORG` — org scope for `gh` commands
- `jq` — JSON construction/validation for the dismissed registry
- `silverbullet` CLI installed and able to serve `$SITREP_REPO`
- All MCP servers required by `wk-goodmorning` / `wk-goodevening`

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn sitrep`).
