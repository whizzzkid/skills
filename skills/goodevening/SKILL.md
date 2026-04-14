---
name: wk:goodevening
description: >-
  Wrap up your workday — review morning progress, write a brag document of
  the day's achievements, capture meeting learnings from Granola, check
  Lattice for pending feedback requests, surface peer feedback opportunities
  from today's interactions, track unfinished action items as GitHub/Jira
  issues, audit unanswered Slack and email messages, and create an
  evening.md for tomorrow's morning brief. Use at the end of your workday.
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
Bootstrap ──► Parallel Fetch ──► Compile Everything ──► One Prompt ──► evening.md
               (5 agents)        (no user input)        (all Qs)
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

**Launch 5 agents in parallel** using the Agent tool. Each agent handles
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

## Stage 2: Synthesize

**Wait for all 5 agents to complete.** Merge their results with
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
gh search issues --assignee=@me --state=open "{keywords}"
```

Also search Jira if available (ToolSearch: `"jira"`). Mark each item as
`tracked` (existing issue/ticket found) or `untracked`.

### 2d. Compile unanswered communications

Merge unanswered items from Agent 3 (Slack) and Agent 4 (Gmail) into a
single list. If all comms are answered, note `comms_clean = true`.

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

---

## Stage 3: Interactive Resolution

**Present everything at once.** Compile all items that need user input
into a single numbered prompt. The user answers all questions in one pass.
Do NOT ask section by section.

Present the full list:

> "Here's your evening wrap-up. I need your input on {N} items:
>
> ---
>
> **Untracked Action Items** ({count})
> _These don't have GitHub issues or Jira tickets yet:_
>
> 1. {action from standup} — from {meeting name}
>    **(a)** GitHub issue  **(b)** Jira ticket  **(c)** Carry forward  **(d)** Skip
>
> 2. {follow-up promised in Slack} — #{channel}
>    **(a)** GitHub issue  **(b)** Jira ticket  **(c)** Carry forward  **(d)** Skip
>
> ---
>
> **Unanswered Communications** ({count})
>
> 3. Slack: @{sender} in #{channel}: {summary} [link]
>    **(a)** Draft response  **(b)** Snooze to tomorrow  **(c)** Skip
>
> 4. Email: {subject} from {sender} — received {time} [link]
>    **(a)** Draft response  **(b)** Snooze to tomorrow  **(c)** Skip
>
> ---
>
> **Lattice Feedback Requests** ({count})
>
> 5. Peer feedback for @{person} — due {date} ({status})
>    **(a)** Draft now  **(b)** Remind tomorrow  **(c)** Skip
>
> ---
>
> **Peer Feedback Opportunities** ({count})
>
> 6. @{person} — {what they did} ({source})
>    Suggested: "{draft feedback}"
>    **(a)** Lattice  **(b)** Slack DM  **(c)** Edit & send  **(d)** Skip
>
> ---
>
> Reply with your choices, e.g.: `1a 2c 3b 4a 5b 6a`"

**If a section has zero items, omit it entirely.** If ALL sections are
empty, skip Stage 3:
> "Nothing needs your input — all items are tracked and all comms answered!"

### Process responses

After receiving the user's answers, process all choices in parallel where
possible:

- **Action items → GitHub:** `gh issue create --title "{action}" --body "{context}" --assignee @me`
- **Action items → Jira:** Use Jira MCP tools to create a ticket
- **Action items → Carry forward:** Add to evening.md carry-over
- **Comms → Draft response:** Draft all responses, then present them
  together for approval before sending via MCP
- **Comms → Snooze:** Add to evening.md carry-over with context
- **Lattice → Draft:** Draft feedback using context from today's
  interactions, present for refinement, submit via Lattice MCP
- **Lattice → Remind:** Add to evening.md carry-over with deadline
- **Peer feedback → Lattice:** Submit via Lattice MCP tools
- **Peer feedback → Slack:** Send via Slack MCP tools
- **Peer feedback → Edit:** Let user edit, then send via chosen channel

If any drafts were requested (comms or Lattice feedback), present all
drafts together in a second prompt for approval before sending.

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
> {brag_highlight — the single most impactful thing you did today}
>
> Would you like to commit and push these files?"

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
| Jira | `"jira"` | Stage 3 | **BLOCKED** — require MCP |

---

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| `/wk:goodevening` | Full evening wrap-up — 5 parallel agents, then interactive |
| No morning.md | Gathers fresh context, still produces evening.md |
| Service unavailable | Block and prompt user to fix, re-run failed agents |
| All comms answered | Celebrates clean inbox |
