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
  version: '2.4.0'
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
gathers what needs your attention, triages items interactively, and
produces an actionable dashboard.

```
Bootstrap ──► Parallel Fetch (5 agents) ──► Auto-resolve ──► Group-by-group Triage ──► Outputs
                │  Slack agent                  │                  │
                │  Gmail agent                  │  Use evening.md  │  ≤5 items/prompt
                │  Calendar+Granola+Drive       │  to pre-answer   │  one group at a time
                │  GitHub agent                 │  repeat items    │
                │  Jira+Confluence agent        │                  │
```

---

## Stage 0: Bootstrap

Run these sequentially — they're fast and everything else depends on them.

### Determine dates and paths

```bash
TODAY=$(date +%Y-%m-%d)
YESTERDAY=$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d "yesterday" +%Y-%m-%d)

# Today:     sitrep/<YYYY>/<MM>/<DD>/
# Yesterday: sitrep/<YYYY>/<MM>/<DD>/  (computed from yesterday's date)
TODAY_DIR="$PWD/sitrep/$(date +%Y)/$(date +%m)/$(date +%d)"
YESTERDAY_DIR="$PWD/sitrep/$(date -v-1d +%Y 2>/dev/null || date -d yesterday +%Y)/$(date -v-1d +%m 2>/dev/null || date -d yesterday +%m)/$(date -v-1d +%d 2>/dev/null || date -d yesterday +%d)"

# Weekly memory: sitrep/<YYYY>/<MM>/week-<WW>-memory.md
WEEK_NUM=$(date +%V)
MONTH_DIR="$PWD/sitrep/$(date +%Y)/$(date +%m)"
WEEK_MEMORY="$MONTH_DIR/week-${WEEK_NUM}-memory.md"

# Previous week (for rollover)
PREV_WEEK_NUM=$(date -v-7d +%V 2>/dev/null || date -d "7 days ago" +%V)
PREV_WEEK_MONTH_DIR="$PWD/sitrep/$(date -v-7d +%Y 2>/dev/null || date -d '7 days ago' +%Y)/$(date -v-7d +%m 2>/dev/null || date -d '7 days ago' +%m)"
PREV_WEEK_MEMORY="$PREV_WEEK_MONTH_DIR/week-${PREV_WEEK_NUM}-memory.md"

# Day of week (1=Monday ... 7=Sunday, ISO)
DOW=$(date +%u)

mkdir -p "$TODAY_DIR"
```

### Read yesterday's evening summary

If `<yesterday_dir>/evening.md` exists, read it and extract:

- Action items marked for today
- Carry-over items not completed
- Notes or context for today
- **Decision history** — what the user chose for each item yesterday
  (e.g., "carry forward", "skip", "GitHub issue created", "already done").
  Store these as the `prior_decisions` map keyed by item summary/identifier.

If it does not exist, note this and continue — it is not an error. Store
the extracted items as the `carry_over` dataset and `prior_decisions` map
for Stage 2.

### Read yesterday's morning summary

If `<yesterday_dir>/morning.md` exists, also read it to extract items
that were triaged yesterday. This provides a second source of
`prior_decisions` — if the user marked something "skip" or "already done"
yesterday morning, and the same item appears again today, use that
decision as the auto-answer.

### Load weekly memory

Read `$WEEK_MEMORY` if it exists. This file contains **recurring triage
rules** — items the user has consistently skipped or marked done across
multiple days this week. Weekly memory rules take priority over daily
`prior_decisions` during auto-resolution.

The file format:

```markdown
# Weekly Memory — Week {WW}, {YYYY}

## Auto-Skip Rules
Items matching these patterns are automatically skipped during triage.

- **pattern**: {identifier — e.g., "newsletter from @bot in #general"}
  **source**: {group — e.g., "Slack — Needs Response"}
  **reason**: {why — e.g., "user skipped 3 consecutive days"}
  **since**: {date rule was created}

## Auto-Done Rules
Items matching these patterns are automatically marked as already done.

- **pattern**: {identifier}
  **source**: {group}
  **reason**: {why}
  **since**: {date}

## User Notes
{Free-form notes the user added about recurring decisions}
```

