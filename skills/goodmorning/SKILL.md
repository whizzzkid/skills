---
name: wk-goodmorning
description: >-
  Prepare for your day by connecting to Slack, Gmail, Calendar, Granola,
  Google Drive, and GitHub. Surfaces unread messages needing response,
  follow-ups on sent messages, meeting prep with agenda docs and past notes,
  PRs/issues needing attention, and yesterday's carry-over action items.
  Produces a structured morning.md and an interactive morning.html dashboard.
  Use at the start of your workday.
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

# Prefer the last_working_day marker written by wk-goodevening.
# This correctly handles Monday (previous working day = Friday, not Sunday).
LAST_WD_FILE="$PWD/sitrep/last_working_day"
if [ -f "$LAST_WD_FILE" ]; then
  YESTERDAY=$(cat "$LAST_WD_FILE")
else
  # Fallback: previous calendar day (may be a weekend — used only when
  # goodevening has never run or the file is missing).
  YESTERDAY=$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d "yesterday" +%Y-%m-%d)
fi

# Today:     sitrep/<YYYY>/<MM>/<DD>/
# Yesterday: derived from $YESTERDAY (last working day, not last calendar day)
TODAY_DIR="$PWD/sitrep/$(date +%Y)/$(date +%m)/$(date +%d)"
YESTERDAY_DIR="$PWD/sitrep/$(echo "$YESTERDAY" | cut -d- -f1)/$(echo "$YESTERDAY" | cut -d- -f2)/$(echo "$YESTERDAY" | cut -d- -f3)"

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

### Idempotency check — has today's brief already been generated?

Before doing any data fetch or triage, check whether today's output
artifacts already exist:

```bash
test -f "$TODAY_DIR/morning.md" || test -f "$TODAY_DIR/morning.html"
```

If either exists, read its **generator version** from the frontmatter
(see "Brief versioning" below — markdown has `generated_with:` in YAML
frontmatter; HTML has `<meta name="generated-with-version" ...>`).
Compare against this skill's current `metadata.version`:

| Stored version | Action |
|----------------|--------|
| Missing (legacy brief, no annotation) | Treat as older — prompt to regenerate. |
| **Older** than current | **Auto-regenerate** without prompting. The skill has improved since this brief was written; the user wants the new behavior. Announce: "Today's brief was generated with v{stored}; current is v{current}. Regenerating." |
| **Equal or newer** | Prompt the user (existing flow below) — re-running is expensive and would overwrite hand-edits and checkbox state. |

CalVer ordering is lexicographic (`YYYY.MM.DD-HHMMSS` UTC), so a plain
string compare is correct: `[ "$STORED" \< "$CURRENT" ]` means stored
is older.

Read the existing `morning.md` and surface a short summary for the
prompt path:
- Generation timestamp (file mtime)
- Generator version (from frontmatter)
- Item counts per section (`needs response`, `PRs to review`, etc.)
- Any items already checked off

Then prompt (only when stored version is equal/newer):

> "Today's morning brief already exists at
> `sitrep/{YYYY}/{MM}/{DD}/morning.md` (generated {mtime} with
> v{stored}, {N} actionable items, {C} completed).
>
> **(a)** Open the existing brief — no regeneration
> **(b)** Regenerate from scratch — overwrites current files
> **(c)** Cancel
>
> Reply with your choice."

| Choice | Behavior |
|--------|----------|
| (a) | `open "$TODAY_DIR/morning.html"` and exit. Skip all remaining stages. |
| (b) | Continue to Stage 1. The user has explicitly accepted overwrite. |
| (c) | Exit silently. |

Auto mode is **not** an exemption for the prompt path — silently
overwriting today's brief defeats the user's prior triage. In auto
mode, default to **(a)** and note the skip in the run summary. The
auto-regenerate-on-older-version path runs in auto mode without
prompting (the version delta is itself the user's prior consent —
they bumped the skill).

### Read yesterday's evening summary

If `<yesterday_dir>/evening.md` exists, read it and extract:

- Action items marked for today
- Carry-over items not completed
- Notes or context for today
- **Tomorrow's Meeting Prep** items — prep work the user flagged for
  today's meetings during last night's wrap-up
