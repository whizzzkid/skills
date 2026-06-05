---
name: wk-sitrep
description: >-
  Unified daily ops log backed by a SilverBullet workspace — replaces
  wk-goodmorning and wk-goodevening. `start` gathers the day's inbox,
  carries forward open items, and writes a live checkbox page you edit in
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
  version: '2026.06.05-230547'
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
  surfaced item unconditionally as a `[ ]` checkbox.
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
- **Nested checkboxes for multi-step items** — indent `  - [ ]` sub-tasks
  under the parent (e.g., a meeting with prep sub-items).
- **Sort each section** by a composite key: priority/severity (highest
  first), then staleness (longest pending first), then due-date (soonest
  first), then undated. Lead each item with an urgency marker — 🔴
  (overdue/ASAP), 🟡 (due ≤3 days), 🟢 (later / no hard date) — and append
  `⏳ {N}d` when the item has been pending on the user beyond 7 days.
- **Format due-dates** as bold with a 📅 prefix: `**📅 2026-06-08**`.
  Never bury a date in prose — it must be scannable at a glance.

## HARD RULE — restart SilverBullet after a compose change

When this skill (or any run) edits `docker-compose.yml` in `$SITREP_REPO`,
restart the container immediately after `git push` succeeds so the running
service matches the committed config:

```bash
docker compose down && docker compose up -d
docker compose logs --tail=5   # confirm the new config is active
```

## Step 0: Bootstrap (both sub-commands)

### Verify environment

```bash
test -n "$SITREP_REPO" || { echo "SITREP_REPO is not set"; exit 1; }
test -n "$EMPLOYER"    || { echo "EMPLOYER is not set"; exit 1; }
SITREP_PORT="${SITREP_PORT:-3000}"

TODAY=$(date +%Y-%m-%d)
LIVE_FILE="$SITREP_REPO/$EMPLOYER/live.md"
SNAPSHOT_DIR="$SITREP_REPO/$EMPLOYER/$(date +%Y)/$(date +%m)/$(date +%d)"
SNAPSHOT_FILE="$SNAPSHOT_DIR/snapshot.md"

mkdir -p "$SITREP_REPO/$EMPLOYER" "$SNAPSHOT_DIR"
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

- **Open items** — unchecked `[ ]` lines; these become today's carry-over.
- **Completed items** — checked `[x]` lines; surface as a count ("X items
  done yesterday") but do not carry forward.

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
- Render the result as a checked `[x]` item under a `## 🤖 Auto-Actions`
  section with `✅ auto-transitioned to Done by agent` — never as an open
  `[ ]` TODO. No prompt (per the no-triage HARD RULE).

### Stage 3: Compile open items (no triage)

Merge agent results with carry-over items from Stage 1. Cross-check
carry-overs against live state — drop any whose external record shows
completion (PR merged, Jira ticket resolved, email chain closed).

Write every surviving item as a `[ ]` checkbox under its section — no
interactive prompts (per the no-triage HARD RULE). The user triages in the
browser.

Sections (in order, skip empty):

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
agents ran, and the user may have checked items in the browser. Preserve
every `[x]` line; never overwrite a checked item with an unchecked one.
Prefer `Edit` (anchored, fails loudly if the file moved) over a full `Write`
overwrite wherever the structure allows.

Write today's live page:

```markdown
---
date: {TODAY}
employer: {EMPLOYER}
generated_with: {SKILL_VERSION}
generated_at: {ISO_8601_UTC}
---

# Live — {TODAY}

## Today's Focus
- [ ] 🔴 {priority} — [{repo}\#{N}: {title}](url)
- [ ] 🟡 {priority} due **📅 {YYYY-MM-DD}** — [{label}](url)
...

## Carry-over from {PREV_WORKING_DAY}
- [ ] {open item from yesterday} — [{label}](url)
...

## Calendar
### {time} — {meeting title}
- Attendees: {list}
- Last time: {Granola summary or "first occurrence"}
- Agenda: {doc summary or "no doc"}
- [ ] Prep: {what to review}
  - [ ] {sub-task} — [{label}](url)

## Slack
### Needs Response
- [ ] #{channel} — @{sender}: {summary} — [thread](url)
### Follow-ups
- [ ] {your message, awaiting reply} — [thread](url)
### Announcements
- {summary} — [link](url)

## Email
### Needs Response
- [ ] {subject} — {sender} — [mail](url)
### Follow-ups
- [ ] {subject} — sent **📅 {YYYY-MM-DD}**, no reply — [mail](url)

## GitHub
### PRs to Review
- [ ] [{repo}\#{N}: {title}](url) — by @{author}
### Your PRs
- [ ] [{repo}\#{N}: {title}](url) — {status}
### Issues
- [ ] [{repo}\#{N}: {title}](url)

## Jira & Confluence
### Assigned
- [ ] {KEY}: {title} ({status}) — [link](url)
### Mentions
- [ ] {KEY or page}: {summary} — [link](url)

## 📣 Standup Snippet
{see Stage 4b}

## 📝 Notes
_Add anything that comes up during the day._
```