Store the parsed rules as the `week_rules` dataset (list of
`{pattern, source, action, reason, since}` entries).

If the file does not exist, `week_rules` is empty — this is not an error.

### New week rollover

If **today is Monday** (`$DOW == 1`) **AND** `$WEEK_MEMORY` does not
yet exist **AND** `$PREV_WEEK_MEMORY` exists:

1. Read the previous week's memory file
2. Present each rule to the user for confirmation:

> "It's a new week. Last week you had {N} recurring triage rules.
> Let's confirm which ones still apply:
>
> 1. Auto-skip: {pattern} ({reason})
>    **(a)** Keep  **(b)** Remove  **(c)** Edit
>
> 2. Auto-done: {pattern} ({reason})
>    **(a)** Keep  **(b)** Remove  **(c)** Edit
>
> ...
>
> Reply with your choices, or **all:a** to keep everything."

3. Write `$WEEK_MEMORY` with confirmed rules (removing any the user
   chose to drop, updating any they edited)
4. If the user says "keep all" or doesn't respond, copy the previous
   week's rules verbatim into the new file

If it is **not Monday**, or the previous week's memory doesn't exist,
skip this step.

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

**IMPORTANT:** Before running any `gh` command, check that `$GITHUB_ORG`
is set (see `wk:gh`). All search commands MUST include
`--owner="$GITHUB_ORG"` to scope results to the user's organization.

Run all four queries (in parallel where the tool supports it):

**4a. PRs needing your review**
```bash
gh search prs --owner="$GITHUB_ORG" --review-requested=@me --state=open \
  --json title,url,repository,author,createdAt
```

**4b. Your PRs needing attention**
```bash
gh search prs --owner="$GITHUB_ORG" --author=@me --state=open \
  --json title,url,repository,reviews,checks
```
Flag: new review comments, failing CI, open > 3 days, merge conflicts.

**4c. Assigned issues**
```bash
gh search issues --owner="$GITHUB_ORG" --assignee=@me --state=open \
  --json title,url,repository,labels,createdAt
```