- **Yesterday's Meeting Follow-Through** — action items, tickets to
  file, share-outs to post, and decisions to communicate that came out
  of yesterday's meetings (from Granola notes). These become triage
  items in Stage 2.
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

### Interview prep scaffolding

Invoke `wk-cal §Interview Prep Scan` via the Skill tool before launching
the parallel agents. This ensures prep and scorecard blocks are created on
the calendar before Agent 3 fetches today's/tomorrow's events — so they
appear correctly in the meeting timeline.

The scan runs silently. Surface its output as an **Interview Scaffolding**
section in the final morning brief only when blocks were created or when a
conflict was found that needs manual action.

---

## Stage 1: Parallel Data Gathering

**Launch 5 agents in parallel** using the Agent tool. Each agent handles
its own MCP authentication and data fetching independently. If any agent
fails to authenticate, it returns a skip notice — it does not block the
others.

### Subagent contract (mandatory — include in every Stage 1 prompt)

> Canonical source: [`skills/goodmorning/references/subagent-contract.md`](./references/subagent-contract.md)

Every agent dispatched in this stage is a **data-gathering subagent**,
not a co-orchestrator. When the subagent reads this skill's instructions
as part of its context, it may mistake itself for the orchestrator and
run the entire skill — writing output files, committing, or prompting
the user. Prevent this by prepending the following contract to every
Stage 1 agent prompt verbatim:

```
SUBAGENT CONTRACT (mandatory):
- Return STRUCTURED DATA ONLY — do not write files, run git commands, or commit
- Do NOT invoke /skills or act as the wk-goodmorning orchestrator
- Do NOT prompt the user for input — the orchestrator handles all triage
- Do NOT open files in browsers or call `open`
- Your output is markdown text the orchestrator pastes into a section
- EVERY item you return that could become a priority MUST include a
  source identifier: a URL, MCP deep link, file path, or
  `{system}:{id}` reference. Items without a source identifier will
  be rejected at compile time. If the item came from a meeting note,
  return the meeting URL or ID alongside the extracted insight; if
  from a Slack message, return the permalink; if inferred, mark
  `(inferred)` and list the source artifacts the inference used.
- Distinguish verified facts from single-source claims. Tag each
  item `verified` (concrete artifact like a calendar invite, Jira
  ticket, PR URL, explicit announcement) or `claim` (extracted from
  someone's offhand remark in a meeting/DM and not cross-checked).
  The orchestrator uses this to choose render styling and conflict
  detection.
```

Before compiling outputs in Stage 2, the orchestrator must verify git
state (no unexpected commits, no uncommitted files outside the session's
intended sitrep paths) — a subagent that overran its scope will show up
here.

### MCP Connection Pattern (shared by all agents)

> See also: [`skills/goodmorning/references/subagent-contract.md`](./references/subagent-contract.md) — canonical copy of this pattern and the soft/hard blocker table.

Each agent follows this pattern for its service:

1. `ToolSearch` to find MCP tools for the service
2. Call the authenticate tool to start OAuth
3. After auth completes, use the operational tools
4. **If auth fails (OAuth URL returned)** → return a **SOFT BLOCK**:
   `"SOFT_BLOCKED: {Service} needs authorization at: {url}"`
5. **If no MCP tools found or missing secret** → return a **HARD BLOCK**:
   `"HARD_BLOCKED: {Service} MCP tools not configured. User must install the MCP server."`

### Soft vs hard blockers

Distinguish between blockers that require a user click (OAuth) and
blockers that require setup the agent cannot resolve (missing MCP
server, missing secret, network failure). OAuth cannot be completed by
the agent, but the brief is still useful if we surface the auth URL and
fall back to carry-over data.

| Type | Example | Behavior |
|------|---------|----------|
| **Hard** | MCP not installed, missing secret | Stop output; list all hard blocks; require user fix before continuing |
| **Soft** | OAuth URL returned | Continue with degraded data; embed the authorization URL in the affected section; note in the summary |

If ANY hard block occurs, pause and present all hard blocks at once:

> "The following services need your attention before I can continue:
>
> 1. {Service}: {reason and action needed}
>
> Please fix these and tell me to continue."

