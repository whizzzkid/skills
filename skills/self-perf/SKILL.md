---
name: wk-self-perf
description: >-
  Generate a self-performance review narrative by pulling data from all work
  systems (GitHub, Slack, Gmail, Calendar, Jira/Confluence, Granola, Docs, DX).
  Supports any time window: day, week, month, quarter, half-year, or annual.
  Writes a QPR reference corpus + synthesized narrative draft to QPR/<period>/.
  Run as: /wk-self-perf quarter  or  /wk-self-perf week  or  /wk-self-perf Q1
argument-hint: '[day | week | month | quarter | Q1-Q4 | H1-H2 | annual | YYYY-MM-DD:YYYY-MM-DD]'
allowed-tools:
  - Skill
  - Agent
  - AskUserQuestion
  - Bash
  - Write
  - Edit
  - Read
model: sonnet
effort: high
model-invocable: false
user-invocable: true
license: MIT
group: rituals
metadata:
  author: whizzzkid
  version: '2026.06.15-200559'
  model:
    openai: o3
    google: gemini-2.5-pro
    meta: llama-4-maverick
    kimi: k2
    qwen: qwen3-235b
    cursor: composer-2
---

# Self-Performance Review

Pull data from all connected work systems in parallel → distill accomplishments,
impact signals, leadership evidence → narrative ready for QPR submission.

```
Parse period ──► Parallel data fetch (7 agents) ──► Synthesize ──► Draft narrative
     │                                                    │
     └── day|week|month|quarter|half|annual               └── QPR/<period>/references/*.md
                                                              QPR/<period>/synthesis.md
```

---

## Stage 0: Parse Period and Set Date Range

### Parse the period argument

Map the period argument to a start/end date range:

| Argument | Start | End |
|----------|-------|-----|
| `day` | Today 00:00 | Today 23:59 |
| `week` | Monday of current week | Today |
| `month` | 1st of current month | Today |
| `quarter` or `Q1`/`Q2`/`Q3`/`Q4` | First day of FY quarter | Last day of FY quarter |
| `half` or `H1`/`H2` | First day of half-year | Last day of half-year |
| `annual` | Feb 1 of current FY | Jan 31 of next FY |
| `YYYY-MM-DD:YYYY-MM-DD` | Custom start | Custom end |

**$EMPLOYER FY quarters** (Feb–Jan fiscal year, adjust per `$EMPLOYER_FY_START` if set):
- Q1: Feb 1 – Apr 30
- Q2: May 1 – Jul 31
- Q3: Aug 1 – Oct 31
- Q4: Nov 1 – Jan 31

**Buffer:** Add 2 days before and after the period for context.

```bash
# Example for Q1 FY2026
START_DATE="2026-01-30"
END_DATE="2026-05-02"
DISPLAY_PERIOD="Q1 FY2026"
PERIOD_SLUG="Q1"  # for folder naming
```

### Determine output paths

```bash
QPR_DIR="$PWD/QPR/${PERIOD_SLUG}"
REFS_DIR="$QPR_DIR/references"
SYNTHESIS_FILE="$QPR_DIR/synthesis.md"
mkdir -p "$REFS_DIR"
```

### Check for existing corpus

If `$SYNTHESIS_FILE` exists, prompt:

> "A QPR corpus already exists for `${PERIOD_SLUG}` (synthesis.md found).
>
> **(a)** Open existing synthesis — no regeneration
> **(b)** Re-gather from scratch — overwrites all reference files and synthesis
> **(c)** Supplement — run only missing or stale reference files, then re-synthesize
>
> Reply with your choice."

Auto mode → default **(c)** (supplement is safe and additive).

---

## Stage 1: Parallel Data Gathering

- Launch **7 agents in parallel**.
- Each writes its output to a file in `$REFS_DIR/`.
- Include the period context in every prompt.

### Subagent contract (mandatory)

