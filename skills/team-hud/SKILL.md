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
  version: "2026.10.09-184159"
  internal: false
  model:
    openai: gpt-5.6-terra
    claude: claude-sonnet-4-6
---

# Team HUD

> **⚠️ Work in progress — do not invoke.** Non-invocable until at least one roster source works end-to-end. Blockers:
>
> - **Slack roster fetch fails with `missing_scopes`** on both private and public channels: the MCP token needs `channels:read.members` and `groups:read.members` (re-auth required), or the contract must pivot to an explicit member CSV env var.
> - **Jira Team URL** (`api.atlassian.com/public/teams/v1/teams/<id>/members`) is not exposed by the Jira MCP; the Slack cache pattern would require a prompted CSV of accountIds.
> - **Google Group URL** has no MCP endpoint; would need `gcloud identity groups` installed locally or a manual member CSV.

Generate a heads-up display of what each team member is actively working on, sourced live from Slack, Jira, GitHub, and
email.

- Invoked by `wk-sitrep` (parallel sub-task) for the daily brief's team activity section, or directly via `/wk-team-hud`
  for an on-demand snapshot.
- **NOT** a contact directory or org-chart lookup: this is a *what's happening now* signal.
- Requires Slack, Jira, GitHub, and Gmail MCP connectors authenticated, and write access to
  `$WK_SKILLS_HOME/config/team-hud.yaml` (handle→channel cache).

## Step 0: Validate environment

Stop and report if any required env var is unset:

```bash
: "${WK_SKILLS_TEAM_SLACK_HANDLE:?WK_SKILLS_TEAM_SLACK_HANDLE must be set (comma-separated Slack usergroup handles, e.g., 'your-team,platform-team')}"
: "${WK_SKILLS_TEAM_JIRA:?WK_SKILLS_TEAM_JIRA must be set (comma-separated Jira project keys)}"
: "${WK_SKILLS_TEAM_GITHUB:?WK_SKILLS_TEAM_GITHUB must be set (GitHub org or org/repo filter)}"
```

`WK_SKILLS_TEAM_JIRA` example: `ENG,DATA`. `WK_SKILLS_TEAM_GITHUB` example: `acme` or `acme/backend`.

## Step 1: Resolve each team handle to a Slack channel (cached)

The Slack MCP does not expose `usergroups.users.list`: resolve each handle to the team's primary channel once, cache it,
and read channel members every run.

**Load or build the cache** at `$WK_SKILLS_HOME/config/team-hud.yaml`:

```yaml
handles:
  your-team:
    channel_id: C0XXXXXXXXX
    channel_name: your-team-internal
    resolved_at: 2026-05-28
```

- `mkdir -p "$WK_SKILLS_HOME/config"`; create the file if missing.
- Split `$WK_SKILLS_TEAM_SLACK_HANDLE` on commas; trim whitespace.
- Handle has `handles.<handle>.channel_id` in the cache → use it and skip resolution.

**Resolve missing handles** (one-time per handle):

- Strip a trailing `-team` suffix to form a search stem; call `slack_search_channels` with that stem on both
  `public_channel` and `private_channel` types.
- Present up to 5 candidates via `AskUserQuestion` with channel name, ID, type, and creator, plus an `Other` option.
- Persist the choice under `handles.<handle>` with `channel_id`, `channel_name`, and `resolved_at: <today>`.
- Never auto-pick a candidate: a wrong cache entry silently poisons every future run until edited by hand.

**List members** for each resolved `channel_id`:

- Call `slack_list_channel_members` with `response_format: detailed`; paginate via the returned `cursor` until
  exhausted.
- Exclude bots, deactivated users, and the calling user (their activity surfaces in the calling brief's other sections).
- Union member lists across all handles; deduplicate by user ID.
- Capture each member's `display_name`, `email`, and any GitHub handle in the profile (used in Step 3).

## Step 2: Determine time window

Default: last 24 hours for morning invocation, last 8 hours for evening. `--since <duration>` (relative, e.g. `48h`,
`3d`) overrides; calling skills (`wk-sitrep`) may pass it.

## Step 3: Fetch live signals (parallel, one dispatch per member)

For each team member, run these source queries in parallel:

- **Slack** — for every resolved `channel_id`, search for the member's messages in the window; read threads they started
  or replied to.
- **Jira** — always scope to `project in ($WK_SKILLS_TEAM_JIRA)` (unscoped queries return org-wide noise); find issues
  assigned to the member that are `In Progress` or transitioned within the window:

  ```jql
  project in (<WK_SKILLS_TEAM_JIRA>) AND assignee = "<member>" AND
  (status = "In Progress" OR statusCategory changed AFTER "-<window>")
  ORDER BY updated DESC
  ```

- **GitHub** — within `$WK_SKILLS_TEAM_GITHUB`, surface open PRs authored by the member, PRs they reviewed or commented
  on, and recent commits. Use the GitHub handle from their Slack profile; otherwise fall back to email matching.
- **Email** — search sent messages or threads where the member is a sender and at least one other team member is a
  recipient (team-scoped threads only).

**HARD RULE:** Pull all signals from live sources — never promote a
carry-over item from a prior run without re-verifying it is still
accurate.

Every item must trace back to a live signal fetched this run: cross-check PR status and Jira transitions; drop items
that closed before the run window.

## Step 4: Distill per-member summary

Write 2–4 bullets per member covering: what they are actively working on (PR / ticket title + status); anything they
announced or shared out (docs, demos, deployments, shareouts); blockers or asks visible in threads or PR review
comments. Drop items older than the time window even if they look interesting.

## Step 5: Compose and return the HUD block

```markdown
## Team Activity — <YYYY-MM-DD>

### <Display Name>
- <bullet>
- <bullet>

### <Display Name>
...
```

Invoked by another skill → return the block as output; invoked standalone → also write to
`$HOME/.claude/team-hud/<YYYY-MM-DD>.md`.

## Post-Completion

Invoke `wk-learn team-hud`.
