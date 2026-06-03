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
  - AskUserQuestion
  - Read
  - Write
  - "Bash(date:*)"
  - "Bash(mkdir:*)"
  - "Bash(cat:*)"
  - "Bash(grep:*)"
  - "Bash(open:*)"
  - "Bash(pgrep:*)"
  - "Bash(silverbullet:*)"
  - "Bash(git log:*)"
  - "Bash(git config:*)"
  - "Bash(gh search prs:*)"
  - "Bash(gh search issues:*)"
  - "Bash(gh api:*)"
  - "Bash(gh issue create:*)"
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
  version: '2026.06.03-200337'
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
start ──► Bootstrap ──► 5 parallel agents ──► Carry-over merge ──► live.md ──► open in browser
end   ──► Read live.md ──► 7 parallel agents ──► Snapshot + scrub ──► open in browser
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
LAST_WD_FILE="$SITREP_REPO/$EMPLOYER/.last_working_day"

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

Resolve yesterday's date from `$LAST_WD_FILE` if it exists; otherwise use the
previous calendar day. Cross-check open items against live external state
during Stage 2 (a checked PR or resolved Jira ticket drops the carry-over).

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
`"jira"`, `"confluence"`.

Soft/hard block handling: same rules as `wk-goodmorning` — OAuth soft
blocks degrade gracefully with an authorization CTA; missing MCP hard blocks
pause everything and require the user to fix before continuing.

### Stage 3: Triage open items

Merge agent results with carry-over items from Stage 1. Cross-check
carry-overs against live state — drop any whose external record shows
completion (PR merged, Jira ticket resolved, email chain closed).

Run interactive triage **one group at a time, max 5 items per prompt**,
with auto-resolution using the weekly memory file at
`$SITREP_REPO/$EMPLOYER/.weekly_memory.md`. Per-item options and the `+m`
modifier follow the same model as `wk-goodmorning` Stage 2a — see that
skill for the full group/option table.

Groups (process in order, skip empty):

1. Carry-over from previous live.md
2. Today's Meeting Prep (from Granola past notes + agenda docs)
3. Slack — Needs Response
4. Slack — Follow-ups
5. Email — Needs Response
6. Email — Follow-ups
7. GitHub — PRs to Review
8. GitHub — Your PRs
9. GitHub — Issues
10. Jira — Tickets
11. Jira — Mentions
12. Confluence — Mentions

Every item MUST have a source URL. FYI-only items (announcements, share-outs)
appear as read-only bullets, never triaged.

### Stage 4: Write live.md

Overwrite `$LIVE_FILE` with today's live page:

```markdown
---
date: {TODAY}
employer: {EMPLOYER}
generated_with: {SKILL_VERSION}
generated_at: {ISO_8601_UTC}
---

# Live — {TODAY}

## Today's Focus
- [ ] {priority 1} [source]
- [ ] {priority 2} [source]
...

## Carry-over from {LAST_WORKING_DAY}
- [ ] {open item from yesterday} [source]
...

## Calendar
### {time} — {meeting title}
- Attendees: {list}
- Last time: {Granola summary or "first occurrence"}
- Agenda: {doc summary or "no doc"}
- Prep: {what to review}

## Slack
### Needs Response
- [ ] #{channel} — @{sender}: {summary} [link]
### Follow-ups
- [ ] {your message, awaiting reply} [link]
### Announcements
- {summary} [link]

## Email
### Needs Response
- [ ] {subject} — {sender} [link]
### Follow-ups
- [ ] {subject} — sent {date}, no reply [link]

## GitHub
### PRs to Review
- [ ] {repo}#{number} — {title} by @{author} [link]
### Your PRs
- [ ] {repo}#{number} — {status} [link]
### Issues
- [ ] {repo}#{number} — {title} [link]

## Jira & Confluence
### Assigned
- [ ] {KEY}: {title} ({status}) [link]
### Mentions
- [ ] {KEY or page}: {summary} [link]

## Notes
_Add anything that comes up during the day._
```

- Triage decisions apply: `[ ]` = will do, `[x]` = already done, omitted = skipped.
- Every checkbox item carries an inline source link.
- Priorities list carries the same inline links as the section items.

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
comments; Confluence mentions.

**Agent 7 — DX:** engineering metrics (review turnaround, cycle time,
deploy frequency) vs team/org averages; improvement actions.

### Stage 3: Interactive resolution

Same model as `wk-goodevening` Stage 3. Groups (in order, skip empty):

1. Tomorrow's Meeting Prep
2. Untracked Action Items
3. Unanswered Slack
4. Unanswered Email
5. Unanswered Jira Comments
6. Unanswered Confluence Mentions
7. Lattice Feedback Requests
8. Peer Feedback Opportunities

Max 5 items per prompt. Auto-resolve via weekly memory
(`$SITREP_REPO/$EMPLOYER/.weekly_memory.md`) then morning `live.md` decisions.

### Stage 4: Write snapshot.md

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
{per-meeting summaries — decisions, action items, open questions}

## Tomorrow's Prep
- [ ] {time} — {meeting}: {prep action}

## Carry-forward
- [ ] {open item from live.md}: {context}

## Feedback Queue
- [ ] {Lattice request}: due {date}

## Issues Created Today
- {repo}#{number}: {title} [link]

## DX Metrics
| Metric | You | Team | Org | Trend |
|--------|-----|------|-----|-------|
| Review turnaround | | | | |
| PR cycle time | | | | |
| Deploy frequency | | | | |

### Improvement Actions for Tomorrow
- [ ] {specific action}: {rationale}

## Day Stats
- Completed: {N} items  ·  Meetings: {N}  ·  PRs: {created}/{reviewed}/{merged}  ·  Commits: {N}
```

Append QPR-worthy items (feature ships, architectural decisions, cross-team
wins, peer recognition) to
`$SITREP_REPO/$EMPLOYER/QPR/brag-log.md` with a `🌟` marker.

### Stage 5: Scrub live.md

Rewrite `$LIVE_FILE` keeping only open (`[ ]`) items. Remove all `[x]` lines
and date-specific sections (Calendar, Announcements, FYIs). Preserve open items
with their source links; group them under a `## Carry-forward` heading for
tomorrow's `start` run to pick up.

```markdown
---
date: {TODAY}
note: "Scrubbed {N} completed items — full record in snapshot"
---

# Live — carry-forward from {TODAY}

## Carry-forward
- [ ] {open item 1} [source]
- [ ] {open item 2} [source]

## Notes
{preserved free-form notes, if any}
```

### Stage 6: Write last_working_day marker

```bash
echo "$TODAY" > "$LAST_WD_FILE"
```

### Stage 7: Open snapshot in browser

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

---

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| `/wk-sitrep start` | Workday start — data gather, triage, write live.md, open browser |
| `/wk-sitrep end` | Workday end — data gather, snapshot, scrub live.md, open browser |
| `/wk-sitrep` (no arg) | Same as `start` (default) |
| SilverBullet stopped | Auto-start via `silverbullet $SITREP_REPO &` |
| Service auth fails | OAuth soft block: degrade with CTA; MCP hard block: stop |
| No previous live.md | Skip carry-over; start fresh |
| Item skipped 2+ days | Offer auto-skip rule in weekly memory |

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
