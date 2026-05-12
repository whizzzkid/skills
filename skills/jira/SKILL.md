---
name: wk-jira
description: >-
  Coordinate Jira ticket state with the development lifecycle. Auto-invoked
  when the agent starts work on a branch, creates a PR, marks a PR ready,
  or detects a PR merge. Detects the associated Jira key from the branch
  name, commit messages, or recent prompts; assigns the ticket to the user;
  transitions the ticket through In Progress → In Review → Done in lockstep
  with PR state; and ensures every PR title carries a `[BOARD-NUM]` suffix
  and the PR description references the ticket. Also gates user-initiated
  write operations (create, edit, batch transition) behind explicit
  confirmation — Jira writes are effectively irreversible (no delete API).
  Requires the Jira MCP connector. Not user-invocable — fires automatically
  alongside `wk-commit`, `wk-pr`, and `wk-workflow`.
allowed-tools:
  - Bash
  - Read
  - Grep
  - ToolSearch
  - AskUserQuestion
  - "Bash(gh pr view:*)"
  - "Bash(gh pr edit:*)"
  - "Bash(gh pr list:*)"
  - "Bash(gh pr ready:*)"
  - "Bash(git branch:*)"
  - "Bash(git log:*)"
  - "Bash(git config:*)"
model: sonnet
effort: low
model-invocable: true
user-invocable: false
license: MIT
group: tools
metadata:
  author: whizzzkid
  version: '2026.05.08-000002'
  internal: false
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# Jira

Keep Jira ticket state in lockstep with PR lifecycle. The skill is the
glue between code work and project tracking — the user never has to
remember to flip the ticket; the agent does it on their behalf as
state transitions happen.

```
Start work ──► In Progress + assign-to-me
PR opened  ──► title = "<conventional>: <subject> [BOARD-NUM]"
                description references ticket
PR ready   ──► In Review
PR merged  ──► Done
```

---

## Trigger conditions

The skill fires automatically at four lifecycle points. Only the
matching subset of stages runs each time — do not re-do work already
done.

| Trigger | Stages to run |
|---------|---------------|
| Agent begins work on a branch (first edit, first commit on a fresh branch) | 0 (MCP), 1 (detect), 2 (start) |
| About to create a PR (called from `wk-pr`) | 0, 1, 3 (title + description) |
| PR transitioning from draft → ready | 0, 1, 4 (In Review) |
| PR merged (detected during `wk-pr` post-merge or via `gh pr view --json state`) | 0, 1, 5 (Done) |

If the agent cannot determine which trigger fired, default to detect
(Stage 1) and report what was found — never guess and transition.

---

## Stage 0: MCP availability check

```
ToolSearch select:mcp__claude_ai_Jira_Confluence__getJiraIssue,mcp__claude_ai_Jira_Confluence__transitionJiraIssue,mcp__claude_ai_Jira_Confluence__editJiraIssue,mcp__claude_ai_Jira_Confluence__searchJiraIssuesUsingJql,mcp__claude_ai_Jira_Confluence__getTransitionsForJiraIssue,mcp__claude_ai_Jira_Confluence__lookupJiraAccountId
```

