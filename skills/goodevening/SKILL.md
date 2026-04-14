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
  version: '1.0.0'
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

---

## Phase 1: Initialize

### Determine dates and paths

```bash
TODAY=$(date +%Y-%m-%d)
TOMORROW=$(date -v+1d +%Y-%m-%d 2>/dev/null || date -d "tomorrow" +%Y-%m-%d)
TODAY_DIR="$PWD/$TODAY"
MORNING_FILE="$TODAY_DIR/morning.md"
EVENING_FILE="$TODAY_DIR/evening.md"
```

### Read the morning brief

If `<pwd>/<YYYY-MM-DD>/morning.md` exists, read it in full. This is your
baseline — the items you planned to work through today.

If it does not exist, note this and gather fresh context from services
instead. The evening summary is still valuable even without a morning brief.

---

## Phase 2: Review Morning Progress

If morning.md exists, walk through every checkable item and determine its
status:

- **Completed** — the item was done (evidence: replies sent, PRs merged,
  issues closed, meetings attended)
- **In progress** — partially done, needs continuation
- **Not started** — was not touched today
- **No longer relevant** — the situation changed (meeting cancelled, PR
  closed by someone else, etc.)

Check the HTML dashboard's localStorage state if the user has the
morning.html open — but do not depend on it. Verify against the actual
services where possible.

Present a quick summary:

> "Of the X items in your morning brief:
> - Y completed
> - Z in progress
> - W not started
> - V no longer relevant"

---

## Phase 3: Brag Document

Build a summary of the day's achievements. Pull from multiple sources:

### 3a. Git activity

```bash
git log --all --author="$(git config user.email)" --since="$TODAY 00:00" \
  --format="%h %s" 2>/dev/null
```

Also check across multiple repos if the user works in several:

```bash
gh search prs --author=@me --merged --updated=">=$TODAY" \
  --json title,url,repository,mergedAt 2>/dev/null
gh search issues --author=@me --state=closed --updated=">=$TODAY" \
  --json title,url,repository 2>/dev/null
```

### 3b. PR activity

- PRs you created today
- PRs you reviewed today
- PRs you merged today
- Review comments you posted

### 3c. Meetings attended

Cross-reference today's calendar events (fetch via Calendar MCP tools —
same auth pattern as `wk:goodmorning` Phase 2) with what actually happened.

### 3d. Slack/email contributions

High-value messages you sent:
- Decisions you communicated
- Questions you unblocked for others
- Discussions you moved forward
- Documents or resources you shared

### 3e. Compile the brag document

Write achievements in a format suitable for:
- Weekly status updates
- Performance review evidence
- Manager 1:1 prep

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

**Tone**: factual, concise, uses strong verbs. "Led", "shipped",
"unblocked", "decided", "reviewed" — not "worked on" or "helped with."

---

## Phase 4: Meeting Notes from Granola

Use ToolSearch to find Granola MCP tools (search: `"granola"`).
Authenticate if needed.

### 4a. Fetch today's meeting notes

Search Granola for notes from all meetings that occurred today. Match by:
- Meeting title
- Date range (today)
- Attendees

### 4b. Extract key learnings and insights

For each meeting with notes, extract:

- **Key decisions made** — what was decided and by whom
- **Action items** — who owns what, and by when
- **Open questions** — unresolved items that need follow-up
- **Insights** — non-obvious learnings, context, or information worth
  remembering

### 4c. Compile meeting summary

```markdown
## Meeting Notes — {YYYY-MM-DD}

### {time} — {meeting title}
**Attendees**: {list}
**Decisions**: {bulleted list}
**Action items**:
- [ ] {owner}: {action} (due: {date})
**Open questions**: {list}
**Key insights**: {what you learned}
```

If Granola is unavailable, prompt the user:
> "Granola is not connected. Would you like to manually summarize any
> meetings from today?"

---

## Phase 5: Track Unfinished Action Items

Collect all action items from:

1. Morning brief items not completed (Phase 2)
2. Meeting action items assigned to you (Phase 4)
3. Slack threads where you committed to doing something
4. Emails where you promised follow-up

### 5a. Check if already tracked

For each action item, check if a corresponding GitHub issue or Jira ticket
already exists:

- Search GitHub issues by keywords:
  ```bash
  gh search issues --assignee=@me --state=open "{action item keywords}"
  ```
- Use ToolSearch to find Jira MCP tools (search: `"jira"`) and search for
  matching tickets

### 5b. Prompt for untracked items

For each action item that does NOT have an existing issue/ticket, present
it to the user:

