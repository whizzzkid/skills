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
  version: '2.0.0'
  model:
    openai: gpt-4.1
    google: gemini-2.5-pro
    meta: llama-4-maverick
    kimi: k2
    qwen: qwen3-235b
    cursor: composer-2
---

# Good Morning

Daily preparation skill that connects to all your work tools in parallel,
gathers what needs your attention, and produces an actionable dashboard.

```
Bootstrap ──► Parallel Fetch (5 agents) ──► Compile Outputs
                │  Slack agent
                │  Gmail agent
                │  Calendar+Granola+Drive agent
                │  GitHub agent
                │  Jira+Confluence agent
```

---

## Stage 0: Bootstrap

Run these sequentially — they're fast and everything else depends on them.

### Determine dates and paths

```bash
TODAY=$(date +%Y-%m-%d)
YESTERDAY=$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d "yesterday" +%Y-%m-%d)
mkdir -p "$PWD/$TODAY"
```

### Read yesterday's evening summary

If `<pwd>/<YYYY-MM-DD-1>/evening.md` exists, read it and extract:

- Action items marked for today
- Carry-over items not completed
- Notes or context for today

If it does not exist, note this and continue — it is not an error. Store
the extracted items as the `carry_over` dataset for Stage 2.

---

## Stage 1: Parallel Data Gathering

**Launch 5 agents in parallel** using the Agent tool. Each agent handles
its own MCP authentication and data fetching independently. If any agent
fails to authenticate, it returns a skip notice — it does not block the
others.

### MCP Connection Pattern (shared by all agents)

Each agent follows this pattern for its service:

1. `ToolSearch` to find MCP tools for the service
2. Call the authenticate tool to start OAuth
3. After auth completes, use the operational tools
4. **If auth fails** → **STOP the agent** and return an error:
   `"BLOCKED: {Service} authentication failed. User must complete OAuth at: {url}"`
5. **If no MCP tools found** → **STOP the agent** and return an error:
   `"BLOCKED: {Service} MCP tools not configured. User must install the MCP server."`

**No service is optional.** If any agent returns a BLOCKED error, pause
output generation and present ALL blocked services to the user at once:

> "The following services need your attention before I can continue:
>
> 1. {Service}: {reason and action needed}
> 2. {Service}: {reason and action needed}
>
> Please fix these and tell me to continue."

**Do not proceed to Stage 2 until all agents succeed.** After the user
fixes access, re-run only the failed agents.

---

### Agent 1: Slack

**ToolSearch query:** `"slack"`

Fetch all three datasets and return them as structured results:

**1a. Unread notifications needing your input**

Items that **require a response or decision** from you:

- Direct messages you haven't replied to
- Mentions in channels where someone is waiting for your input
- Threads you're participating in with new replies
- Channel messages that explicitly ask you a question or tag you

**Exclude**: bot notifications, automated alerts, already-responded messages.

**1b. Follow-ups on your sent messages (last 7 days)**

Messages **you** posted that may need follow-up:

- Messages you sent that received no reply (dropped threads)
- Questions you asked with partial or no answers
- Threads you started with new unread activity
- Action items you assigned to others — check if they responded

**1c. Important announcements and share-outs (last 24-48h)**

- Messages in announcement or general channels
- Messages with high reaction counts (> 5 reactions)
- Messages from leadership, team leads, or org-wide channels
- Share-outs, FYIs, company-wide updates
- Messages linking to docs, slides, or recordings

**Return format per item:**
- Channel name and message link
- Sender
- Brief summary (1-2 sentences)
- Urgency: `action-required` | `follow-up` | `fyi`

---

### Agent 2: Gmail

**ToolSearch query:** `"gmail"`

Fetch all three datasets and return them as structured results:

**2a. Unread emails needing your input**