If the connector is unavailable (tool search returns no matches),
**skip silently** — log a one-line note ("Jira MCP not connected;
ticket sync skipped") and let the development workflow proceed.
Direct the user to https://claude.ai/customize/connectors only when
they explicitly ask why a ticket didn't move.

If available, cache the resolved tool names for the session.

**HARD RULE:** never read or write Jira via a browser, WebFetch, or a
web-search agent. All Jira reads and writes must go through the
MCP connector. The browser path is slower, escapes the agent's
context, can spawn an extra agent, and produces unstructured output
that the agent then has to re-parse. If the MCP is unavailable, do
not fall back to the browser — surface the connector gap per the
silent-skip rule above and let the user decide.

---

## Stage 1: Detect the ticket key

A Jira key matches `[A-Z][A-Z0-9]+-\d+` — letters/digits, a hyphen,
then digits. Search in priority order; stop at the first hit:

1. **Current branch name** — `git rev-parse --abbrev-ref HEAD`. Many
   teams encode the key (`feat/<KEY>-<slug>`, `<key>-<slug>`).
2. **Most recent commit message** — `git log -1 --pretty=%B`. Look
   in subject and body.
3. **PR title and body** — when fired during PR creation/update,
   `gh pr view --json title,body`.
4. **Recent user prompts in this session** — the user often pasted
   the ticket URL or key when assigning the work.

Normalize matches to UPPERCASE. If multiple distinct keys appear,
prefer the one in the branch name; if still ambiguous, **ask** before
transitioning anything:

> "Found Jira keys {KEY-A, KEY-B}. Which one is the work for
> this branch?"

If **no** key is found, do not invent one. Skip transitions; in
Stage 3 ask the user once whether a Jira ticket exists; if they
say no, record it and stop offering for the rest of the branch.

---

## Stage 2: Start work — In Progress + assign

When the trigger is "start of branch," fetch the current state of the
detected ticket and decide what to change.

```
mcp__claude_ai_Jira_Confluence__getJiraIssue(issueIdOrKey="<KEY>")
mcp__claude_ai_Jira_Confluence__lookupJiraAccountId(searchString="<git user.email>")
```

Compare current `status` and `assignee` against the desired state:

- If `assignee` is unset OR is not the user, assign to the user.
- If `status` is not already `In Progress` (or a forward-equivalent
  like `In Review`/`Done` — never regress), transition to
  `In Progress`.

Get available transitions before posting:

```
mcp__claude_ai_Jira_Confluence__getTransitionsForJiraIssue(issueIdOrKey="<KEY>")
```

Match the transition by name (case-insensitive contains
`in progress`). If no matching transition exists from the current
state, leave status alone and report the gap once.

Apply changes via:

```
mcp__claude_ai_Jira_Confluence__editJiraIssue   # for assignee
mcp__claude_ai_Jira_Confluence__transitionJiraIssue  # for status
```

Report in one line:

> "Jira: {KEY} → In Progress, assigned @<user>."

---

## Stage 3: PR title and description sync

When `wk-pr` is creating or updating a PR for a branch with a
detected key, enforce two things:

### Title suffix

Every PR title carries the key in **square brackets** at the end of
the subject:

```
feat(auth): ✨ OAuth login [<KEY>]
fix(ci): 💚 pin dependency [<KEY>]
```

Rules:

- One key per title. If the work spans multiple tickets, choose the
  primary one and reference others in the body.
- Square brackets, no parens, no colon prefix. Format `[<KEY>]`.
- Bracket suffix sits **after** the conventional-commit subject and
  any classifier emoji — last token in the title.
- If the title already has a key suffix, do not duplicate it. If the
  existing key is wrong, ask before replacing.

### Description reference

The PR body must include a section that links back to the ticket so
reviewers can navigate to context:

```markdown
## Ticket

[<KEY>](https://<your-domain>.atlassian.net/browse/<KEY>) — <ticket summary>
```

Place the `## Ticket` section near the top, just under the
auto-generated `## Summary`. Pull `<ticket summary>` from the Jira
issue (`fields.summary`) so the link carries human context. Use the
canonical Atlassian URL the MCP returns.

If `wk-pr` already builds a description, **insert** the `## Ticket`
section rather than overwriting the rest. If the section already
exists, refresh its content if the ticket summary has changed.

---

## Stage 4: PR ready → In Review

When `wk-pr` flips a PR from draft to ready (`gh pr ready`), or when
the agent observes a non-draft PR for the first time on the branch,
transition the ticket:

```
mcp__claude_ai_Jira_Confluence__getTransitionsForJiraIssue(issueIdOrKey="<KEY>")
mcp__claude_ai_Jira_Confluence__transitionJiraIssue(issueIdOrKey="<KEY>", transition={ id: "<resolved>" })
```

Match transition name on case-insensitive contains `in review` /
`code review` / `review` (in that priority — `in review` is the
strongest match). Some boards name it `Ready for Review`; that
matches too.

Do not regress: if the ticket is already `In Review` or further
forward, leave it alone. If the only forward transition is `Done`,
stop and ask — that means the board has no review state and Stage 4
should be a no-op for this team.

Report once per state change:

> "Jira: {KEY} → In Review."

---

## Stage 5: PR merged → Done

When the agent observes that the PR has merged (`gh pr view --json
state` returns `MERGED`), transition the ticket to `Done`:

- Match transition name on case-insensitive contains: `done` first,
  then `closed`, then `resolved`. Pick the first that exists.
- If the ticket is already `Done`/`Closed`/`Resolved`, no-op.
- If multiple "done-like" transitions exist (e.g., `Done` and
  `Won't Do`), always pick `Done`. **Never** auto-pick a
  cancellation/won't-do/duplicate transition — those require human
  judgment.

If the PR merged but the build/deploy is gated behind a separate
post-merge process (e.g., the team's "Done" requires production
deploy verification), respect that: if the board's workflow has a
separate `Deployed`/`Verified` stage between `In Review` and `Done`,
move only one step forward and report. Do not skip stages.

Report:

> "Jira: {KEY} → Done. PR #<N> merged."

---

## Manual ticket operations (confirm-first)

When the user explicitly asks the agent to create, edit, or batch-transition
Jira items outside the auto lifecycle, confirm before any write call. Jira
write operations via the Atlassian MCP connector (`createJiraIssue`,
`editJiraIssue`, and similar write methods) are effectively irreversible —
there is no delete API.

**HARD RULE:** Never call a Jira write method on user-initiated work without
explicit approval of the proposed change set. Auto mode does not exempt —
Jira items are visible to the whole team.

| Operation | Confirmation required | Command pattern |
|-----------|----------------------|-----------------|
| Create issue(s) | Yes — show numbered list of titles before writing | Present draft set, wait for "yes" / "go ahead" |
| Edit issue fields | Yes — if ambiguous source or batch | Show diff of proposed changes |
| Transition to terminal state | Yes — if not part of auto lifecycle | Confirm the target state explicitly |
| Assign to user (auto lifecycle) | No — auto-assign as part of Stage 2 | `editJiraIssue` with assignee |

---

## Conflict and missing-state handling

| Situation | Behavior |
|-----------|----------|
| Ticket already in target state | No-op, no report |
| Target state has no transition from current | Skip, report gap once: "Jira: {KEY} cannot transition from {current} to {target}; check board workflow." |
| Multiple matching transitions | Prefer the one whose name is a closer match; tie-break: alphabetic |
| Ticket assignee already set, but to someone else | Do **not** reassign; the work may genuinely be reassigned. Report once: "Jira: {KEY} is assigned to @<them>; not changing." |
| Branch name has a key but the ticket was deleted / inaccessible | Report gap, skip transitions for this branch |
| MCP returns auth error | Report once with the connector URL; do not block development |

Never block a commit, push, or PR action on a Jira sync failure —
ticket state is a side-effect of the work, not a precondition for it.

---

## Quick Reference

| Trigger | Stages |
|---------|--------|
| First commit on a branch | 0, 1, 2 |
| `wk-pr` creating/updating PR | 0, 1, 3 |
| `gh pr ready` succeeds | 0, 1, 4 |
| `gh pr view` shows MERGED | 0, 1, 5 |
| Ambiguous: multiple keys found | 1 only — ask |
| MCP unavailable | 0 only — silent skip |

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn jira`).
