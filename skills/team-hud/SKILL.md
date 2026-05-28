---
name: wk-team-hud
description: >-
  [WIP — do not invoke] Generate a heads-up display of what each team member
  is working on. Blocked: Slack MCP lacks `channels:read.members` /
  `groups:read.members` scopes so roster cannot be fetched; Jira Team URL has
  no MCP endpoint; Google Group has no MCP. Status pending re-auth or
  contract pivot to explicit member CSV.
argument-hint: '[--since <duration>]'
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - AskUserQuestion
  - "mcp__claude_ai_Slack_*__slack_list_channel_members"
  - "mcp__claude_ai_Slack_*__slack_search_channels"
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
model-invocable: false
user-invocable: false
status: wip
license: MIT
group: rituals
metadata:
  author: whizzzkid
  version: '2026.05.28-221500'
  internal: false
  model:
    claude: claude-sonnet-4-6
---

# Team HUD

> **⚠️ Work in progress — do not invoke.**
>
> Blockers discovered during initial run:
>
> - **Slack roster fetch fails with `missing_scopes`** on both private and
>   public channels. The MCP token needs `channels:read.members` and
>   `groups:read.members` (re-auth required), or the contract must pivot to
>   an explicit member CSV env var.
> - **Jira Team URL** (`api.atlassian.com/public/teams/v1/teams/<id>/members`)
>   is not exposed by the Jira MCP; same cache pattern as Slack would
>   require a prompted CSV of accountIds.
> - **Google Group URL** has no MCP endpoint at all; would need
>   `gcloud identity groups` installed locally or a manual member CSV.
>
> Skill is non-invocable until at least one roster source works end-to-end.

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
: "${WK_SKILLS_TEAM_SLACK_HANDLE:?WK_SKILLS_TEAM_SLACK_HANDLE must be set (comma-separated Slack usergroup handles, e.g., 'your-team,platform-team')}"
: "${WK_SKILLS_TEAM_JIRA:?WK_SKILLS_TEAM_JIRA must be set (comma-separated Jira project keys)}"
: "${WK_SKILLS_TEAM_GITHUB:?WK_SKILLS_TEAM_GITHUB must be set (GitHub org or org/repo filter)}"
```

## Step 1: Resolve each team handle to a Slack channel (cached)

**Why this is needed.** The Slack MCP server does not expose
`usergroups.users.list`, so a usergroup handle like `@your-team`
cannot be turned into a member list directly. The skill resolves each
handle to the team's primary chat channel once, caches the mapping, and
reads channel members on every run.

### Load or build the cache

Cache file lives at `$WK_SKILLS_HOME/config/team-hud.yaml`:

```yaml
handles:
  your-team:
    channel_id: C0XXXXXXXXX
    channel_name: your-team-internal
    resolved_at: 2026-05-28
```

Steps:

- `mkdir -p "$WK_SKILLS_HOME/config"`; create the file if missing.
- Split `$WK_SKILLS_TEAM_SLACK_HANDLE` on commas; trim whitespace.
- For each handle, look up `handles.<handle>.channel_id` in the cache.
- If present, skip resolution and use the cached `channel_id`.

### Resolve missing handles (one-time per handle)

For every handle absent from the cache:

- Strip a trailing `-team` suffix to form a search stem, then call
  `slack_search_channels` with that stem on both `public_channel` and
  `private_channel` types.
- Present up to 5 candidates to the user via `AskUserQuestion` with the
  channel name, ID, type, and creator. Include an `Other` option in
  case the right channel is missing.
- Persist the user's choice into `$WK_SKILLS_HOME/config/team-hud.yaml`
  under `handles.<handle>` with `channel_id`, `channel_name`, and
  `resolved_at: <today>`.
- Never auto-pick a candidate — incorrect channel selection silently
  poisons every future run until the cache is edited by hand.

### List members

For each resolved `channel_id`:

- Call `slack_list_channel_members` with `response_format: detailed`
  and paginate via the returned `cursor` until exhausted.
- Exclude bots, deactivated users, and the calling user (the brief
  is about the *team*, not the caller).
- Union the resulting member lists across all handles; deduplicate by
  user ID.
- For each member, capture `display_name`, `email`, and any GitHub
  handle present in the profile (used in Step 3 GitHub queries).

## Step 2: Determine time window

- Default: last 24 hours for morning invocation; last 8 hours for evening invocation.
- Calling skills (`wk-goodmorning`, `wk-goodevening`) may pass `--since <duration>` to override.
- Parse `--since` as a relative duration string (e.g., `48h`, `3d`).

## Step 3: Fetch live signals (parallel, one dispatch per member)

For each team member, run these source queries in parallel:

- **Slack** — for every resolved `channel_id` from Step 1, search the
  channel for messages posted by the member in the time window; read
  any threads they started or replied to.
- **Jira** — query `$WK_SKILLS_TEAM_JIRA` project keys for issues
  assigned to the member with status `In Progress` or transitioned
  within the window:

  ```jql
  project in (<WK_SKILLS_TEAM_JIRA>) AND assignee = "<member>" AND
  (status = "In Progress" OR statusCategory changed AFTER "-<window>")
  ORDER BY updated DESC
  ```

- **GitHub** — within `$WK_SKILLS_TEAM_GITHUB`, surface: open PRs
  authored by the member, PRs they reviewed or commented on, and
  recent commits. Use the member's GitHub handle from their Slack
  profile if present; otherwise fall back to email matching.
- **Email** — search for sent messages or threads where the member
  is a sender and at least one other team member is a recipient
  (team-scoped threads only).

**HARD RULE:** Pull all signals from live sources — never promote a
carry-over item from a prior run without re-verifying it is still
accurate.

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

- **Auto-picking the channel for a handle:** never silently choose;
  always confirm via `AskUserQuestion`. A wrong cache entry poisons
  every future run until edited.
- **Stale carry-overs:** every item must trace back to a live signal
  fetched this run. Cross-check PR status and Jira transitions; drop
  items that closed before the run window.
- **Unscoped Jira queries:** always filter by
  `project in ($WK_SKILLS_TEAM_JIRA)`. Omitting the project filter
  returns org-wide noise.
- **Including the calling user's own activity:** Step 1 excludes the
  caller — their activity surfaces in the calling brief's other sections.

## Quick Reference

| Invocation | Behavior |
|------------|----------|
| `/wk-team-hud` | On-demand snapshot, writes to `~/.claude/team-hud/` |
| `wk-goodmorning` / `wk-goodevening` → parallel | Returns HUD block, no disk write |
| `/wk-team-hud --since 48h` | Extends the look-back window |

## Requirements

- `WK_SKILLS_TEAM_SLACK_HANDLE` — comma-separated Slack usergroup
  handles for the team(s) to track (e.g., `your-team`).
- `WK_SKILLS_TEAM_JIRA` — comma-separated Jira project keys (e.g., `ENG,DATA`).
- `WK_SKILLS_TEAM_GITHUB` — GitHub org or `org/repo` filter (e.g., `acme` or `acme/backend`).
- Slack, Jira, GitHub, and Gmail MCP connectors authenticated.
- Write access to `$WK_SKILLS_HOME/config/team-hud.yaml` (handle→channel cache).

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn team-hud`).