If only soft blocks occur, proceed to Stage 2. For each soft-blocked
service:
- Use yesterday's morning.md / evening.md as a fallback data source
  (surface as "Known items — from yesterday"). If no prior data exists,
  leave the section empty.
- Embed the authorization URL as a prominent **⚠ Authorize {Service}**
  CTA in the corresponding dashboard section.
- List the soft block in the final summary so the user knows the
  section is degraded.

After the user fixes access, re-run only the failed agents.

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

Follow `wk-cal §Fetch Day Events` — ToolSearch for `"gcal"` or `"calendar"`,
then list today's events. For each event extract: title, time, duration,
attendees (organizer flagged), location/video link, description, recurrence
flag, and any linked document URLs.

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
is set (see `wk-gh`). All search commands MUST include
`--owner="$GITHUB_ORG"` to scope results to the user's organization.

Run all four queries (in parallel where the tool supports it):

**Exclude Draft/WIP PRs from action items.** A PR is an action item only
when it is ready for review. Drafts signal "not ready" and must not
surface in 4a or 4b. Use `--draft=false` on every `gh search prs` call
below. If a fallback tool does not support `--draft`, filter the result
set by `isDraft == false` (and drop any title prefixed with `[WIP]`,
`WIP:`, or `Draft:`) before returning items.

**4a. PRs needing your review**
```bash
gh search prs --owner="$GITHUB_ORG" --review-requested=@me --state=open \
  --draft=false \
  --json title,url,repository,author,createdAt,isDraft
```

**4b. Your PRs needing attention**
```bash
gh search prs --owner="$GITHUB_ORG" --author=@me --state=open \
  --draft=false \
  --json title,url,repository,reviews,checks,isDraft
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

#### Non-interactive / auto mode

When the harness signals auto mode (or otherwise directs the agent to
minimize interruptions), **skip interactive prompting**:

1. Still run auto-resolution (weekly memory + prior-day decisions) as
   normal.
2. For items that remain unresolved, default to **(a) Will do** —
   include them as unchecked `[ ]` items in the dashboard.
3. Do not commit new weekly-memory rules automatically. If a candidate
   pattern is detected (e.g., skipped 2+ days in a row), record it as
   "pending confirmation" in `$WEEK_MEMORY` under a `## Pending Rules`
   section for the user to approve the next interactive run.
4. Add a banner to the dashboard header:
   > "Auto-triaged — {N} items defaulted to 'Will do'. Edit morning.md
   > to override."

Skip the rest of Stage 2a (presentation format, group-specific options,
`+m` modifier, weekly memory updates) when in auto mode.

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

1. **Today's Meeting Prep** — prep actions flagged in last night's
   evening.md (agenda docs to read, demos to prepare, updates to gather)
2. **Yesterday's Meeting Follow-Through** — action items from
   yesterday's meetings that need follow-up today (tickets to file,
   share-outs to post, decisions to communicate, open questions to
   chase). Extracted from evening.md's Granola meeting notes.
3. **Yesterday's Carry-Over**
4. **Slack — Needs Response**
5. **Slack — Follow-ups**
6. **Email — Needs Response**
7. **Email — Follow-ups**
8. **GitHub — PRs to Review**
9. **GitHub — Your PRs**
10. **GitHub — Issues**
11. **Jira — Tickets**
12. **Jira — Mentions**
13. **Confluence — Mentions**

**FYI items** (announcements, Confluence updates, Slack share-outs) are
NOT triaged — they always appear in the dashboard as read-only entries.

#### Presentation format

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
  [`references/triage-link-sources.md`](references/triage-link-sources.md).

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
| Today's Meeting Prep | **(d)** Open doc now  **(e)** Defer to before meeting |
| Meeting Follow-Through | **(d)** Create GitHub issue  **(e)** Create Jira ticket  **(f)** Post share-out now |
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

### Checkbox rule for summary/priorities lists

**Every item in the "Today's Priorities" / "Today's Focus" list MUST
render as a checkable item** — never plain bullets. The priorities
list is the user's working surface throughout the day; without
checkboxes there's no place to mark progress, and the user is forced
to scroll to the downstream section to tick items off.

- **markdown** (`morning.md`): `- [ ] {priority text} [link]` for
  unstarted, `- [x] {priority text} [link]` for items already
  completed (carry-over marked done in triage).
