---
name: wk-goodevening
description: >-
  Wrap up your workday — review morning progress, write a brag document of
  the day's achievements, capture meeting learnings from Granola, check
  Lattice for pending feedback requests, surface peer feedback opportunities
  from today's interactions, track unfinished action items as GitHub/Jira
  issues, audit unanswered Slack and email messages, and create an
  evening.md for tomorrow's morning brief. Use at the end of your workday.
model-invocable: false
user-invocable: true
allowed-tools:
  - Skill
  - Agent
  - AskUserQuestion
model: sonnet
effort: medium
license: MIT
group: rituals
metadata:
  author: whizzzkid
  version: '2026.05.13-003212'
  model:
    openai: gpt-4.1
    google: gemini-2.5-pro
    meta: llama-4-maverick
    kimi: k2
    qwen: qwen3-235b
    cursor: composer-2
---

# Good Evening

Daily wrap-up skill that reviews your day, documents achievements, captures
meeting insights, ensures nothing falls through the cracks, and prepares
context for tomorrow. Every surfaced item offers clear triage options
including skip and mark-as-done.

```
Bootstrap ──► Parallel Fetch ──► Compile + Auto-resolve ──► Group-by-group ──► evening.md
               (7 agents)        (use morning.md to           (≤5 items/prompt,
                                  pre-answer repeats)          one group at a time)
```

---

## Stage 0: Bootstrap

### Determine dates and paths

```bash
TODAY=$(date +%Y-%m-%d)

# Today: sitrep/<YYYY>/<MM>/<DD>/
TODAY_DIR="$PWD/sitrep/$(date +%Y)/$(date +%m)/$(date +%d)"
MORNING_FILE="$TODAY_DIR/morning.md"

# Weekly memory: sitrep/<YYYY>/<MM>/week-<WW>-memory.md
WEEK_NUM=$(date +%V)
MONTH_DIR="$PWD/sitrep/$(date +%Y)/$(date +%m)"
WEEK_MEMORY="$MONTH_DIR/week-${WEEK_NUM}-memory.md"
```

### Idempotency check — has today's wrap-up already been generated?

Before doing any data fetch or triage, check whether today's output
artifacts already exist:

```bash
test -f "$TODAY_DIR/evening.md" || test -f "$TODAY_DIR/evening.html"
```

If either exists, read its **generator version** from the frontmatter
(see "Brief versioning" below — markdown YAML `generated_with:`, HTML
`<meta name="generated-with-version">`). Compare against this skill's
current `metadata.version`:

| Stored version | Action |
|----------------|--------|
| Missing (legacy file, no annotation) | Treat as older — prompt to regenerate. |
| **Older** than current | **Auto-regenerate** without prompting. The skill has improved since this wrap-up was written; the user wants the new behavior. Announce: "Today's wrap-up was generated with v{stored}; current is v{current}. Regenerating." |
| **Equal or newer** | Prompt the user (existing flow below) — re-running is expensive (7 parallel agents, MCP auth, draft review) and would overwrite the brag document, carry-over decisions, and hand-curated notes that tomorrow's `wk-goodmorning` will read. |

CalVer ordering is lexicographic (`YYYY.MM.DD-HHMMSS` UTC), so a plain
string compare is correct: `[ "$STORED" \< "$CURRENT" ]` means stored
is older.

Read the existing `evening.md` and surface a short summary for the
prompt path:
- Generation timestamp (file mtime)
- Generator version (from frontmatter)
- Achievement counts (PRs shipped, meetings documented, feedback given)
- Carry-over count and unresolved items
- Any issues created today

Then prompt (only when stored version is equal/newer):

> "Today's evening wrap-up already exists at
> `sitrep/{YYYY}/{MM}/{DD}/evening.md` (generated {mtime} with
> v{stored}, {A} achievements, {C} carry-overs).
>
> **(a)** Open the existing wrap-up — no regeneration
> **(b)** Regenerate from scratch — overwrites current files and
>     re-runs all 7 agents
> **(c)** Cancel
>
> Reply with your choice."

| Choice | Behavior |
|--------|----------|
| (a) | `open "$TODAY_DIR/evening.html"` and exit. Skip all remaining stages. |
| (b) | Continue to Stage 1. The user has explicitly accepted overwrite. |
| (c) | Exit silently. |

