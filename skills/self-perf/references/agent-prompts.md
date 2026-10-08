# Self-Perf Agent Prompts

Detailed prompts for the 7 parallel data-gathering agents. Each writes to `$REFS_DIR/`.

## Agent 1: GitHub Activity

**Output file:** `$REFS_DIR/github.md`

Fetch via `gh` CLI or GitHub MCP:

```bash
# PRs authored
gh search prs --author=@me --created="${START_DATE}..${END_DATE}" \
  --limit 100 --json number,title,repository,state,mergedAt,additions,deletions

# PRs reviewed
gh search prs --reviewed-by=@me --updated="${START_DATE}..${END_DATE}" \
  --limit 100 --json number,title,repository,state,author

# Issues/discussions
gh search issues --assignee=@me --updated="${START_DATE}..${END_DATE}" \
  --json number,title,repository,state,labels
```

Structure output as:
- Summary stats (PRs authored/merged, PRs reviewed, repos touched)
- PRs grouped by repo with dates and impact
- Key accomplishments: major features, security hardening, architecture changes
- Velocity and quality patterns

---

## Agent 2: Calendar and Meetings

**Output file:** `$REFS_DIR/calendar.md`

Use a Google Calendar MCP tool (search `gcal` via `ToolSearch`).

Fetch all events `START_DATE` → `END_DATE`. Categorize:
- Interviews conducted (as interviewer or debrief panelist)
- Training/workshops facilitated (as organizer/presenter)
- 1:1s with direct reports and manager
- Cross-functional meetings (outside immediate team)
- Team cadence meetings owned (standups, planning, retros)
- All-hands, company meetings
- External/industry events

Per category: count, estimated hours, notable examples.

Structure output as:
- Summary stats table
- Time investment by category
- Candidate interviews (with levels and orgs)
- Training sessions facilitated (with audience size)
- Regular commitments showing leadership
- Cross-team collaboration evidence

---

## Agent 3: Slack Contributions

**Output file:** `$REFS_DIR/slack.md`

Use a Slack MCP tool (search `slack` via `ToolSearch`).

Search the user's messages during the period. Look for:
- Decisions influenced or communicated
- Technical explanations and unblocking of others
- Announcements of shipped features
- Cross-team collaboration (posting in other teams' channels)
- Design proposals, architecture discussions
- Recognition given or received

Structure output as:
- Communication patterns and channel activity
- Key decisions and discussions influenced
- Technical leadership moments
- Cross-team reach
- Notable announcements

---

## Agent 4: Gmail Contributions

**Output file:** `$REFS_DIR/gmail.md`

Use a Gmail MCP tool (search `gmail` via `ToolSearch`).

Resolve the user's email dynamically:

```bash
USER_EMAIL=$(git config user.email)
```

Search: `from:${USER_EMAIL} after:${START_DATE} before:${END_DATE}`

Look for:
- Proposals, designs, plans sent to stakeholders
- Feedback received (Lattice, peer, manager)
- Cross-functional communications
- Escalations handled
- Project announcements

Structure output as:
- Notable sent communications
- Feedback received (unsolicited is especially valuable)
- Cross-functional email signals
- Leadership / initiative evidence

---

## Agent 5: Jira and Confluence

**Output file:** `$REFS_DIR/jira-confluence.md`

Use Jira/Confluence MCP (`mcp__claude_ai_Jira_Confluence__*`).

Resolve the user's email dynamically:

```bash
USER_EMAIL=$(git config user.email)
```

**Jira:**
```
reporter = "${USER_EMAIL}" AND created >= "${START_DATE}"
assignee = "${USER_EMAIL}" AND updated >= "${START_DATE}"
```

**Confluence:** Search pages created or edited by the user.

Structure output as:
- Issues created (by project/epic)
- Issues resolved
- Epics owned or contributed to
- Confluence pages authored
- Technical specs, ADRs, runbooks written

---

## Agent 6: Granola + Google Docs + Drive

**Output file:** `$REFS_DIR/docs-meetings.md`

Use Granola MCP (`mcp__granola__*`), a Google Docs MCP tool (search `gdocs` via `ToolSearch`),
and Glean (`mcp__claude_ai_Glean__*`).

**Granola:** Get all meetings in the period. Extract:
- Decisions made by the user
- Action items owned
- Technical proposals put forward
- Cross-team influence moments

**Docs/Drive:** Find documents created or edited:
- Technical specs and design docs
- Engineering blog posts
- Architecture decision records
- Training materials / workshop content
- Proposals sent to stakeholders

Structure output as:
- Meeting summary with decisions and action items owned
- Documents authored with purpose and estimated impact
- Technical writing and thought leadership

---

## Agent 7: DX Metrics + Sitrep Files

**Output file:** `$REFS_DIR/dx-sitrep.md`

**Part 1: DX Metrics** (if available — search `dx` via `ToolSearch`):
- PR cycle time, code review turnaround
- Deploy frequency, lead time
- Team/org/company comparisons
- Trends over the period

**Part 2: Sitrep files** (always available) — read all sitrep files in the period from `$PWD/sitrep/`:

```bash
find "$PWD/sitrep" -name "*.md" -newer /tmp/start_marker | sort
```

Extract from morning/evening briefs:
- Projects shipped and milestones hit
- Technical decisions made
- Process improvements built
- Incidents resolved
- Team impact: unblocking, mentoring, reviews

Structure output as:
- Chronological timeline of accomplishments
- Technical wins with specifics
- Process improvements and automation
- Team impact moments
- DX metric snapshot (if available)
