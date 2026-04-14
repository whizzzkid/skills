---
name: wk:goodmorning
description: >-
  Prepare for your day by connecting to Slack, Gmail, Calendar, Granola,
  Google Drive, and GitHub. Surfaces unread messages needing response,
  follow-ups on sent messages, meeting prep with agenda docs and past notes,
  PRs/issues needing attention, and yesterday's carry-over action items.
  Produces a structured morning.md and an interactive morning.html dashboard.
  Use at the start of your workday.
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

# Good Morning

Daily preparation skill that connects to all your work tools, gathers what
needs your attention, and produces an actionable dashboard for the day.

---

## Phase 1: Initialize

### Determine dates and paths

```bash
TODAY=$(date +%Y-%m-%d)
YESTERDAY=$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d "yesterday" +%Y-%m-%d)
MORNING_DIR="$PWD/$TODAY"
EVENING_FILE="$PWD/$YESTERDAY/evening.md"
```

Create today's output directory:

```bash
mkdir -p "$MORNING_DIR"
```

### Check for yesterday's evening summary

If `<pwd>/<YYYY-MM-DD-1>/evening.md` exists, read it and extract:

- Action items marked for today
- Carry-over items not completed
- Notes or context for today

If it does not exist, note this and continue — it is not an error.

---

## Phase 2: Connect to Services

For each service below, follow this connection pattern:

1. **Discover** — use `ToolSearch` to find MCP tools for the service
2. **Authenticate** — call the authenticate tool to start OAuth
3. **Wait** — after auth completes, operational tools become available
4. **If auth fails** — inform the user clearly:
   > "{Service} authentication failed. Please complete the OAuth flow at
   > the URL above, then tell me to continue."
5. **If no MCP tools exist** — skip the service and note it in the output:
   > "Skipped {service} — no MCP tools configured."

**Process services in order.** Each service builds on context from the
previous ones (e.g., calendar agenda docs need Drive access).

### Fallback for GitHub

If GitHub MCP tools are unavailable, fall back to the `gh` CLI:

```bash
gh api notifications --jq '.[] | {title: .subject.title, type: .subject.type, reason: .reason, url: .subject.url}'
```

---

## Phase 3: Slack

Use ToolSearch to find Slack MCP tools (search: `"slack"`). Authenticate
if needed.

### 3a. Unread notifications needing your input

Fetch unread messages and notifications. Filter for items that **require a
response or decision** from you:

- Direct messages you haven't replied to
- Mentions in channels where someone is waiting for your input
- Threads you're participating in with new replies
- Channel messages that explicitly ask you a question or tag you

**Exclude**: bot notifications, automated alerts, messages you've already
responded to.

### 3b. Follow-ups on your sent messages (last 7 days)

Search for messages **you** posted in the last 7 days that may need
follow-up:

- Messages you sent that received no reply (potential dropped threads)
- Questions you asked that got partial or unclear answers
- Threads you started that have new unread activity
- Action items you assigned to others — check if they responded

### 3c. Important announcements and share-outs

Search for messages from the last 24-48 hours that are likely important
announcements:

- Messages in announcement or general channels
- Messages with high reaction counts (> 5 reactions)
- Messages from leadership, team leads, or org-wide channels
- Share-outs, FYIs, and company-wide updates
- Messages linking to docs, slides, or recordings you should review

**For each item found, record:**
- Channel name and link to the message
- Sender
- Brief summary (1-2 sentences)
- Urgency: `action-required` | `follow-up` | `fyi`

---

## Phase 4: Gmail

Use ToolSearch to find Gmail MCP tools (search: `"gmail"`). Authenticate
if needed.

### 4a. Unread emails needing your input

Fetch unread emails from the inbox. Filter for items requiring action:

- Emails addressed directly to you (not just CC'd)
- Emails with questions or requests
- Emails from your manager, direct reports, or key stakeholders
- Calendar-related emails (meeting changes, RSVPs needed)

**Exclude**: newsletters, automated notifications, marketing, and emails
where you're just CC'd on a thread that doesn't need your input.

### 4b. Sent emails needing follow-up

Search sent mail from the last 7 days:

- Emails you sent that haven't been replied to
- Questions you asked that are still unanswered
- Requests you made where the deadline is approaching

### 4c. Important announcements

Search for emails from the last 24-48 hours that look like announcements:

- All-hands emails, org-wide updates
- Policy changes, HR announcements
- Emails from senior leadership

**For each item found, record:**
- Subject, sender, date
- Brief summary
- Urgency: `action-required` | `follow-up` | `fyi`
- Link if available

---

## Phase 5: Calendar

Use ToolSearch to find Calendar MCP tools (search: `"gcal"` or
`"calendar"`). Authenticate if needed.

### 5a. Fetch today's meetings

Get all calendar events for today. For each meeting, extract:

- Title, time, duration
- Attendees (and who organized it)
- Location or video link
- Description/notes field
- Whether it's a recurring meeting

### 5b. Recurring meetings — fetch past notes from Granola

For each **recurring** meeting:

1. Use ToolSearch to find Granola MCP tools (search: `"granola"`)
2. Authenticate if needed
3. Search for notes from previous instances of this meeting (match by
   title or attendees)
4. Extract key points, decisions, and open action items from the most
   recent 1-2 instances
5. Summarize what was discussed last time and what's likely to come up

If Granola is unavailable, note it and continue.

### 5c. Agenda docs — fetch from Google Drive/Docs

For each meeting that has a linked document (URL in the description,
attached agenda, or referenced Google Doc):

1. Use ToolSearch to find Google Drive or Docs MCP tools (search:
   `"gdrive"` or `"gdocs"`)
2. Authenticate if needed
3. Fetch the document content
4. Extract the agenda items, discussion points, and any pre-reads
5. Summarize the key points you need to prepare for

If the doc is not accessible, note the URL for manual review.

### 5d. Distill meeting prep

For each meeting, produce a prep block:

```
### {time} — {title} ({duration})
**Type**: recurring | one-off
**Attendees**: {list}
**Last time**: {summary from Granola, if recurring}
**Agenda**: {distilled points from doc, or "no agenda found"}
**Your prep**: {what you should review or prepare before this meeting}
```

---

## Phase 6: GitHub

Use ToolSearch to find GitHub MCP tools (search: `"github"`). If
unavailable, fall back to the `gh` CLI.

### 6a. PRs needing your review

```bash
gh search prs --review-requested=@me --state=open --json title,url,repository,author,createdAt
```

Or use MCP tools to fetch PRs where your review is requested.

### 6b. Your PRs needing attention

```bash
gh search prs --author=@me --state=open --json title,url,repository,reviews,checks
```

Flag PRs that have:
- New review comments you haven't addressed
- Failing CI checks
- Been open for more than 3 days without review
- Merge conflicts

### 6c. Assigned issues

```bash
gh search issues --assignee=@me --state=open --json title,url,repository,labels,createdAt
```

### 6d. Mentioned in issues/PRs

```bash
gh api notifications --jq '.[] | select(.reason == "mention" or .reason == "review_requested") | {title: .subject.title, type: .subject.type, url: .subject.url}'
```

**For each item, record:**
- Title, repo, URL
- Type: `pr-review` | `pr-authored` | `issue` | `mention`
- Age and urgency

---

## Phase 7: Previous Day Follow-ups

If yesterday's `evening.md` was found in Phase 1, present the action items
as a carry-over section:

- Items marked as incomplete
- Items deferred to today
- Blockers that were identified

If no evening.md exists, skip this section.

---

## Phase 8: Generate Outputs

### 8a. morning.md

Write to `<pwd>/<YYYY-MM-DD>/morning.md`. This is the structured reference
for the agent (and for `wk:goodevening` to review later).

```markdown
# Morning Brief — {YYYY-MM-DD}

## Yesterday's Carry-Over
- [ ] {action item from evening.md}
- ...

## Calendar
### {time} — {title}
- Type: recurring | one-off
- Attendees: ...
- Last time: {Granola summary}
- Agenda: {doc summary}
- Prep: ...

## Slack
### Needs Response
- [ ] #{channel} — @{sender}: {summary} [link]
### Follow-ups
- [ ] #{channel} — {your message summary, awaiting reply} [link]
### Announcements
- {summary} [link]

## Email
### Needs Response
- [ ] {subject} — from {sender} [link]
### Follow-ups
- [ ] {subject} — sent {date}, no reply [link]
### Announcements
- {summary}

## GitHub
### PRs to Review
- [ ] {repo}#{number} — {title} by @{author} [link]
### Your PRs
- [ ] {repo}#{number} — {title} ({status}) [link]
### Issues
- [ ] {repo}#{number} — {title} [link]

## Notes
_Space for anything that comes up during the day._
```

### 8b. morning.html

Write to `<pwd>/<YYYY-MM-DD>/morning.html`. This is a **self-contained**
interactive dashboard with embedded CSS and JS (no CDN dependencies).

**Required features:**

1. **Header** — date, greeting, overall progress bar (X of Y items done)
2. **Sections** — collapsible panels for each category:
   - Yesterday's Carry-Over
   - Calendar (meeting cards with prep notes)
   - Slack (tabs: Needs Response | Follow-ups | Announcements)
   - Email (tabs: Needs Response | Follow-ups | Announcements)
   - GitHub (tabs: PRs to Review | Your PRs | Issues)
3. **Checkboxes** — every actionable item has a checkbox
4. **Persistence** — checkbox state saves to `localStorage` keyed by date
5. **Priority badges** — `action-required` (red), `follow-up` (amber),
   `fyi` (blue)
6. **Links** — every item links to its source (Slack message, email,
   PR, calendar event)
7. **Meeting cards** — show time, title, attendees, Granola summary,
   agenda highlights, and a "prep notes" area
8. **Dark mode** — respect `prefers-color-scheme` media query
9. **Responsive** — works on desktop and mobile
10. **Print-friendly** — `@media print` hides interactive elements

**Design guidelines:**
- Clean, minimal, modern aesthetic
- System font stack (no external fonts)
- Subtle colors, clear hierarchy
- Sections default to expanded; user can collapse
- Progress bar updates in real-time as checkboxes are toggled

After writing both files, inform the user:

> "Your morning brief is ready:
> - `{date}/morning.md` — structured reference
> - `{date}/morning.html` — open in your browser for the interactive
>   dashboard
>
> You have X items needing action, Y follow-ups, and Z meetings today."

---

## Service Connection Summary

| Service | ToolSearch query | Auth tool pattern | Fallback |
|---------|-----------------|-------------------|----------|
| Slack | `"slack"` | `mcp__*slack*__authenticate` | None — skip |
| Gmail | `"gmail"` | `mcp__*gmail*__authenticate` | None — skip |
| Calendar | `"gcal"` | `mcp__*gcal*__authenticate` | None — skip |
| Granola | `"granola"` | `mcp__*granola*__authenticate` | None — skip |
| Google Drive | `"gdrive"` | `mcp__*gdrive*__authenticate` | None — skip |
| Google Docs | `"gdocs"` | `mcp__*gdocs*__authenticate` | None — skip |
| GitHub | `"github"` | `mcp__*github*__authenticate` | `gh` CLI |

---

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| `/wk:goodmorning` | Full morning prep with all services |
| Service auth fails | Prompt user, continue with remaining services |
| No evening.md | Skip carry-over section, note in output |