Auto mode does **not** exempt the consultation gate — silently overwriting today's
wrap-up loses the day's documented achievements. When the prompt path is reached in
auto mode and the only viable option is obvious (e.g., an equal/newer version exists
and overwriting would destroy hand-edited brag notes with no upside), default to **(a)**
and note the skip in the run summary. The auto-regenerate-on-older-version path runs
in auto mode without prompting (the version delta is itself the user's prior consent).

### Read the morning brief

If `morning.md` exists, read it in full. This is the baseline — the items
planned for today. Store it as the `morning_baseline` dataset.

Also extract the **triage decisions** from the morning session — which
items were marked "Will do" (unchecked `[ ]`), "Already done"
(checked `[x]`), and which were omitted (skipped). Store these as the
`morning_decisions` map keyed by item summary/identifier. These are used
in Stage 3 to auto-resolve repeat items.

If it does not exist, note this. The evening summary is still valuable
without a morning brief — Stage 1 gathers fresh context.

### Load weekly memory

Read `$WEEK_MEMORY` if it exists. This file contains **recurring triage
rules** — items the user has consistently skipped or marked done across
multiple days this week. Weekly memory rules take priority over daily
`morning_decisions` during auto-resolution in Stage 3.

Store the parsed rules as the `week_rules` dataset (list of
`{pattern, source, action, reason, since}` entries).

If the file does not exist, `week_rules` is empty — this is not an error.

**Note:** Unlike goodmorning, goodevening does NOT perform new-week
rollover. That happens in the morning session when the user is fresh.
Goodevening only reads the weekly memory; goodmorning owns the rollover.

---

## Stage 1: Parallel Data Gathering

**Launch 7 agents in parallel** using the Agent tool. Each agent handles
its own MCP authentication independently. If any agent fails to
authenticate, it returns a skip notice — it does not block the others.

### Subagent contract and MCP pattern

> See [`skills/goodmorning/references/subagent-contract.md`](../goodmorning/references/subagent-contract.md)
> for the canonical subagent contract, MCP soft/hard block pattern, `+m` modifier table,
> and pattern-extraction table. Include the full contract verbatim at the start of every
> Stage 1 agent prompt; substitute `wk-goodevening` for the orchestrator name.

Before compiling outputs in Stage 2, the orchestrator must verify git state (no
unexpected commits, no uncommitted files outside the session's intended sitrep paths)
— a subagent that overran its scope will show up here. If any subagent wrote files or
committed, discard its output and re-dispatch with the contract emphasized.

For soft blocks, use the most recent available brief (morning.md or yesterday's
evening.md) as fallback data and embed the authorization URL as a prominent
**⚠ Authorize {Service}** CTA.

---

### Agent 1: Code + GitHub Activity

Gathers all code and PR activity for the brag document. No MCP needed —
uses git and `gh` CLI directly.

**Run all in parallel:**

**IMPORTANT:** Before running any `gh` command, check that `$GITHUB_ORG`
is set (see `wk-gh`). All search commands MUST include
`--owner="$GITHUB_ORG"`.

Draft/WIP PRs are fine to include in the **brag document** (creating a
draft is still a day's work), but must be excluded from any **action
items** derived from GitHub — a draft is not ready for review, so it
doesn't belong in tomorrow's triage. When carrying a PR forward as an
action item (e.g., unfinished morning carry-over), confirm the PR is
not a draft before re-surfacing it.

```bash
# Today's commits (all repos in cwd)
git log --all --author="$(git config user.email)" --since="$TODAY 00:00" \
  --format="%h %s"

# PRs merged today
gh search prs --owner="$GITHUB_ORG" --author=@me --merged --updated=">=$TODAY" \
  --json title,url,repository,mergedAt

# PRs created today (brag doc — include drafts, flag them)
gh search prs --owner="$GITHUB_ORG" --author=@me --created=">=$TODAY" \
  --json title,url,repository,isDraft

# PRs reviewed today
gh search prs --owner="$GITHUB_ORG" --reviewed-by=@me --updated=">=$TODAY" \
  --json title,url,repository,author
```

```bash
# Issues closed today
gh search issues --owner="$GITHUB_ORG" --author=@me --state=closed --updated=">=$TODAY" \
  --json title,url,repository
```

**Return:** structured list of commits, PRs (created/merged/reviewed),
issues closed, with URLs.

---

### Agent 2: Calendar + Granola Meeting Notes

**Step 1: Fetch today's calendar events**

Follow `wk-cal §Fetch Day Events` — ToolSearch for `"gcal"` or `"calendar"`,
then list today's events (title, time, attendees, whether attended).

**Step 1b: Fetch tomorrow's calendar events**

Repeat `wk-cal §Fetch Day Events` for the next business day. For each event
extract: title, time, duration, attendees/organizer, description, linked
document URLs, recurrence flag, and whether the user is a presenter, organizer,
or has an active role.

Flag meetings that likely need prep:
- Meetings where the user is the organizer or presenter
- 1:1s with manager or direct reports
- Meetings with external stakeholders
- Planning, review, or decision meetings (match by title keywords)
- Meetings with linked agenda docs the user hasn't viewed

**Step 2: Fetch Granola notes for each meeting (parallel per meeting)**

ToolSearch query: `"granola"`

For each meeting, search Granola for today's notes. Extract per meeting:

- **Key decisions made** — what was decided and by whom
- **Action items** — who owns what, by when
- **Open questions** — unresolved items needing follow-up
- **Insights** — non-obvious learnings worth remembering

For each **tomorrow's recurring meeting**, also search Granola for past
notes to provide context for prep (what was discussed last time, open
items from prior sessions).

If Granola is unavailable, return BLOCKED error — do not continue
without it.

**Return format per today's meeting:**

```
{time} — {title}
Attendees: {list}
Decisions: {bulleted list}
Action items:
- {owner}: {action} (due: {date})
Open questions: {list}
Key insights: {what was learned}
```

---

### Agent 3: Slack Audit

**ToolSearch query:** `"slack"`

Fetch two datasets:

**3a. Unanswered messages (for communication audit)**

- Direct messages received today that you haven't replied to
- Mentions in channels where someone is waiting for your response
- Threads you're in with unread replies directed at you
- Items from this morning's "Needs Response" list (cross-reference
  `morning_baseline` if provided) that are still unresolved

**3b. Your contributions today (for brag document)**

High-value messages you sent today:
- Decisions you communicated
- Questions you unblocked for others
- Discussions you moved forward
- Documents or resources you shared

**Return:** both datasets structured with sender, channel, summary, link.

---

### Agent 4: Gmail Audit

**ToolSearch query:** `"gmail"`

Fetch two datasets:

**4a. Unreplied emails (for communication audit)**

- Emails received today addressed to you that are unanswered
- Items from this morning's "Needs Response" list that are still pending
- Time-sensitive emails (meeting changes, urgent requests)

**4b. Your contributions today (for brag document)**

Notable emails you sent today:
- Decisions or approvals communicated
- Requests you fulfilled
- Information shared proactively

**Return:** both datasets structured with subject, sender, date, summary.

---

### Agent 5: Lattice Feedback

**ToolSearch query:** `"lattice"`

Fetch two datasets:

**5a. Pending feedback requests**

Feedback requests assigned to you that are awaiting your response:
- Peer reviews, 360 reviews, manager feedback cycles
- Any feedback request with an upcoming or past deadline
- Requests you've started but not submitted

For each, extract:
- Who requested it (or who it's about)
- Type of feedback (peer, upward, 360, etc.)
- Deadline (if any)
- Whether you've started a draft

**5b. Recent feedback received**

Any new feedback you've received that you haven't viewed:
- Praise, recognition, or constructive feedback
- Review cycle results

**Return:** both datasets structured with person, type, deadline, status.

---

### Agent 6: Jira + Confluence Audit

**ToolSearch query:** `"jira"` or `"confluence"`

Jira and Confluence share a single MCP server — one authentication covers
both.

**6a. Jira activity today (for brag document + audit)**

- Tickets you updated, commented on, or transitioned today
- Tickets assigned to you with new comments you haven't responded to
- Mentions in Jira comments awaiting your input

**6b. Confluence activity today (for announcements + audit)**

- Pages or comments where you were mentioned today
- New blog posts or announcements in team/org spaces
- Decision pages or meeting notes published today
- Pages shared with you that you haven't viewed

**Return:** both datasets structured with title, project/space, URL,
type (`jira-activity` | `jira-unanswered` | `confluence-mention` |
`confluence-announcement`), summary.

---

### Agent 7: DX (Developer Experience Metrics)

**ToolSearch query:** `"DX"`

Fetch your engineering metrics and standing across team, org, and company:

**7a. Your contributions and metrics**

- Code review turnaround time (how fast you review others' PRs)
- PR cycle time (open → merge for your PRs)
- Deploy frequency and lead time
- Lines of code / commits / PRs (relative to your baseline)
- Any DX-specific health scores or developer satisfaction signals

**7b. Standing relative to team, org, and company**

- How your metrics compare to team averages
- How your metrics compare to org and company benchmarks
- Trends — are you improving, declining, or steady this week/month?
- Any flags or alerts (e.g., review backlog growing, cycle time spiking)

**7c. Improvement areas**

Identify the top 2-3 areas where improvement would have the most impact:
- Metrics that are below team/org average
- Metrics that have been declining recently
- Quick wins (e.g., "you have 3 PRs awaiting your review that are > 24h old")

**Return:** structured metrics data with current values, comparisons,
trends, and suggested improvement areas.

---

## Stage 2: Synthesize

**Wait for all 7 agents to complete.** Merge their results with
`morning_baseline`.

### 2a. Review morning progress

If `morning_baseline` exists, walk through every checkable item and
classify its status using the agent results as evidence:

- **Completed** — evidence found (replies sent, PRs merged, issues
  closed, meetings attended)
- **In progress** — partially done, needs continuation
- **Not started** — no evidence of work on this item
- **No longer relevant** — situation changed (meeting cancelled, PR
  closed by someone else, etc.)

Present a quick summary:

> "Of the X items in your morning brief:
> - Y completed, Z in progress, W not started, V no longer relevant"

### 2b. Compile brag document

Pull from all agent results:

| Source | Agent |
|--------|-------|
| Commits, PRs, issues | Agent 1 |
| Meetings attended, decisions | Agent 2 |
| Slack contributions | Agent 3 |
| Email contributions | Agent 4 |
| Feedback given/received | Agent 5 |
| Jira tickets, Confluence activity | Agent 6 |
| DX engineering metrics | Agent 7 |

Structure:

```markdown
## Achievements — {YYYY-MM-DD}

### Code & PRs
- {what you shipped, reviewed, or unblocked}

**HARD RULE: Authorship filter.** Include a PR only if the user is
(a) the author, (b) a listed co-author, or (c) the primary/approving
reviewer who drove the work to completion. Merging another person's
PR — even as a maintainer — is a maintenance action, not an
achievement, and does not belong in the brag document.

### Meetings & Collaboration
- {decisions made, discussions led, context shared}

### Communication
- {threads unblocked, announcements made, people helped}

### Other
- {anything else notable}
```

**Tone**: factual, concise, strong verbs. "Led", "shipped", "unblocked",
"decided", "reviewed" — not "worked on" or "helped with."

### 2c. Collect and pre-check untracked action items

Merge action items from all sources:

| Source | Where to find them |
|--------|-------------------|
| Incomplete morning items | `morning_baseline` items classified as "not started" or "in progress" |
| Meeting action items | Agent 2 — action items assigned to you |
| Slack commitments | Agent 3 — threads where you committed to doing something |
| Email promises | Agent 4 — emails where you promised follow-up |

Deduplicate across sources (same action from different channels = one item).

**Pre-check tracking status** for each action item (do this now, not in
Stage 3 — no user input needed):

```bash
gh search issues --owner="$GITHUB_ORG" --assignee=@me --state=open "{keywords}"
```

Also search Jira if available (ToolSearch: `"jira"`). Mark each item as
`tracked` (existing issue/ticket found) or `untracked`.

### 2d. Compile unanswered communications

Merge unanswered items from Agent 3 (Slack), Agent 4 (Gmail), and
Agent 6 (Jira comments and Confluence mentions) into a single list.
If all comms are answered, note `comms_clean = true`.

### 2e. Compile Lattice feedback

From Agent 5, collect:
- Pending feedback requests (with deadlines and draft status)
- New feedback received

### 2f. Identify peer feedback opportunities

Mine today's interactions across all agents to find moments where you
could share meaningful feedback with coworkers. Look for:

| Signal | Source | Feedback type |
|--------|--------|--------------|
| Someone gave a great PR review | Agent 1 (PRs reviewed) | Praise — thorough review |
| Someone unblocked you in Slack | Agent 3 (Slack threads) | Praise — responsiveness |
| A meeting was well-facilitated | Agent 2 (meetings) | Praise — leadership |
| Someone presented or demo'd | Agent 2 (meetings) | Praise — communication |
| A coworker shipped something notable | Agent 1 (PRs merged by others) | Praise — delivery |
| Collaborative debugging or pairing | Agent 3 (Slack threads) | Praise — collaboration |
| Someone shared a useful resource | Agent 3 / Agent 4 | Praise — knowledge sharing |
| A decision was made with good tradeoff analysis | Agent 2 (meetings) | Praise — judgment |

For each opportunity, record:
- **Who**: the coworker's name
- **What**: the specific interaction (with link/reference)
- **Why it matters**: what made it feedback-worthy
- **Suggested feedback**: a 1-2 sentence draft the user can refine

### 2g. Tomorrow's meeting prep

From Agent 2's tomorrow calendar data, identify meetings that need
preparation and surface them as action items.

For each tomorrow meeting flagged as needing prep, determine what's
needed:

| Signal | Prep action |
|--------|------------|
| User is organizer | Review/create agenda, prepare talking points |
| Linked agenda doc exists | Read the doc, note discussion points |
| Recurring meeting with open action items from last time | Review prior action items, prepare status updates |
| 1:1 with manager | Prepare updates, blockers, asks |
| 1:1 with direct report | Review their recent work, prepare feedback |
| External stakeholders attending | Review context, prepare any deliverables |
| Planning/review/retro meeting | Gather metrics, prepare proposals |
| Presentation or demo | Prepare materials, test demos |

For each, record:
- **Meeting**: title, time, attendees
- **Prep needed**: specific actions (e.g., "read agenda doc", "prepare demo")
- **Time estimate**: rough estimate of prep effort (5min / 15min / 30min+)
- **Priority**: `must-prep` (you're presenting or it's high-stakes) vs
  `nice-to-prep` (recurring with context from Granola)

These become triage items in Stage 3 under a dedicated "Tomorrow's Meeting
Prep" group.

### 2h. DX metrics and improvement actions

From Agent 7, compile:

**Current standing:**

```
| Metric | You | Team Avg | Org Avg | Trend |
|--------|-----|----------|---------|-------|
| Review turnaround | Xh | Yh | Zh | ↑/↓/→ |
| PR cycle time | Xh | Yh | Zh | ↑/↓/→ |
| Deploy frequency | X/wk | Y/wk | Z/wk | ↑/↓/→ |
```

**Proposed improvement actions for tomorrow:**

For each area below team/org average or declining, propose a specific,
actionable item for the next day:

- If review turnaround is high → "Review the 3 pending PRs first thing
  tomorrow morning (before standup)"
- If PR cycle time is high → "Break the large open PR into smaller PRs
  or address blocking review comments"
- If deploy frequency is low → "Ship the feature branch that's been
  ready but unmerged"

These become action items in evening.md for tomorrow's morning brief.

---

## Stage 3: Interactive Resolution

Present items **one group at a time**, with a maximum of **5 items per
prompt**. Groups with more than 5 items are paginated across multiple
prompts. Process each group's responses before moving to the next.

### Auto-resolution (weekly memory + morning brief)

Before presenting any group, auto-resolve items using two sources in
priority order:

**Priority 1: Weekly memory rules** (`week_rules`)

Check each item against the `week_rules` patterns. Match by item
identifier, source group, or content pattern. If a rule matches:

| Rule type | Auto-answer | Rationale |
|-----------|-------------|-----------|
| Auto-skip | **Skip** | User consistently skips this pattern |
| Auto-done | **Already done** | User says this is always handled |

**Priority 2: Morning brief decisions** (`morning_decisions`)

For items not matched by weekly rules, check against today's morning.md
triage. An item is a **repeat** if it matches a morning item by key
identifiers (same Slack thread URL, same PR number, same Jira key,
same email subject+sender).

| Morning decision | Evening auto-answer | Rationale |
|-----------------|---------------------|-----------|
| `[x]` (Already done) | **Already done** | User confirmed completion this morning |
| `[ ]` (Will do) + evidence of completion (from agents) | **Already done** | Agent data shows it was handled |
| `[ ]` (Will do) + no evidence | Keep in triage | Still needs user decision |
| Skipped (omitted) | **Skip** | User chose to ignore this morning |

**Announce auto-resolved items** at the start of each group. Distinguish
weekly-memory resolutions from morning resolutions:

> "Auto-resolved {N} items ({W} from weekly rules, {M} from morning
> decisions). Review the remaining items below."

If all items in a group are auto-resolved, announce and move to the next
group — do not prompt.

### Resolution groups (in order)

Process groups in this order. Skip any group with 0 items:

1. **Tomorrow's Meeting Prep** — prep actions for important meetings
2. **Untracked Action Items** — from meetings, Slack commitments, email promises
3. **Unanswered Slack Messages**
4. **Unanswered Emails**
5. **Unanswered Jira Comments**
6. **Unanswered Confluence Mentions**
7. **Lattice Feedback Requests**
8. **Peer Feedback Opportunities**

If ALL groups are empty after auto-resolution, skip Stage 3:
> "Nothing needs your input — all items are tracked and all comms answered!"

### Presentation format

**HARD RULE:** Every triaged item MUST be presented with a clickable
link to the underlying artifact. The `[link]` slot is non-optional.

- Resolve URLs at fetch time — every Stage 1 agent emits a `url`
  field on each item.
- Render the link as a markdown autolink `<url>` or labeled link
  `[title](url)` so terminals and the HTML dashboard both resolve it.
- Refuse to prompt on any item lacking a URL — re-fetch, fall back to
  a search query, or mark `link_unavailable: true` with a reason and
  skip the item rather than present a bare summary.
- Source mapping per group is in
  [`../goodmorning/references/triage-link-sources.md`](../goodmorning/references/triage-link-sources.md).

For each group, present up to 5 items at a time. Each batch includes
**batch-level actions** that apply to all items, and individual per-item
options:

> "**{Group Name}** ({current}/{total} items, {auto_resolved} auto-resolved)
>
> **Batch actions:** `all:a` (will do all) | `all:b` (all done) |
> `all:c` (skip all) | `all:c+m` (skip all + remember for the week)
>
> 1. {item summary} [link]
>    **(a)** Will do  **(b)** Already done  **(c)** Skip  {group-specific options}
>
> 2. {item summary} [link]
>    **(a)** Will do  **(b)** Already done  **(c)** Skip  {group-specific options}
>
> ...up to 5...
>
> Append **+m** to any choice to save it as a weekly rule.
> e.g.: `1a 2c+m 3d` — skip item 2 and remember that choice.
>
> Reply with your choices."

Wait for the user's response, then process that batch immediately. Present
the next batch (if the group has more items) or move to the next group.

### The `+m` (remember) modifier

> See [`skills/goodmorning/references/subagent-contract.md`](../goodmorning/references/subagent-contract.md)
> — `+m` modifier table and pattern-extraction table.

Behavior summary: append `+m` to any choice (`2c+m`, `all:c+m`) to save a weekly memory
rule. Extract the pattern (channel name, sender, repo, project key, space name, or
source meeting), confirm inline, and write to `$WEEK_MEMORY`. If the user says "no" or
"cancel", apply the action but don't save the rule.

### Group-specific options

Every item always has the 3 base options **(a) Will do (b) Already done
(c) Skip**. Groups add extras:

| Group | Extra options |
|-------|-------------|
| Tomorrow's Meeting Prep | **(d)** Prep now (open doc/draft notes)  **(e)** Add to morning brief |
| Untracked Action Items | **(d)** GitHub issue  **(e)** Jira ticket  **(f)** Carry forward |
| Unanswered Slack | **(d)** Draft response  **(e)** Snooze to tomorrow |
| Unanswered Emails | **(d)** Draft response  **(e)** Snooze to tomorrow |
| Unanswered Jira | **(d)** Draft response  **(e)** Snooze to tomorrow |
| Unanswered Confluence | **(d)** Draft response  **(e)** Snooze to tomorrow |
| Lattice Feedback | **(d)** Draft now  **(e)** Remind tomorrow |
| Peer Feedback Opportunities | **(d)** Lattice  **(e)** Slack DM  **(f)** Edit & send |

All options support the `+m` modifier.

### Process responses (per batch)

After each batch of responses, process immediately in parallel where
possible:

- **(a) Will do** → Carry forward to evening.md action items
- **(b) Already done** → Record as completed in evening.md achievements.
  Do not create an issue, carry forward, or draft anything.
- **(c) Skip** → Omit entirely from evening.md — not carried forward,
  not recorded as done.
- **(d) GitHub issue** → `gh issue create --title "{action}" --body "{context}" --assignee @me` (verify `$GITHUB_ORG` per `wk-gh`)
- **(d/e) Draft response** → Queue for draft review (present all drafts
  together after all groups are done)
- **(e) Jira ticket** → Create via Jira MCP tools
- **(e/f) Snooze / Carry forward** → Add to evening.md carry-over with context
- **(e) Remind tomorrow** → Add to evening.md carry-over with deadline
- **(d) Draft now (Lattice)** → Queue for draft review
- **(d) Lattice / (e) Slack DM / (f) Edit & send** → Queue for draft review
- **Any + `+m`** → also write the pattern to `$WEEK_MEMORY` as an
  auto-rule (auto-skip, auto-done, or auto-will-do depending on the
  base option chosen)

### Draft review pass

After all groups are processed, if any drafts were queued (comms or
feedback), present all drafts together in a single review prompt:

> "I have {N} drafts ready for your review:
>
> 1. **Reply to @{sender}** in #{channel}:
>    > {draft text}
>    **(a)** Send  **(b)** Edit  **(c)** Discard
>
> ...
>
> Reply with your choices."

Send approved drafts via MCP. Edits get a follow-up prompt. Discarded
drafts are dropped.

### Update weekly memory

After all groups are processed, scan today's decisions (combined with
this morning's triage decisions) for patterns worth remembering.

An item becomes a **weekly rule candidate** when:

- The user chose **Skip** for an item that was also skipped this morning
  AND on at least one prior day this week (consistent skip pattern)
- The user chose **Already done** for an item that was also marked done
  this morning AND on a prior day (consistently pre-handled)
- The user explicitly says "always skip this" or "remember this" during
  triage

For each candidate not already in `week_rules`, ask:

> "You've consistently {skipped/marked-done} `{pattern}` this week.
> Should I auto-{skip/done} it for the rest of the week?
> **(a)** Yes, remember  **(b)** No, ask each time"

If the user confirms, add the rule to `$WEEK_MEMORY`. If the file
doesn't exist yet, create it with the standard weekly memory format
(see goodmorning Stage 0 for the template).

This step is **quick** — only fires when new patterns are detected.
If no candidates, skip silently.

---

## Stage 4: Generate evening.md

Write to `<today_dir>/evening.md`. This file is consumed by
tomorrow's `wk-goodmorning` — structure it for machine readability.

### Brief versioning (applies to evening.md and evening.html)

Every generated wrap-up MUST embed the generator's `metadata.version`
so the next run's idempotency check can detect "is this older than
the current skill?" without parsing prose. Read the value from this
skill's own frontmatter at runtime — never hardcode.

- **markdown** (`evening.md`): YAML frontmatter at the top with
  `generated_with`, `generated_with_skill`, `generated_at`.
- **html** (`evening.html`): `<meta name="generated-with-version">`,
  `<meta name="generated-with-skill">`, `<meta name="generated-at">`
  inside `<head>`.

CalVer string-compare gives correct ordering. The annotations are
non-negotiable structural metadata; the renderer must inject them
even when a user-maintained template doesn't include the slots.

```markdown
---
generated_with: {SKILL_VERSION}
generated_with_skill: wk-goodevening
generated_at: {ISO_8601_UTC}
---

# Evening Summary — {YYYY-MM-DD}

## Achievements
{brag document from Stage 2b}

## Meeting Notes
{compiled meeting summaries from Agent 2}

## Tomorrow's Meeting Prep
- [ ] {time} — {meeting title}: {prep action} ({priority})
- [ ] {time} — {meeting title}: {prep action} ({priority})

## Action Items for Tomorrow
- [ ] {item}: {context and source}

## Yesterday's Meeting Follow-Through
- [ ] {meeting}: {action item or share-out from Granola notes}

## Carry-Over Items
- [ ] {morning brief item not completed}: {status and context}
- [ ] {snoozed Slack/email}: {summary and link}

## Deferred Communications
- [ ] Reply to @{sender} in #{channel}: {summary} [link]
- [ ] Reply to {email subject} from {sender} [link]

## Feedback
### Lattice Requests Pending
- [ ] {type} for @{person} — due {date}
### Feedback Sent Today
- @{person}: {summary} (via {Lattice|Slack})

## Issues Created Today
- {repo}#{number}: {title} [link]
- {JIRA-KEY}: {title} [link]

## Open Questions
- {question from meeting}: {context}

## DX Metrics
| Metric | You | Team Avg | Org Avg | Trend |
|--------|-----|----------|---------|-------|
| {metric} | {value} | {team} | {org} | {trend} |

### Improvement Actions for Tomorrow
- [ ] {specific action}: {rationale from DX data}

## Day Stats
- Morning brief items: {total} ({completed} done, {remaining} remaining)
- Meetings attended: {count}
- PRs created/reviewed/merged: {counts}
- Issues closed: {count}
- Commits: {count}
```

### Generate evening.html — Achievements Dashboard

Write to `<today_dir>/evening.html`. Self-contained, cheerful HTML report
celebrating the day's accomplishments — **no CDN dependencies**, all CSS
and JS embedded.

**Tone:** Warm, celebratory, positive. This is the reward for a day's
work. Use encouraging language, highlight impact, and make achievements
feel substantial. End-of-day energy should be "look what you did today"
not "here's what's left."

**Required features:**

0. **Generator metadata** — `<head>` must include `<meta name="generated-with-version" content="{SKILL_VERSION}">`, `<meta name="generated-with-skill" content="wk-goodevening">`, and `<meta name="generated-at" content="{ISO_8601_UTC}">`. The Stage 0 idempotency check reads these on the next run.
1. **Header** — date, cheerful greeting ("Great day, {name}!" or
   "You crushed it today!"), overall stats bar (items completed,
   PRs shipped, meetings attended)
2. **Hero section** — the single most impactful achievement of the day,
   displayed prominently with a large emoji and a one-line summary
3. **Achievements grid** — card layout for each category:
   - Code & PRs (commits, PRs created/merged/reviewed, issues closed)
   - Meetings & Collaboration (decisions made, discussions led)
   - Communication (threads unblocked, people helped)
   - Feedback (given and received)
   - Each card has a count badge and expandable details
4. **DX Metrics snapshot** — compact table with trend arrows and
   color-coded cells (green = above average, amber = near average,
   red = below). Improvement actions as callouts.
5. **Meeting highlights** — timeline view of today's meetings with
   key decisions and action items. Collapsible per meeting.
6. **Tomorrow preview** — compact list of prep items and carry-overs,
   visually distinct from achievements (muted colors, smaller type).
   This is informational, not the focus.
7. **Day stats footer** — total commits, PRs, issues, meetings,
   messages sent, feedback given. Rendered as a clean stat row.
8. **Confetti or celebration animation** — subtle CSS animation on
   page load (e.g., confetti particles, a brief bounce on the hero
   card, or a gradient sweep). Keep it tasteful — one animation, not
   a circus.
9. **Dark mode** — respect `prefers-color-scheme`
10. **Responsive** — 2-col grid on wide screens, single column on mobile
11. **Print-friendly** — `@media print` hides animations, switches to
    single column, uses dark text on white

**Design:** Warm color palette (soft greens, blues, amber accents),
system font stack, generous whitespace, rounded cards with subtle
shadows. Achievements should feel like trophies, not a spreadsheet.
The overall vibe is "end of a good day."

**Links:** All links to PRs, issues, Slack threads, Jira tickets, and
Confluence pages MUST use `target="_blank" rel="noopener noreferrer"`.

### Write last_working_day marker

After writing the evening files, record today as the last working day so
tomorrow's `wk-goodmorning` can find yesterday's sitrep correctly
when "yesterday" is a weekend (Monday morning problem):

```bash
mkdir -p "$PWD/sitrep"
echo "$TODAY" > "$PWD/sitrep/last_working_day"
```

This file is consumed by `wk-goodmorning §Determine dates and paths`
set `YESTERDAY` to the last day goodevening ran, not the last calendar day.

### Open for review

After writing both files, open the HTML dashboard:

```bash
open "$TODAY_DIR/evening.html"
```

Then announce:

> "Your evening wrap-up is ready:
> - `sitrep/{YYYY}/{MM}/{DD}/evening.html` — your achievements dashboard
> - `sitrep/{YYYY}/{MM}/{DD}/evening.md` — tomorrow's carry-over reference
>
> Today: {completed} items done, {remaining} carried forward,
> {issues_created} issues created, {meetings} meetings documented.
>
> {brag_highlight — the single most impactful thing you did today}
>
> Would you like to commit and push these files?"

---

## Stage 5: Distill Accumulated Learnings

After generating the evening files, check for unprocessed learnings from
skill executions during the day. These accumulate via the Post-Completion
Learning Capture hooks on each skill.

### Scan for unprocessed learnings

```bash
test -n "$WK_SKILLS_HOME" && \
  find "$WK_SKILLS_HOME/learnings/skills" -name "*.md" \
    ! -name "*.learned.md" -type f 2>/dev/null | head -20
```

If `$WK_SKILLS_HOME` is not set or the directory doesn't exist, skip
this stage silently — learnings are optional.

If no unprocessed files are found (all are `.learned.md` or none exist),
skip this stage:
> "No new learnings to distill today."

### Process each learning

For each unprocessed `.md` file found:

1. **Read the learning** — extract the skill name, what happened, root
   cause, and suggested fix
2. **Invoke `wk-sharpen`** via the Skill tool with the learning file as
   input — this distills the principle and applies it to the target skill
3. **After `wk-sharpen` completes**, rename the file to mark it absorbed:

```bash
mv "$learning_file" "${learning_file%.md}.learned.md"
```

The `.learned.md` extension signals that the learning has been distilled
into the skill and should not be processed again.

### Batch presentation

If multiple learnings exist, present a summary before processing:

> "Found {N} unprocessed learnings across {M} skills:
>
> 1. `goodmorning/2026-04-21_missing-auth-retry.md` — gap (medium)
> 2. `pr-review/2026-04-21_stale-diff-cache.md` — correction (high)
> 3. `workflow/2026-04-20_skipped-docs-step.md` — pattern (low)
>
> Distilling into skill improvements..."

Process all learnings, then report results:

> "Distilled {N} learnings:
> - {count} skills updated
> - {count} learnings absorbed (renamed to .learned.md)
> - {count} skipped (routine, nothing to distill)"

### Rate limiting

If more than 5 unprocessed learnings exist, process the 5 with the
highest severity first (high > medium > low). Carry the rest to
tomorrow — they won't be lost since only `.learned.md` files are
excluded from the scan.

---

## Service Connection Summary

| Service | ToolSearch | Agent | Fallback |
|---------|-----------|-------|----------|
| GitHub / git | `"github"` | 1 | `gh` CLI (always available) |
| Calendar | `"gcal"` | 2 | **BLOCKED** — require MCP |
| Granola | `"granola"` | 2 | **BLOCKED** — require MCP |
| Slack | `"slack"` | 3 | **BLOCKED** — require MCP |
| Gmail | `"gmail"` | 4 | **BLOCKED** — require MCP |
| Lattice | `"lattice"` | 5 | **BLOCKED** — require MCP |
| Jira + Confluence | `"jira"` / `"confluence"` | 6 | **BLOCKED** — require MCP |
| DX | `"DX"` | 7 | **BLOCKED** — require MCP |

---

## QPR Brag Accumulation

**QPR brag accumulation:** As you compile today's brag document, flag items
that are particularly QPR-worthy with a `🌟` marker. An item is QPR-worthy
when it demonstrates: shipping a meaningful feature or system, making an
architectural decision, leading cross-team work, facilitating training,
contributing to hiring, resolving a security issue, or receiving peer
recognition. Append flagged items to the running QPR brag log:

```bash
QPR_LOG="$PWD/QPR/brag-log.md"
# Create if missing, append date-stamped wins
```

Format each appended entry as:

```
## {YYYY-MM-DD}
- 🌟 {accomplishment — strong verb, specific impact, evidence link}
```

This log feeds `wk-self-perf` with pre-distilled signals when QPR season
arrives, so you're not reconstructing the quarter from scratch.

**Perf review season awareness:** During February and August ($EMPLOYER QPR
seasons), add a banner to the evening summary:

> "📋 **QPR Season** — Consider whether today's achievements should be
> captured in your self-review. Run `/wk-self-perf quarter` to generate
> your current-quarter narrative."

---

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| `/wk-goodevening` | Full evening wrap-up — 7 parallel agents, then interactive |
| No morning.md | Gathers fresh context, still produces evening.md |
| Service unavailable | Block and prompt user to fix, re-run failed agents |
| All comms answered | Celebrates clean inbox |
| Item skipped consistently | Offer to add auto-skip rule to weekly memory |
| No weekly memory | No auto-rules — all items triaged manually |
| Unprocessed learnings found | Distill via `wk-sharpen`, rename to `.learned.md` |
| No learnings | Skip distillation silently |
| >5 learnings pending | Process top 5 by severity, carry rest to tomorrow |

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn goodevening`).