- **html** (`morning.html`): real `<input type="checkbox">` elements
  with `localStorage` persistence keyed by date — same mechanism the
  downstream section cards use. Tick state in the priorities list
  must round-trip through `localStorage` (so a refresh preserves
  what's been marked).
- **Synthesized priorities** with no upstream artifact (e.g., "Adjust
  system prompt") still get a checkbox — the user wants to mark them
  done too.

Empty priorities list: render an italicized "Nothing flagged for
today" placeholder, not a missing slot.

### Source-link rule for summary/priorities lists

Whenever the brief renders a consolidated "Today's Priorities", "Today's
Focus", or any other top-level summary list derived from items that
already appear in a downstream section (Slack, Email, GitHub, Jira,
Calendar, Google Docs, Buildkite, Datadog, etc.), **every priority item
MUST carry inline source link(s)** in the same format it would have in
its home section. The summary is the highest-traffic view — users scan
it first and return to it throughout the day — so paraphrased-only
entries force extra clicks exactly where they hurt most.

Rules:

- If a priority maps to one upstream artifact, inline a single
  `[label](url)` (markdown) or `<a>` chip (html) link.
- If it maps to multiple (e.g., a PR + the Slack thread requesting
  review + a design doc), include all of them separated by ` · `.
- Synthesized or purely internal priorities with no external artifact
  (e.g., "Adjust system prompt") are exempt.
- Apply to both markdown (2b) and html (2c) output. Never render a
  priority list without origin links when the upstream section has them.

Categories to surface when present: Slack threads/DMs, GitHub PRs/issues,
Jira tickets, Calendar Zoom URLs (for time-blocked priorities), Google
Doc/Drive URLs, Buildkite/Datadog/external tool URLs.

**Internal sources count too.** When the upstream artifact is internal
(meeting notes, prior-day brief carry-over, agent inference) instead of
an external URL, the priority must still carry a citation. The rule is
"every priority is traceable to its source," not "every priority has an
https link." Use these forms:

- Meeting note → `granola://meeting/<id>` deep link, or
  `(Granola: {meeting-title} {YYYY-MM-DD})` inline if no deep link is
  available.
- Carry-over from yesterday's `evening.md` / earlier `morning.md` →
  `(carry-over from {YYYY-MM-DD})` linking to the relative file path.
- Agent-derived inference (e.g., "PR #X looks superseded by #Y") →
  `(inferred)` annotation plus links to the underlying artifacts the
  inference referenced.
- Pure synthesis with no upstream artifact at all (e.g., "Adjust
  system prompt") → exempt as before.

A priority with no traceable source must not be rendered. The render
pass below rejects such items.

### Claim-confidence annotation

Single-source claims extracted from meeting notes or DMs are not
verified facts and must not render with the same weight as items
backed by a concrete artifact (calendar invite, Jira ticket, PR URL,
explicit announcement). Distinguish at render time:

- `(verified: <link>)` — backed by a concrete external artifact.
  Renders in the default style.
- `(claim: {source})` — single-source claim that has not been
  cross-checked against another data point. Render in a softer style
  (italics in markdown, muted color in HTML) so it does not read as
  an authoritative deadline.

When promoting a `(claim: ...)` item to a hard priority — top-of-list
or "deadline today" framing — the renderer must flip it back to
`(claim: ...)` styling **and** carry a `?` or `unverified` marker so
the user can spot it at a glance.

### Cross-source conflict detection

Before emitting any priority, cross-check it against the other
gathered sources for the day. If a single-source claim contradicts
another data point — e.g., a meeting note's "deadline tomorrow"
versus a calendar invite's "AMA next week" or a Gmail
announcement's later date — flag inline rather than silently
picking one source:

```
- [ ] {item} ⚠ conflicts with: {other source link}  (claim: {origin})
```

Conflict detection is a Stage 2 step that runs after all Stage 1
agents have returned and before the priorities slot is built.

### 2.0. Template discovery (run before 2b and 2c)

The brief's structure is **owned by the user**, not the skill. Before
rendering either output file, look for a user-maintained template in
the repo and use the first one found. The built-in template embedded
in this skill is a fallback only.

**Discovery cascade:**

| Output | Lookup order |
|--------|--------------|
| `morning.html` | `<repo_root>/_templates/morning/brief.html` → built-in |
| `morning.md`   | `<repo_root>/_templates/morning/brief.md` → built-in |

**Template contract.** A template is a static skeleton plus two kinds
of placeholders:

- **Scalar tokens** as `{{KEY}}` — e.g., `{{DATE_ISO}}`, `{{DATE_LONG}}`,
  `{{STORAGE_KEY}}`. Replaced by string substitution.
- **Block slots** as `<!-- SLOT:name -->` — replaced with the rendered
  HTML/markdown fragment for that section. Use the same comment marker
  in markdown templates (it survives as a literal text marker the
  renderer can find).

Standard slot names: `resolved_badges`, `priorities`, `calendar`,
`meeting_followthrough`, `carryover`, `slack_response`, `slack_followup`,
`slack_announce`, `email_response`, `email_followup`, `email_announce`,
`github_review`, `github_yours`, `github_issues`, `jira_assigned`,
`jira_mentions`, `confluence`, `lattice`, `peer_feedback`, plus
matching `{slot}_count` scalars for badge totals.

**Render flow:**

1. Resolve template path via the cascade above.
2. Load template as a string.
3. Substitute every `{{KEY}}` scalar.
4. For each slot, build the section fragment from the triaged data and
   replace the slot marker (or the entire line containing it, to keep
   indentation tidy).
5. If a slot has no items, inject an empty-state placeholder
   (`<div class="empty">…</div>` for HTML, an italicized "Nothing for
   this section" for markdown). Never leave a naked `<!-- SLOT:name -->`
   in the rendered output.
6. Write the result to the date-stamped output path.

**Source-link enforcement at render time.** The `priorities` slot
builder MUST emit inline source links (`slack ↗ · doc ↗ · zoom ↗` for
HTML, `[label](url) · …` for markdown) for every priority that maps to
an external artifact, **and** an internal-source citation
(`(Granola: ...)`, `(carry-over from ...)`, `(inferred)`) for every
priority backed by an internal source. This rule is structural — embed
it in the slot builder so it cannot be forgotten on a per-run basis.
Pure synthesis with no upstream artifact at all is exempt.

**Reject sourceless items.** When building the priorities slot, drop
any item whose Stage 1 source identifier is missing or empty. Either
re-fetch with a sourcing prompt to the agent, demote the item out of
priorities, or render it as a `(claim: unsourced)` line in a softer
style — never promote a sourceless item to a hard priority.

**Confidence-aware styling.** Items tagged `claim` from Stage 1 must
render with the softer style described in the claim-confidence
annotation rule above. The slot builder reads the tag and chooses
the styling — it does not silently flatten claims into the default
authoritative style.

**Auto mode does not silently resolve high-impact uncertainty.** Auto
mode skips routine triage prompts; it does not let a single-source
`claim` flagged as `unverified-but-promoted-to-priority` (top-of-list
or "deadline today" framing) pass without a one-time confirmation.
Before rendering such an item as a hard priority in auto mode, surface
a single yes/no prompt to the user with the source and the
conflicting / corroborating data points. The exception applies only
to claims that would shift the user's day if wrong — routine claims
remain auto-handled.

**Checkbox enforcement at render time.** The `priorities` slot
builder MUST also emit a checkbox for every priority — `- [ ]` /
`- [x]` in markdown, `<input type="checkbox">` with
`localStorage`-backed state in HTML. Apply to synthesized priorities
too. Pair with the source links above: `- [ ] Ship review for {pr}
[pr ↗] · [thread ↗]`.

**Bootstrap.** If neither template exists, optionally offer to seed
`<repo_root>/_templates/morning/brief.html` and `…/brief.md` from the
built-in skeleton on first run, so the user can evolve the design from
there. After bootstrapping, switch to the user-maintained template on
the next run.

**Why this matters.** The data the brief surfaces changes daily; the
shape it appears in should not. Loading the skeleton from disk
guarantees that user style edits persist day-over-day, the skill's job
shrinks to "gather + triage + emit fragments", and other sitrep skills
(e.g., `wk-goodevening`, evening.md/.html) adopt the same convention
under `<repo_root>/_templates/<skill>/`.

The built-in templates described in 2b and 2c below are the **fallback
only** — they document the slot/scalar contract that any custom
template must satisfy.

### Brief versioning (applies to 2b and 2c)

Every generated brief MUST embed the generator's `metadata.version`
so the next run can detect "is this brief older than the current
skill?" without parsing prose. Read the value from this skill's own
frontmatter at runtime — never hardcode.

- **markdown** (`morning.md`): YAML frontmatter at the top of the
  file with the keys `generated_with`, `generated_with_skill`, and
  `generated_at` (ISO-8601 UTC):

  ```markdown
  ---
  generated_with: 2026.04.27-190851
  generated_with_skill: wk-goodmorning
  generated_at: <timestamp>
  ---

  # Morning Brief — {YYYY-MM-DD}
  ```

- **html** (`morning.html`): `<meta>` tags inside `<head>` with
  matching values:

  ```html
  <meta name="generated-with-version" content="2026.04.27-190851">
  <meta name="generated-with-skill" content="wk-goodmorning">
  <meta name="generated-at" content="<timestamp>">
  ```

The Stage 0 idempotency check reads `generated_with` (markdown YAML
or HTML meta) and string-compares against this skill's current
`metadata.version`. CalVer (`YYYY.MM.DD-HHMMSS` UTC) is lexicographic,
so plain `<` comparison gives the correct ordering.

If the user-maintained template (per the discovery cascade) does not
already include these annotations, the renderer must inject them
before writing the file — they are non-negotiable structural metadata,
not user-customizable design.

### 2b. morning.md

Write to `<today_dir>/morning.md`:

```markdown
---
generated_with: {SKILL_VERSION}
generated_with_skill: wk-goodmorning
generated_at: {ISO_8601_UTC}
---

# Morning Brief — {YYYY-MM-DD}

## Today's Meeting Prep
- [ ] {time} — {meeting title}: {prep action}
- [x] {time} — {meeting title}: {prep done yesterday evening}

## Yesterday's Meeting Follow-Through
- [ ] {meeting}: {action item — file ticket / post share-out / chase answer}

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

## Standup Snippet
- 👈🏽 Yesterday:
   - {achievement} {bare URL}
- 👉🏽 Today:
   - {priority} {bare URL}
- ✋🏽 Blockers:
   - {blocker} {bare URL}

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

0. **Generator metadata** — `<head>` must include `<meta name="generated-with-version" content="{SKILL_VERSION}">`, `<meta name="generated-with-skill" content="wk-goodmorning">`, and `<meta name="generated-at" content="{ISO_8601_UTC}">`. The Stage 0 idempotency check reads these on the next run.
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

### 2d. Standup snippet (mandatory — both outputs)

Append a copy-paste-ready Slack standup at the end of `morning.md`
**and** as a dedicated card in `morning.html`. The user posts this
verbatim to a team standup channel every working day, so the format is
constrained by Slack's paste behavior — not by markdown aesthetics.

**Format (markdown and HTML both):**

```
- 👈🏽 Yesterday:
   - {achievement} {bare URL} [{bare URL} ...]
   - ... (3-4 highest-impact items)
- 👉🏽 Today:
   - {priority} {bare URL}
   - ... (3-4 time-sensitive items, deadlines first)
- ✋🏽 Blockers:
   - {blocker} {bare URL}
   - ... (omit the section entirely if no blockers)
```

**HARD RULE:** Bare URLs only. Slack does not render markdown
`[text](url)` syntax when pasted from the clipboard; it renders the
literal brackets and parentheses. Always emit URLs as bare strings
(Slack auto-linkifies them on paste). This applies to both the
markdown file (so the user can copy from the source) and the HTML
copy-to-clipboard payload.

**HARD RULE:** Emoji lead characters (`👈🏽`, `👉🏽`, `✋🏽`) are mandatory
on the Yesterday, Today, and Blockers bullets respectively. After
writing the file, verify they are present:

```bash
grep -c "👈🏽" "$TODAY_DIR/morning.md"  # must be >= 1
grep -c "👉🏽" "$TODAY_DIR/morning.md"  # must be >= 1
```

If either `grep` returns 0, the emoji were stripped (a known failure
mode when writing files via bash heredoc — multi-byte sequences can be
silently dropped by locale or shell encoding mismatches). Re-write the
standup section using the Write tool or a `printf` approach that
preserves UTF-8, then re-verify. Do not commit until all three emoji
leads are confirmed present in both `morning.md` and the clipboard
payload embedded in `morning.html`.

**Source mapping:**
- **Yesterday** → previous working day's `evening.md` `## Achievements`
  section. Pick 3-4 items with the highest visible impact (shipped/merged
  PRs, decisions led, blockers cleared, key meetings).
  - **HARD RULE: Authorship filter.** A PR qualifies as a Yesterday
    achievement only if the user is (a) the author, (b) a listed
    co-author, or (c) the primary/approving reviewer who drove the
    work to completion. Merging another person's PR — even as a
    maintainer — is a maintenance action, not an achievement. Drop
    any PR that fails this test before picking the top 3-4.
- **Today** → today's `## Today's Priorities` list. Pick the top 3-4
  🔥/⚠️-flagged or time-sensitive items, deadline-first.
- **Blockers** → any item flagged ⚠️, containing "BLOCKED", or noted as
  a conflict/dependency. If none, omit the bullet entirely (do not emit
  an empty Blockers heading).

**Source-link enforcement.** Every bullet in Yesterday/Today/Blockers
must include at least one bare URL pointing to its primary artifact
(PR, ticket, Slack thread, doc). Items with multiple artifacts list
each URL space-separated on the same line. Items with no external
artifact (e.g., a meeting debrief, a synthesized priority) may omit
the URL but should still appear if they belong in the standup.

**HTML rendering:**
- Render the snippet inside its own card titled "Standup Snippet"
  positioned at the top of the dashboard (above the priorities card)
  so the user can grab it first thing.
- Include a "Copy to clipboard" button that copies the **plain-text
  payload with bare URLs** — not the rendered HTML. Use
  `navigator.clipboard.writeText(plainText)` with the same indented
  bullet structure as the markdown version.
- Inside the card, display the plain text in a monospace block so
  what the user sees matches what they paste.

**Markdown rendering:** add a `## Standup Snippet` section as the last
section before `## Notes`. The user copies directly from the rendered
file; bare URLs ensure Slack-paste fidelity.

### Open for review

After writing both files, open the HTML dashboard automatically:

```bash
open "$TODAY_DIR/morning.html"
```

**HARD RULE: `open` is unconditional.** It runs immediately after the files are
written — before any commit/push offer, before any announcement, and without
exception in auto mode. Auto mode does not exempt this step. The file must be
open in the browser before the agent proceeds to the next step.

Then announce (do NOT ask whether the user wants to see it — it is already open):

> "Your morning brief is ready and opened in your browser:
> - `sitrep/{YYYY}/{MM}/{DD}/morning.md` — structured reference
> - `sitrep/{YYYY}/{MM}/{DD}/morning.html` — interactive dashboard (opened)
>
> You have X items needing action, Y follow-ups, and Z meetings today."

After the announcement, offer the commit/push step:

> "Commit and push these files? (auto mode: yes)"

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

## QPR Season Awareness

Check if today falls in a QPR preparation window (typically the last 2 weeks
of January, April, July, or October — ahead of $EMPLOYER's quarterly review cycles):

```bash
MONTH=$(date +%m)
DAY=$(date +%d)
# Flag if: (Jan and day >= 15) or (Apr and day >= 15) or (Jul and day >= 15) or (Oct and day >= 15)
```

If in a QPR window AND `$PWD/QPR/brag-log.md` exists with recent entries,
add a **QPR Prep** banner to the morning brief:

> "📋 **QPR Prep** — Quarter ends soon. Your brag log has {N} entries
> since {start date}. Run `/wk-self-perf quarter` to generate your
> performance narrative."

This fires once per day during the window, not on every run.

---

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| `/wk-goodmorning` | Full morning prep — 5 parallel agents |
| Service auth fails | Block and prompt user to fix, re-run failed agents |
| No evening.md | Skip carry-over section, note in output |
| Monday (new week) | Roll over previous week's memory, confirm rules |
| Item skipped 2+ days | Offer to add auto-skip rule to weekly memory |
| No weekly memory | Start fresh — no auto-rules applied |

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn goodmorning`).
