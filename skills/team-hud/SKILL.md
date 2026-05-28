---
name: wk-team-hud
description: >-
  Generate a heads-up display of what each team member is working on — surfacing
  PRs, Jira tickets, Slack activity, announcements, shareouts, and emails. Invoked
  in parallel by wk-goodmorning and wk-goodevening to produce the team activity
  section of daily summaries. Can also be called directly for an on-demand snapshot.
argument-hint: '[--since <duration>]'
allowed-tools:
  - Bash
  - Read
  - Write
  - "mcp__claude_ai_Slack_*__slack_list_channel_members"
  - "mcp__claude_ai_Slack_*__slack_read_channel"
  - "mcp__claude_ai_Slack_*__slack_read_thread"
  - "mcp__claude_ai_Slack_*__slack_search_public_and_private"
  - "mcp__claude_ai_Slack_*__slack_read_user_profile"
  - "mcp__claude_ai_Jira_*__getJiraIssue"
  - "mcp__claude_ai_Jira_*__searchJiraIssuesUsingJql"
  - "mcp__claude_ai_Github-*__*"
  - "mcp__claude_ai_Gmail_*__search"
  - "mcp__claude_ai_Gmail_*__fetch_message"
  - "mcp__claude_ai_Glean__search"
  - "mcp__claude_ai_Glean__user_activity"
model: sonnet
effort: medium
model-invocable: true
user-invocable: true
license: MIT
group: rituals
metadata:
  author: whizzzkid
  version: '2026.05.28-210000'
  internal: false
  model:
    claude: claude-sonnet-4-6
---

# Team HUD

Generate a heads-up display for what each team member is actively working on,
sourced live from Slack, Jira, GitHub, and email.

## When to Use

- Invoked by `wk-goodmorning` and `wk-goodevening` (parallel sub-task) to
  populate the team activity section of the daily brief.
- Called directly via `/wk-team-hud` for an on-demand snapshot.
- **NOT** a contact directory or org-chart lookup — this is a *what's happening now* signal.

## Step 0: Validate environment

Stop and report if any required env var is unset:

```bash
: "${WK_SKILLS_TEAM_SLACK:?WK_SKILLS_TEAM_SLACK must be set (Slack channel ID for the team)}"
: "${WK_SKILLS_TEAM_JIRA:?WK_SKILLS_TEAM_JIRA must be set (comma-separated Jira project keys)}"
: "${WK_SKILLS_TEAM_GITHUB:?WK_SKILLS_TEAM_GITHUB must be set (GitHub org or org/repo filter)}"
```

## Step 1: Resolve the team roster

- Fetch channel members from `$WK_SKILLS_TEAM_SLACK` via `slack_list_channel_members`.
- Exclude bots and the calling user (this is a *team* brief, not a self-brief).
- For each member, fetch their Slack profile to resolve display name, email, and GitHub handle.
- Cache the resolved roster in the skill's working context; do not re-fetch mid-run.

## Step 2: Determine time window

- Default: last 24 hours for morning invocation; last 8 hours for evening invocation.
- Calling skills (`wk-goodmorning`, `wk-goodevening`) may pass `--since <duration>` to override.
- Parse `--since` as a relative duration string (e.g., `48h`, `3d`).

## Step 3: Fetch live signals (parallel, one dispatch per member)

For each team member, run these source queries in parallel:

- **Slack** — search `$WK_SKILLS_TEAM_SLACK` for messages posted by the member
  in the time window; read any threads they started or replied to.
- **Jira** — query `$WK_SKILLS_TEAM_JIRA` project keys for issues assigned to
  the member with status `In Progress` or transitioned within the window:

  ```jql
  project in (<WK_SKILLS_TEAM_JIRA>) AND assignee = "<member>" AND
  (status = "In Progress" OR statusCategory changed AFTER "-<window>")
  ORDER BY updated DESC
  ```

- **GitHub** — within `$WK_SKILLS_TEAM_GITHUB`, surface: open PRs authored by
  the member, PRs they reviewed or commented on, and recent commits.
- **Email** — search for sent messages or threads where the member is a sender
  and at least one other team member is a recipient (team-scoped threads only).

**HARD RULE:** Pull all signals from live sources — never promote a carry-over
item from a prior run without re-verifying it is still accurate.

## Step 4: Distill per-member summary

For each member, produce a 2–4 bullet summary covering:

- What they are actively working on (PR / ticket title + status).
- Anything they announced or shared out (docs, demos, deployments, shareouts).
- Blockers or asks visible in threads or PR review comments.

Drop items older than the time window even if they look interesting.

## Step 5: Compose and return the HUD block

Produce a Markdown block for embedding in a calling brief:

```markdown
## Team Activity — <YYYY-MM-DD>

### <Display Name>
- <bullet>
- <bullet>

### <Display Name>
...
```

- Return the block as output when invoked by another skill.
- When invoked standalone, also write to `~/.claude/team-hud/<YYYY-MM-DD>.md`.

## Common Mistakes

- **Stale carry-overs:** Every item must trace back to a live signal fetched
  this run. Cross-check PR status and Jira transitions; drop items that closed
  before the run window.
- **Unscoped Jira queries:** Always filter by `project in ($WK_SKILLS_TEAM_JIRA)`.
  Omitting the project filter returns org-wide noise.
- **Including the calling user's own activity:** Step 1 excludes the caller —
  their activity surfaces in the calling brief's other sections.

## Quick Reference

| Invocation | Behavior |
|------------|----------|
| `/wk-team-hud` | On-demand snapshot, writes to `~/.claude/team-hud/` |
| `wk-goodmorning` / `wk-goodevening` → parallel | Returns HUD block, no disk write |
| `/wk-team-hud --since 48h` | Extends the look-back window |

## Requirements

- `WK_SKILLS_TEAM_SLACK` — Slack channel ID for the team channel.
- `WK_SKILLS_TEAM_JIRA` — Comma-separated Jira project keys (e.g., `ENG,DATA`).
- `WK_SKILLS_TEAM_GITHUB` — GitHub org or `org/repo` filter (e.g., `acme` or `acme/backend`).
- Slack, Jira, GitHub, and Gmail MCP connectors authenticated.

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn team-hud`).
