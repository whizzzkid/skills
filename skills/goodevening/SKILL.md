---
name: wk:goodevening
description: >-
  Wrap up your workday — review morning progress, write a brag document of
  the day's achievements, capture meeting learnings from Granola, track
  unfinished action items as GitHub/Jira issues, audit unanswered Slack
  and email messages, and create an evening.md for tomorrow's morning brief.
  Use at the end of your workday.
model-invocable: false
user-invocable: true
model: sonnet
effort: medium
license: MIT
metadata:
  author: whizzzkid
  version: '2.0.0'
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
context for tomorrow.

```
Bootstrap ──► Parallel Fetch (4 agents) ──► Synthesize ──► Interactive ──► evening.md
                │  Code+GitHub agent                         │
                │  Calendar+Granola agent                    │  Untracked items
                │  Slack agent                               │  Unanswered comms
                │  Gmail agent                               │
```

---

## Stage 0: Bootstrap

### Determine dates and paths

```bash
TODAY=$(date +%Y-%m-%d)
TODAY_DIR="$PWD/$TODAY"
MORNING_FILE="$TODAY_DIR/morning.md"
```

### Read the morning brief

If `morning.md` exists, read it in full. This is the baseline — the items
planned for today. Store it as the `morning_baseline` dataset.

If it does not exist, note this. The evening summary is still valuable
without a morning brief — Stage 1 gathers fresh context.

---

## Stage 1: Parallel Data Gathering

**Launch 4 agents in parallel** using the Agent tool. Each agent handles
its own MCP authentication independently. If any agent fails to
authenticate, it returns a skip notice — it does not block the others.

### MCP Connection Pattern (shared by all agents)

1. `ToolSearch` to find MCP tools for the service
2. Call the authenticate tool to start OAuth
3. After auth completes, use the operational tools
4. **If auth fails** → **STOP the agent** and return an error:
   `"BLOCKED: {Service} authentication failed. User must complete OAuth at: {url}"`
5. **If no MCP tools found** → **STOP the agent** and return an error:
   `"BLOCKED: {Service} MCP tools not configured. User must install the MCP server."`

**No service is optional.** If any agent returns a BLOCKED error, pause
and present ALL blocked services to the user at once:

> "The following services need your attention before I can continue:
>
> 1. {Service}: {reason and action needed}
> 2. {Service}: {reason and action needed}
>
> Please fix these and tell me to continue."

**Do not proceed to Stage 2 until all agents succeed.** After the user
fixes access, re-run only the failed agents.

---

### Agent 1: Code + GitHub Activity

Gathers all code and PR activity for the brag document. No MCP needed —
uses git and `gh` CLI directly.

**Run all in parallel:**

```bash
# Today's commits (all repos in cwd)
git log --all --author="$(git config user.email)" --since="$TODAY 00:00" \
  --format="%h %s"

# PRs merged today
gh search prs --author=@me --merged --updated=">=$TODAY" \
  --json title,url,repository,mergedAt

# PRs created today
gh search prs --author=@me --created=">=$TODAY" \
  --json title,url,repository

# PRs reviewed today
gh search prs --reviewed-by=@me --updated=">=$TODAY" \
  --json title,url,repository,author

# Issues closed today
gh search issues --author=@me --state=closed --updated=">=$TODAY" \
  --json title,url,repository
```

**Return:** structured list of commits, PRs (created/merged/reviewed),
issues closed, with URLs.

---

### Agent 2: Calendar + Granola Meeting Notes

**Step 1: Fetch today's calendar events**

ToolSearch query: `"gcal"` or `"calendar"`

Get all events for today — title, time, attendees, whether attended.

**Step 2: Fetch Granola notes for each meeting (parallel per meeting)**

ToolSearch query: `"granola"`

For each meeting, search Granola for today's notes. Extract per meeting:

- **Key decisions made** — what was decided and by whom
- **Action items** — who owns what, by when
- **Open questions** — unresolved items needing follow-up
- **Insights** — non-obvious learnings worth remembering

If Granola is unavailable, return BLOCKED error — do not continue
without it.

**Return format per meeting:**

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

## Stage 2: Synthesize

**Wait for all 4 agents to complete.** Merge their results with
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

Structure:

```markdown
## Achievements — {YYYY-MM-DD}

### Code & PRs
- {what you shipped, reviewed, or unblocked}

### Meetings & Collaboration
- {decisions made, discussions led, context shared}

### Communication
- {threads unblocked, announcements made, people helped}

### Other
- {anything else notable}
```

**Tone**: factual, concise, strong verbs. "Led", "shipped", "unblocked",
"decided", "reviewed" — not "worked on" or "helped with."