> See [`wk-sitrep`](../sitrep/SKILL.md#stage-2-parallel-data-gathering)
> for the base contract. Prepend verbatim to every agent prompt, then append these
> self-perf-specific additions:

```
SUBAGENT CONTRACT ADDITIONS (self-perf):
- Write your findings ONLY to the specified output file (path provided in prompt)
- Be comprehensive — this is for a performance review where the user's job depends on it
- Use strong-verb impact language: "shipped", "led", "designed", "resolved"
- Include specific evidence: PR numbers, dates, ticket keys, attendee counts, metrics
```

The base contract's source-identifier and verified/claim tagging rules apply here too.

---

### Agent 1: GitHub Activity

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

### Agent 2: Calendar and Meetings

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

### Agent 3: Slack Contributions

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

### Agent 4: Gmail Contributions

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

### Agent 5: Jira and Confluence

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

### Agent 6: Granola + Google Docs + Drive

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

### Agent 7: DX Metrics + Sitrep Files

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

---

## Stage 2: Synthesize into Narrative

After all 7 agents complete → read every reference file → synthesize into `$SYNTHESIS_FILE`.

### Synthesis structure

```markdown
# Self-Performance Review — {DISPLAY_PERIOD}
**Period:** {START_DATE_DISPLAY} – {END_DATE_DISPLAY}
**Role:** {ROLE} — confirm or update before submitting
**Compiled:** {TODAY}

## Executive Summary
{3-4 sentences: what you shipped, the impact, and one standout signal}

## Major Accomplishments

### 1. {Largest shipped feature/system}
**What:** {one-line description}
**Key milestones:** {bulleted timeline with specific evidence}
**Impact:** {outcomes, metrics, reach}
**Evidence:** {PR numbers, Jira keys, meeting dates}

### 2. {Next accomplishment}
...

## Team & People Impact
- Direct reports managed: {names, cadence}
- Interviews conducted: {count, levels, orgs, outcomes}
- Training facilitated: {sessions, hours, engineers reached}
- Peers unblocked: {notable examples}

## Technical Leadership
- Architecture decisions made: {ADRs authored, design docs, key choices}
- Security work: {hardening, threat models, reviews}
- Platform contributions: {cross-team tools, shared libraries}

## Cross-Team Impact
- Teams collaborated with: {list with nature of collaboration}
- Cross-team PRs: {repos contributed to outside your own}
- External visibility: {talks, events, blog posts}

## DX / Engineering Health
- PR velocity: {avg/period}
- Review quality: {notes}
- Documentation: {every feature shipped with docs?}
- Test coverage: {patterns}

## Quarter Narrative (Suggested Self-Review Language)
> {2-3 paragraph first-person narrative ready to paste into Lattice/QPR tool}
```

> ⚠️ **Role placeholder:** The synthesis template uses `{ROLE}`. Before writing
> the file, resolve the user's current role from Workday, Lattice, or their
> GitHub profile bio. If unresolvable, leave the placeholder and flag it.

### Impact language guide

When synthesizing, prefer strong over weak verbs:

| Weak | Strong |
|------|--------|
| "worked on" | "designed and shipped" |
| "helped with" | "led", "unblocked", "enabled" |
| "made changes to" | "hardened", "refactored", "extracted" |
| "participated in" | "co-facilitated", "presented at", "drove" |
| "was involved in" | "owned end-to-end", "drove to completion" |

### Calibrating to level expectations

Structure the narrative to demonstrate the user's level expectations.
For the user's current level at $EMPLOYER, surface these signals:

| L4 Signal | Evidence to surface |
|-----------|---------------------|
| Ships impactful projects end-to-end | Feature milestones with dates and metrics |
| Drives cross-team collaboration | Orgs collaborated with, PRs in other repos |
| Mentors and grows team members | 1:1s, hiring contributions, unblocking patterns |
| Writes and owns technical design | ADRs, design docs, architecture decisions |
| Improves team processes | Automation built, CI improvements, workflow changes |
| External visibility | Talks, blog posts, industry engagement |

---

## Stage 3: Write Output Files

### 3a. Commit reference files

After all agents write their output files:

```bash
git add QPR/
git commit -m "feat(QPR): add ${PERIOD_SLUG} performance reference corpus"
```

### 3b. Write synthesis

Write the synthesized narrative to `$SYNTHESIS_FILE`, then commit:

```bash
git add "$SYNTHESIS_FILE"
git commit -m "feat(QPR): add ${PERIOD_SLUG} self-performance synthesis"
git push
```

### 3c. Open synthesis

```bash
open "$SYNTHESIS_FILE"
```

Announce:

> "Your `${PERIOD_SLUG}` self-performance corpus is ready:
> - `QPR/${PERIOD_SLUG}/references/` — {N} source files with raw evidence
> - `QPR/${PERIOD_SLUG}/synthesis.md` — narrative draft ready for QPR submission
>
> Top accomplishments surfaced:
> 1. {accomplishment 1}
> 2. {accomplishment 2}
> 3. {accomplishment 3}
>
> The 'Quarter Narrative' section has suggested self-review language you can
> paste directly."

---

## Stage 4: Distill Learnings into Daily Sitreps

After synthesis, evaluate whether meaningful patterns from this period belong in the daily sitrep:

| Pattern | Add to |
|---------|--------|
| A recurring impact signal worth tracking daily | sitrep end brag/snapshot section |
| A type of work worth preparing for in the morning | wk-sitrep start context section |
| A metric that should be monitored | DX section of sitrep end |

**QPR brag log:** Append notable accomplishments to the QPR running log:

```bash
QPR_LOG="$PWD/QPR/brag-log.md"
# Append this period's highlights with date range
```

This log accumulates across quarters so the next QPR has a richer corpus.

---

## Quick Reference

| Command | Behavior |
|---------|----------|
| `/wk-self-perf quarter` | Current FY quarter |
| `/wk-self-perf Q1` | Q1 FY2026 (Feb–Apr) |
| `/wk-self-perf week` | Current week |
| `/wk-self-perf month` | Current month |
| `/wk-self-perf annual` | Full FY |
| `/wk-self-perf 2026-02-01:2026-04-30` | Custom range |

---

## Post-Completion

Invoke `wk-learn` with this skill's short name: `wk-learn self-perf`.