**4d. Mentions**
```bash
gh api notifications --jq ".[] | select(.repository.owner.login == \"$GITHUB_ORG\") | select(.reason == \"mention\" or .reason == \"review_requested\") | {title: .subject.title, type: .subject.type, url: .subject.url}"
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

## Stage 2: Compile and Triage

**Wait for all 5 agents to complete.** Merge their results with the
`carry_over` dataset from Stage 0.

### 2a. Interactive Triage

Before generating output files, triage all actionable items with the user.
Items are presented **one group at a time**, with a maximum of **5 items
per prompt**. Groups with more than 5 items are paginated across multiple
prompts.

#### Auto-resolution (weekly memory + prior day)

Before presenting any group, auto-resolve items using two sources in
priority order:

**Priority 1: Weekly memory rules** (`week_rules`)

Check each item against the `week_rules` patterns. Match by item
identifier, source group, or content pattern. If a rule matches:

| Rule type | Auto-answer | Rationale |
|-----------|-------------|-----------|
| Auto-skip | **(c) Skip** | User consistently skips this pattern |
| Auto-done | **(b) Already done** | User says this is always handled |

**Priority 2: Prior day decisions** (`prior_decisions`)

For items not matched by weekly rules, check against yesterday's
evening.md and morning.md decisions. An item is a **repeat** if it
matches a prior item by key identifiers (e.g., same Slack thread URL,
same PR number, same Jira key, same email subject+sender).

| Yesterday's decision | Today's auto-answer | Rationale |
|---------------------|---------------------|-----------|
| Carry forward / Will do | **(a) Will do** | User explicitly chose to keep it |
| Skip | **(c) Skip** | User explicitly chose to ignore it |
| Already done | **(c) Skip** | Was completed yesterday — shouldn't resurface |
| GitHub issue / Jira ticket created | **(b) Already done** | Tracked in an external system |
| Draft response sent | **(b) Already done** | Communication was handled |

**Announce auto-resolved items** at the start of each group. Distinguish
weekly-memory resolutions from daily resolutions:

> "Auto-resolved {N} items ({W} from weekly rules, {D} from yesterday's
> decisions). Review the remaining items below."

If all items in a group are auto-resolved, announce and move to the next
group — do not prompt.

#### Triage groups (in order)

Process groups in this order. Skip any group with 0 items:

1. **Yesterday's Carry-Over**
2. **Slack — Needs Response**
3. **Slack — Follow-ups**
4. **Email — Needs Response**
5. **Email — Follow-ups**
6. **GitHub — PRs to Review**
7. **GitHub — Your PRs**
8. **GitHub — Issues**
9. **Jira — Tickets**
10. **Jira — Mentions**
11. **Confluence — Mentions**

**FYI items** (announcements, Confluence updates, Slack share-outs) are
NOT triaged — they always appear in the dashboard as read-only entries.

#### Presentation format

For each group, present up to 5 items at a time. Each batch includes
**batch-level actions** that apply to all items in the batch, and
individual per-item options:

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
> e.g.: `1a 2c+m 3c` — skip item 2 and remember that choice.
>
> Reply with your choices."

Wait for the user's response, then present the next batch (if the group
has more than 5 items) or move to the next group.

#### The `+m` (remember) modifier

Any per-item or batch-level choice can have `+m` appended to save it as
a weekly memory rule. This works with any option:

| Input | Effect |
|-------|--------|
| `2c+m` | Skip item 2 AND add an auto-skip rule to weekly memory |
| `3a+m` | Will do item 3 AND add an auto-will-do rule to weekly memory |
| `all:c+m` | Skip entire batch AND add auto-skip rules for all items |

When `+m` is used, the agent extracts the **pattern** from the item
(not the specific instance) and writes it to `$WEEK_MEMORY`. Patterns
are derived from the item's distinguishing attributes:

| Item type | Pattern extracted |
|-----------|-----------------|
| Slack message | Channel name (e.g., "skip all from #alerts") |
| Email | Sender or subject pattern (e.g., "skip newsletters from noreply@") |
| GitHub PR/Issue | Repository name (e.g., "always will-do PRs from repo-x") |
| Jira ticket | Project key (e.g., "skip mentions from PROJECT-Y") |
| Confluence | Space name (e.g., "skip announcements from Engineering space") |
| Carry-over | Source description (e.g., "skip carry-overs from meeting X") |

After extracting the pattern, confirm with the user:

> "Saving weekly rule: **auto-skip items from #{channel}**.
> This will apply to all future items matching this pattern this week."

This confirmation is inline — no separate prompt. If the user says
"no" or "cancel", apply the action but don't save the rule.

#### Group-specific options

Every item always has the 3 base options. Groups may add extras:

| Group | Extra options |
|-------|-------------|
| Carry-Over | **(d)** Delegate (describe to whom) |
| Slack — Needs Response | **(d)** Reply now (draft inline) |
| Email — Needs Response | **(d)** Reply now (draft inline) |
| GitHub — PRs to Review | **(d)** Review now (opens PR) |
| GitHub — Your PRs | **(d)** Check CI / merge |
| Jira — Tickets | **(d)** Update status |
| Jira / Confluence — Mentions | **(d)** Reply now (draft inline) |

All options support the `+m` modifier.

#### Processing triage decisions

- **(a) Will do** → appears as an unchecked `[ ]` item in the dashboard
- **(b) Already done** → appears as a checked `[x]` item (pre-completed)
- **(c) Skip** → omitted from the dashboard entirely
- **(d) Group-specific** → execute the action (draft reply, open PR, etc.)
  then mark as `[ ]` or `[x]` depending on whether it was fully handled
- **Any + `+m`** → also write the pattern to `$WEEK_MEMORY` as an
  auto-rule (auto-skip, auto-done, or auto-will-do depending on the
  base option chosen)

If the user says "skip triage" at any point, default all remaining items
across all remaining groups to **(a) Will do**.

#### Update weekly memory

After triage is complete, scan today's decisions for patterns worth
remembering. An item becomes a **weekly rule candidate** when:

- The user chose **(c) Skip** for an item that was also skipped yesterday
  (same item skipped on 2+ consecutive days)
- The user chose **(b) Already done** for an item that was also marked
  done yesterday (same item done on 2+ consecutive days)

For each candidate not already in `week_rules`, ask:

> "You've skipped/marked-done `{pattern}` multiple days in a row.
> Should I auto-{skip/done} it for the rest of the week?
> **(a)** Yes, remember  **(b)** No, ask each time"

If the user confirms, add the rule to `$WEEK_MEMORY`. If the file
doesn't exist yet, create it with the standard format.

This step is **quick** — only fires when new patterns are detected
(usually 0-2 items). If no candidates, skip silently.

### 2b. morning.md

Write to `<today_dir>/morning.md`:

```markdown
# Morning Brief — {YYYY-MM-DD}