### 2c. Collect untracked action items

Merge action items from all sources:

| Source | Where to find them |
|--------|-------------------|
| Incomplete morning items | `morning_baseline` items classified as "not started" or "in progress" |
| Meeting action items | Agent 2 — action items assigned to you |
| Slack commitments | Agent 3 — threads where you committed to doing something |
| Email promises | Agent 4 — emails where you promised follow-up |

Deduplicate across sources (same action from different channels = one item).

---

## Stage 3: Interactive Resolution

This stage requires user input and runs sequentially.

### 3a. Track untracked action items

For each action item from Stage 2c, check if it's already tracked:

```bash
gh search issues --assignee=@me --state=open "{keywords}"
```

Also search Jira if available (ToolSearch: `"jira"`).

For items **without** an existing issue/ticket, present them:

> "These action items from today don't have tracking issues:
>
> 1. {action from standup} — from {meeting name}
> 2. {follow-up promised in Slack} — #{channel}
> 3. {incomplete morning brief item}
>
> For each, would you like me to:
> **(a)** Create a GitHub issue
> **(b)** Create a Jira ticket
> **(c)** Carry forward to tomorrow (evening.md only)
> **(d)** Skip — handled or no longer needed"

Process each choice:

- **(a):** `gh issue create --title "{action}" --body "{context}" --assignee @me`
- **(b):** Use Jira MCP tools to create a ticket
- **(c):** Add to evening.md carry-over section
- **(d):** Mark as resolved

### 3b. Audit unanswered communications

Merge unanswered items from Agent 3 (Slack) and Agent 4 (Gmail).

If there are outstanding items:

> "You have {N} unanswered communications:
>
> **Slack:**
> 1. @{sender} in #{channel}: {summary} [link]
>
> **Email:**
> 2. {subject} from {sender} — received {time} [link]
>
> For each:
> **(a)** Draft a response now (I'll help compose it)
> **(b)** Snooze to tomorrow
> **(c)** Skip — no response needed"

- **(a):** Draft response, present for approval, send via MCP
- **(b):** Add to evening.md carry-over with context
- **(c):** Mark as resolved

**If all comms are answered:**
> "All Slack messages and emails from today are responded to. Clean inbox!"

---

## Stage 4: Generate evening.md

Write to `<pwd>/<YYYY-MM-DD>/evening.md`. This file is consumed by
tomorrow's `wk:goodmorning` — structure it for machine readability.

```markdown
# Evening Summary — {YYYY-MM-DD}

## Achievements
{brag document from Stage 2b}

## Meeting Notes
{compiled meeting summaries from Agent 2}

## Action Items for Tomorrow
- [ ] {item}: {context and source}

## Carry-Over Items
- [ ] {morning brief item not completed}: {status and context}
- [ ] {snoozed Slack/email}: {summary and link}

## Deferred Communications
- [ ] Reply to @{sender} in #{channel}: {summary} [link]
- [ ] Reply to {email subject} from {sender} [link]

## Issues Created Today
- {repo}#{number}: {title} [link]
- {JIRA-KEY}: {title} [link]

## Open Questions
- {question from meeting}: {context}

## Day Stats
- Morning brief items: {total} ({completed} done, {remaining} remaining)
- Meetings attended: {count}
- PRs created/reviewed/merged: {counts}
- Issues closed: {count}
- Commits: {count}
```

### Announce

> "Your evening wrap-up is complete:
> - `{date}/evening.md` — tomorrow's carry-over reference
>
> Today: {completed} items done, {remaining} carried forward,
> {issues_created} issues created, {meetings} meetings documented.
>
> {brag_highlight — the single most impactful thing you did today}"

---

## Service Connection Summary

| Service | ToolSearch | Agent | Fallback |
|---------|-----------|-------|----------|
| GitHub / git | `"github"` | 1 | `gh` CLI (always available) |
| Calendar | `"gcal"` | 2 | **BLOCKED** — require MCP |
| Granola | `"granola"` | 2 | **BLOCKED** — require MCP |
| Slack | `"slack"` | 3 | **BLOCKED** — require MCP |
| Gmail | `"gmail"` | 4 | **BLOCKED** — require MCP |
| Jira | `"jira"` | Stage 3 | **BLOCKED** — require MCP |

---

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| `/wk:goodevening` | Full evening wrap-up — 4 parallel agents, then interactive |
| No morning.md | Gathers fresh context, still produces evening.md |
| Service unavailable | Block and prompt user to fix, re-run failed agents |
| All comms answered | Celebrates clean inbox |