- Emails addressed directly to you (not just CC'd)
- Emails with questions or requests
- Emails from your manager, direct reports, or key stakeholders
- Calendar-related emails (meeting changes, RSVPs needed)

**Exclude**: newsletters, automated notifications, marketing, CC-only.

**2b. Sent emails needing follow-up (last 7 days)**

- Emails you sent that haven't been replied to
- Questions you asked that are still unanswered
- Requests where the deadline is approaching

**2c. Important announcements (last 24-48h)**

- All-hands emails, org-wide updates
- Policy changes, HR announcements
- Emails from senior leadership

**Return format per item:**
- Subject, sender, date
- Brief summary
- Urgency: `action-required` | `follow-up` | `fyi`
- Link if available

---

### Agent 3: Calendar + Granola + Google Drive

This agent handles three services because they have internal dependencies:
calendar results drive Granola and Drive lookups.

**Step 1: Fetch today's meetings**

ToolSearch query: `"gcal"` or `"calendar"`

For each event, extract:
- Title, time, duration
- Attendees (and organizer)
- Location or video link
- Description/notes field
- Whether it's a recurring meeting
- Any linked document URLs in the description

**Step 2: Enrich recurring meetings with Granola (parallel per meeting)**

ToolSearch query: `"granola"`

For each **recurring** meeting, search Granola for notes from previous
instances (match by title or attendees). Extract from the most recent 1-2
instances:
- Key points and decisions
- Open action items
- What was discussed last time

If Granola is unavailable, return BLOCKED error — do not continue without it.

**Step 3: Enrich meetings with agenda docs (parallel per meeting)**

ToolSearch query: `"gdrive"` or `"gdocs"`

For each meeting with a linked document URL in its description:
- Fetch the document content
- Extract agenda items, discussion points, and pre-reads
- Summarize key points to prepare for

If Google Drive/Docs is unavailable, return BLOCKED error. If a
specific doc is inaccessible (permissions), note the URL for manual review
but do not block on individual docs.

**Return format per meeting:**

```
{time} — {title} ({duration})
Type: recurring | one-off
Attendees: {list}
Last time: {Granola summary, or "N/A"}
Agenda: {doc summary, or "no agenda found"}
Prep: {what to review or prepare}
```

---

### Agent 4: GitHub

**ToolSearch query:** `"github"` — if unavailable, use `gh` CLI.

Run all four queries (in parallel where the tool supports it):

**4a. PRs needing your review**
```bash
gh search prs --review-requested=@me --state=open \
  --json title,url,repository,author,createdAt
```

**4b. Your PRs needing attention**
```bash
gh search prs --author=@me --state=open \
  --json title,url,repository,reviews,checks
```
Flag: new review comments, failing CI, open > 3 days, merge conflicts.

**4c. Assigned issues**
```bash
gh search issues --assignee=@me --state=open \
  --json title,url,repository,labels,createdAt
```

**4d. Mentions**
```bash
gh api notifications --jq '.[] | select(.reason == "mention" or .reason == "review_requested") | {title: .subject.title, type: .subject.type, url: .subject.url}'
```

**Return format per item:**
- Title, repo, URL
- Type: `pr-review` | `pr-authored` | `issue` | `mention`
- Age and urgency

---

### Agent 5: Jira + Confluence

**ToolSearch query:** `"jira"` or `"confluence"`

Jira and Confluence share a single MCP server — one authentication covers
both.

**5a. Jira tickets needing your attention**

- Tickets assigned to you that are open or in progress
- Tickets where you were mentioned in a comment
- Tickets you're watching that have new activity
- Tickets with approaching or overdue due dates

**5b. Jira notifications and mentions**

- Comments on tickets that mention you or request your input
- Status changes on tickets you're involved with
- New tickets assigned to you since yesterday

**5c. Confluence mentions and announcements**

- Pages or comments where you were mentioned
- Recently updated pages in spaces you follow
- New blog posts or announcements in team/org spaces
- Pages shared directly with you
- Meeting notes or decision pages that reference you

**For each item found, record:**
- Title, space/project, URL
- Type: `jira-ticket` | `jira-mention` | `confluence-mention` | `confluence-announcement`
- Brief summary
- Urgency: `action-required` | `follow-up` | `fyi`

---

## Stage 2: Compile Outputs

**Wait for all 5 agents to complete.** Merge their results with the
`carry_over` dataset from Stage 0.

### 2a. morning.md

Write to `<pwd>/<YYYY-MM-DD>/morning.md`:

```markdown
# Morning Brief — {YYYY-MM-DD}

## Yesterday's Carry-Over
- [ ] {action item from evening.md}

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

## Jira
### Assigned Tickets
- [ ] {JIRA-KEY}: {title} ({status}) [link]
### Mentions
- [ ] {JIRA-KEY}: {commenter} mentioned you — {summary} [link]

## Confluence
### Mentions
- [ ] {page title} — @{author} mentioned you [link]
### Announcements
- {page title} — {space} [link]

## Notes
_Space for anything that comes up during the day._
```

### 2b. morning.html

Write to `<pwd>/<YYYY-MM-DD>/morning.html`. Self-contained interactive
dashboard — **no CDN dependencies**, all CSS and JS embedded.

**Required features:**

1. **Header** — date, greeting, overall progress bar (X of Y items done)
2. **Sections** — collapsible panels for each category:
   - Yesterday's Carry-Over
   - Calendar (meeting cards with prep notes)
   - Slack (tabs: Needs Response | Follow-ups | Announcements)
   - Email (tabs: Needs Response | Follow-ups | Announcements)
   - GitHub (tabs: PRs to Review | Your PRs | Issues)
   - Jira (tabs: Assigned | Mentions)
   - Confluence (tabs: Mentions | Announcements)
3. **Checkboxes** — every actionable item has a checkbox
4. **Persistence** — checkbox state saves to `localStorage` keyed by date
5. **Priority badges** — `action-required` (red), `follow-up` (amber),
   `fyi` (blue)
6. **Links** — every item links to its source
7. **Meeting cards** — time, title, attendees, Granola summary, agenda
   highlights, prep notes area
8. **Dark mode** — respect `prefers-color-scheme`
9. **Responsive** — works on desktop and mobile
10. **Print-friendly** — `@media print` hides interactive elements

**Design:** clean, minimal, system font stack, subtle colors, clear
hierarchy, sections default expanded, progress bar updates in real-time.

### Announce

After writing both files:

> "Your morning brief is ready:
> - `{date}/morning.md` — structured reference
> - `{date}/morning.html` — open in your browser
>
> You have X items needing action, Y follow-ups, and Z meetings today.
>
> Would you like to commit and push these files?"

---

## Service Connection Summary

| Service | ToolSearch | Agent | Fallback |
|---------|-----------|-------|----------|
| Slack | `"slack"` | 1 | **BLOCKED** — require MCP |
| Gmail | `"gmail"` | 2 | **BLOCKED** — require MCP |
| Calendar | `"gcal"` | 3 | **BLOCKED** — require MCP |
| Granola | `"granola"` | 3 | **BLOCKED** — require MCP |
| Google Drive/Docs | `"gdrive"` / `"gdocs"` | 3 | **BLOCKED** — require MCP |
| GitHub | `"github"` | 4 | `gh` CLI (always available) |
| Jira + Confluence | `"jira"` / `"confluence"` | 5 | **BLOCKED** — require MCP |

---

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| `/wk:goodmorning` | Full morning prep — 5 parallel agents |
| Service auth fails | Block and prompt user to fix, re-run failed agents |
| No evening.md | Skip carry-over section, note in output |