## Yesterday's Carry-Over
- [x] {item marked "already done" in triage}
- [ ] {item marked "will do" in triage}
{items marked "skip" are omitted}

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

**Triage decisions apply to all sections** — Slack, Email, GitHub, Jira,
and Carry-Over items are filtered based on the user's choices. Only "Will
do" (unchecked) and "Already done" (pre-checked) items appear.

### 2c. morning.html

Write to `<today_dir>/morning.html`. Self-contained interactive
dashboard — **no CDN dependencies**, all CSS and JS embedded.

**Required features:**

1. **Header** — date, greeting, overall progress bar (X of Y items done)
2. **Multi-column dashboard layout** — use CSS grid to fill the screen:
   - **3-column grid** on wide screens (>1200px), **2-column** on medium
     (768-1200px), **single column** on mobile (<768px)
   - Each section is a card that flows into the grid
   - Taller sections (Calendar, Carry-Over) may span 2 rows
   - Layout: `grid-template-columns: repeat(auto-fit, minmax(380px, 1fr))`
3. **Section cards** — collapsible panels for each category:
   - Yesterday's Carry-Over
   - Calendar (meeting cards with prep notes)
   - Slack (tabs: Needs Response | Follow-ups | Announcements)
   - Email (tabs: Needs Response | Follow-ups | Announcements)
   - GitHub (tabs: PRs to Review | Your PRs | Issues)
   - Jira (tabs: Assigned | Mentions)
   - Confluence (tabs: Mentions | Announcements)
4. **Checkboxes** — every actionable item has a checkbox. Items triaged
   as "Already done" render pre-checked with a strikethrough style.
   Items triaged as "Skip" are omitted entirely.
5. **Persistence** — checkbox state saves to `localStorage` keyed by date
6. **Priority badges** — `action-required` (red), `follow-up` (amber),
   `fyi` (blue)
7. **Links** — every item links to its source. **All links MUST use
   `target="_blank" rel="noopener noreferrer"`** to open in a new tab
8. **Meeting cards** — time, title, attendees, Granola summary, agenda
   highlights, prep notes area
9. **Dark mode** — respect `prefers-color-scheme`
10. **Responsive** — 3-col / 2-col / 1-col grid breakpoints
11. **Print-friendly** — `@media print` hides interactive elements,
    switches to single-column flow

**Design:** clean, minimal, system font stack, subtle colors, clear
hierarchy, sections default expanded, progress bar updates in real-time.
Cards have subtle border/shadow, consistent padding, and rounded corners.

### Open for review

After writing both files, open the HTML dashboard automatically:

```bash
open "$TODAY_DIR/morning.html"
```

Then announce:

> "Your morning brief is ready and opened in your browser:
> - `sitrep/{YYYY}/{MM}/{DD}/morning.md` — structured reference
> - `sitrep/{YYYY}/{MM}/{DD}/morning.html` — interactive dashboard
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
| Monday (new week) | Roll over previous week's memory, confirm rules |
| Item skipped 2+ days | Offer to add auto-skip rule to weekly memory |
| No weekly memory | Start fresh — no auto-rules applied |