- Every checkbox carries a link; escape `#` in link text (`repo\#N`).
- Lead each item with an urgency marker; sort per the formatting HARD RULE.

### Stage 4b: Standup snippet

Append a `## 📣 Standup Snippet` section just before `## 📝 Notes`. Delegate
formatting to `wk-slack §Standup Snippet`; this skill owns selection.

- **Yesterday** → yesterday's snapshot `## Achievements`, top 3–4 wins.
  Apply the authorship filter (author / co-author / primary approving
  reviewer only — merging another's PR is not an achievement).
- **Today** → today's 🔴 ASAP items, top 3–4, deadline-first.
- **Blockers** → items flagged `BLOCKED` or a dependency conflict; omit the
  heading entirely if none.
- Apply `wk-slack §Standup privacy filter` — drop hiring/interview/candidate
  items, personal HR/performance items, anything not publicly shareable.

```
## 📣 Standup Snippet

- 👈🏽 Yesterday:
   - {achievement} {bare URL}
- 👉🏽 Today:
   - {priority} {bare URL}
- ✋🏽 Blockers:
   - {blocker} {bare URL}
```

Verify `👈🏽` and `👉🏽` survive the write (multi-byte emoji loss check);
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

- **Completed items** — `[x]` lines across all sections.
- **Open items** — `[ ]` lines; these become tomorrow's carry-over.
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

- **Historical** (→ snapshot): completed `[x]` items, meeting notes,
  achievements, feedback received, DX metrics, day stats.
- **Pending** (→ live.md): tomorrow's meeting prep, untracked action items,
  unanswered Slack/email/Jira/Confluence, Lattice feedback requests, peer
  feedback opportunities, DX improvement actions, and every unchecked item
  carried from today's `live.md`.

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
edited it in the browser since Stage 1. Preserve every `[x]` line; merge
newly-checked items into the snapshot's done set rather than re-surfacing
them as open.

Rewrite `$LIVE_FILE` so it holds **every** pending item — the snapshot keeps
none. Drop all `[x]` lines and date-specific FYI sections (Calendar,
Announcements). Fold in every unchecked item plus the pending buckets from
Stage 3: tomorrow's prep, unresolved follow-ups, Lattice feedback, peer
feedback opportunities, DX improvement actions. Sort and mark urgency per
the formatting HARD RULE.

```markdown
---
date: {TODAY}
note: "Scrubbed {N} completed items — full record in snapshot"
---

# Live — carry-forward from {TODAY}

## Tomorrow's Meeting Prep
- [ ] 🔴 {time} — {meeting}: prep
  - [ ] {sub-task} — [{label}](url)

## Carry-forward
- [ ] 🟡 {open item} due **📅 {YYYY-MM-DD}** — [{repo}\#{N}: {title}](url)
- [ ] 🟢 {open item} — [{label}](url)

## Follow-ups & Feedback
- [ ] {unanswered Slack/email/Jira} — [{label}](url)
- [ ] {Lattice request} due **📅 {YYYY-MM-DD}** — [link](url)

## DX Improvement Actions
- [ ] {action} — {rationale}

## 📝 Notes
{preserved free-form notes, if any}
```

There is **no** `.last_working_day` file — the `date:` frontmatter is the
sole working-day marker.

### Stage 6: Open snapshot in browser

```bash
open "http://localhost:$SITREP_PORT/$EMPLOYER/$(date +%Y)/$(date +%m)/$(date +%d)/snapshot"
```

Announce:

> "Snapshot written: http://localhost:$SITREP_PORT/$EMPLOYER/$(date +%Y)/$(date +%m)/$(date +%d)/snapshot
>
> Today: {N} done, {M} carried forward, {P} meetings documented.
> {brag_highlight — single most impactful item}
>
> live.md scrubbed — {N} open items remain for tomorrow."

### Stage 7: Commit and push

Unconditional — no prompt; do not rely on project-level CLAUDE.md.

```bash
git -C "$SITREP_REPO" add "$LIVE_FILE" "$SNAPSHOT_FILE"
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
| Write live.md / snapshot | Re-read the file first; preserve `[x]`; prefer `Edit` over `Write` |
| Jira agent | Full open-ticket sweep, not just today's activity; backlog collapsed |
| Assigned tickets | Cross-tracker sweep: flag 🔁 status changes + ⏳ staleness; sort by priority → age → due-date |
| Merged PR + open ticket | Auto-transition to Done, render as `[x]` auto-action |
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
- `silverbullet` CLI installed and able to serve `$SITREP_REPO`
- All MCP servers required by `wk-goodmorning` / `wk-goodevening`

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn sitrep`).