> "These action items from today don't have tracking issues:
>
> 1. {action item from standup} — from {meeting name}
> 2. {follow-up promised in Slack} — #{channel}
> 3. {incomplete morning brief item}
>
> For each, would you like me to:
> **(a)** Create a GitHub issue
> **(b)** Create a Jira ticket
> **(c)** Carry forward to tomorrow (track in evening.md only)
> **(d)** Skip — it's handled or no longer needed"

Process each item based on the user's choice:

**(a) GitHub issue:**
```bash
gh issue create --title "{action}" --body "{context, source meeting/thread}" \
  --assignee @me
```

**(b) Jira ticket:**
Use Jira MCP tools to create a ticket with appropriate project, type, and
assignee.

**(c) Carry forward:**
Add to the evening.md carry-over section.

**(d) Skip:**
Mark as resolved in the summary.

---

## Phase 6: Communication Audit

Check that you haven't left anyone hanging today.

### 6a. Slack audit

Connect to Slack (same auth pattern as `wk:goodmorning`).

Check for:
- **Direct messages received today** that you haven't replied to
- **Mentions in channels** where someone is waiting for your response
- **Threads you're in** with unread replies directed at you
- **Messages from your morning brief** "Needs Response" section that are
  still unresolved

### 6b. Email audit

Connect to Gmail (same auth pattern as `wk:goodmorning`).

Check for:
- **Emails received today** addressed to you that are unanswered
- **Emails from your morning brief** that are still pending
- **Time-sensitive emails** (meeting changes, urgent requests)

### 6c. Present outstanding items

If there are unanswered messages or emails, show them:

> "You have {N} unanswered communications:
>
> **Slack:**
> 1. @{sender} in #{channel}: {summary} [link]
> 2. DM from @{sender}: {summary} [link]
>
> **Email:**
> 3. {subject} from {sender} — received {time} [link]
>
> For each, would you like to:
> **(a)** Draft a response now (I'll help compose it)
> **(b)** Snooze to tomorrow
> **(c)** Skip — no response needed"

For **(a)**: help the user draft a response. Present the draft for
approval before sending via MCP tools.

For **(b)**: add to evening.md carry-over with context.

For **(c)**: mark as resolved.

**If all communications are answered:**
> "All Slack messages and emails from today are responded to. Clean inbox!"

---

## Phase 7: Generate evening.md

Write to `<pwd>/<YYYY-MM-DD>/evening.md`. This file is consumed by
tomorrow's `wk:goodmorning` — structure it for machine readability.

```markdown
# Evening Summary — {YYYY-MM-DD}

## Achievements
{brag document from Phase 3}

## Meeting Notes
{compiled meeting summaries from Phase 4}

## Action Items for Tomorrow
- [ ] {item}: {context and source}
- [ ] {item}: {context and source}
- ...

## Carry-Over Items
- [ ] {morning brief item not completed}: {status and context}
- [ ] {snoozed Slack/email}: {summary and link}
- ...

## Deferred Communications
- [ ] Reply to @{sender} in #{channel}: {summary} [link]
- [ ] Reply to {email subject} from {sender} [link]
- ...

## Issues Created Today
- {repo}#{number}: {title} [link]
- {JIRA-KEY}: {title} [link]
- ...

## Open Questions
- {question from meeting}: {context}
- ...

## Day Stats
- Morning brief items: {total} ({completed} done, {remaining} remaining)
- Meetings attended: {count}
- PRs created/reviewed/merged: {counts}
- Issues closed: {count}
- Commits: {count}
```

After writing, inform the user:

> "Your evening wrap-up is complete:
> - `{date}/evening.md` — tomorrow's carry-over reference
>
> Today: {completed} items done, {remaining} carried forward,
> {issues_created} issues created, {meetings} meetings documented.
>
> {brag_highlight — the single most impactful thing you did today}"

---

## Service Connection Summary

| Service | ToolSearch query | Fallback |
|---------|-----------------|----------|
| Slack | `"slack"` | None — skip |
| Gmail | `"gmail"` | None — skip |
| Calendar | `"gcal"` | None — skip |
| Granola | `"granola"` | Manual meeting summary prompt |
| GitHub | `"github"` | `gh` CLI |
| Jira | `"jira"` | None — skip, carry forward in evening.md |
| Google Drive | `"gdrive"` | None — skip |

---

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| `/wk:goodevening` | Full evening wrap-up with all services |
| No morning.md | Gathers fresh context, still produces evening.md |
| Service unavailable | Skips that service, notes in output |
| All comms answered | Celebrates clean inbox |
