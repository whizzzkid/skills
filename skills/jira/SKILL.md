---
name: wk-jira
description: >-
  Coordinate Jira ticket state with the dev lifecycle and surface Jira
  context on any Jira artifact. Auto-invoked on: a Jira URL (matches
  `https?://[^/]+\.atlassian\.net/`, `/browse/<KEY>`, or a self-hosted
  host); a key token (`[A-Z][A-Z0-9]+-\d+`) in a prompt, branch, commit,
  PR body, or agent message; branch start; PR creation; PR draft→ready; PR
  merge. Detects the key; assigns the ticket to the user; moves it to the
  active sprint; transitions In Progress → In Review → Done in lockstep with
  PR state; posts a progress comment at each lifecycle change; audits thin
  descriptions and proposes a context block; ensures every PR title carries
  a `[BOARD-NUM]` suffix referencing the ticket. Gates user write
  operations (create, edit, batch transition) behind confirmation — Jira
  writes are irreversible (no delete API). Requires the Jira MCP connector.
  Not user-invocable — fires alongside `wk-commit`, `wk-pr`, `wk-workflow`.
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
  version: '2026.06.22-145005'
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

Keep Jira ticket state in lockstep with PR lifecycle. Agent flips the
ticket on the user's behalf as state transitions happen — user never
has to remember.

```
Start work ──► In Progress + assign-to-me + active sprint + comment
PR opened  ──► title = "<conventional>: <subject> [BOARD-NUM]"
                description references ticket + comment
PR ready   ──► In Review
PR merged  ──► Done + comment
```

---

## Trigger conditions

Fires automatically on artifact mentions **and** at lifecycle points.
Run only the matching subset of stages each time → never re-do work
already done.

| Trigger | Stages to run |
|---------|---------------|
| Jira URL appears in a user prompt, file, or agent context (`https?://[^/]+\.atlassian\.net/...` or `/browse/<KEY>`) | 0, 1, 6 (surface) |
| Jira key token (`[A-Z][A-Z0-9]+-\d+`) appears in a prompt, branch name, commit, PR body, or recent agent message | 0, 1, 6 (surface) |
| Agent does any development work on a detected ticket and Stage 2 has not completed this branch (first edit/commit on a fresh branch, **or** a mid-branch join) | 0 (MCP), 1 (detect), 2 (start) |
| About to create a PR (called from `wk-pr`) | 0, 1, 3 (title + description) |
| PR transitioning from draft → ready | 0, 1, 4 (In Review) |
| PR merged (detected during `wk-pr` post-merge or via `gh pr view --json state`) | 0, 1, 5 (Done) |

If trigger undeterminable → default to detect (Stage 1), report what was
found, never guess and transition.

**HARD RULE:** never assume "wasn't told to look up Jira." If a Jira URL
or key is in the agent's context → Stage 0 + 1 + 6 run before any other
response that depends on ticket context. Skip only when MCP unavailable
(silent-skip rule).

**HARD RULE — wk-jira claim precedes wk-workflow Phase 1.** A Jira key/URL
in the session-opening prompt is a development claim, not a side-effect of
the work. Run Stage 0 + 1 + 2 (surface + assign + In Progress + sprint +
comment) **before** `wk-workflow` Phase 1 planning begins — `wk-workflow`'s
"any development task" trigger must not fire first and skip the claim. The
ticket lands In Progress at session start, not retroactively after the PR
exists.

---

## Stage 0: MCP availability check

```
ToolSearch select:mcp__claude_ai_Jira_Confluence__getJiraIssue,mcp__claude_ai_Jira_Confluence__transitionJiraIssue,mcp__claude_ai_Jira_Confluence__editJiraIssue,mcp__claude_ai_Jira_Confluence__searchJiraIssuesUsingJql,mcp__claude_ai_Jira_Confluence__getTransitionsForJiraIssue,mcp__claude_ai_Jira_Confluence__lookupJiraAccountId,mcp__claude_ai_Jira_Confluence__addCommentToJiraIssue
```

- Connector unavailable (tool search returns no matches) → **skip
  silently**: log one-line note ("Jira MCP not connected; ticket sync
  skipped"), let development workflow proceed.
- Direct user to https://claude.ai/customize/connectors only when they
  explicitly ask why a ticket didn't move.
- Available → cache resolved tool names for the session.

**HARD RULE:** never read or write Jira via browser, WebFetch, or a
web-search agent. All Jira reads/writes go through the MCP connector.
Rationale: browser path is slower, escapes the agent's context, can spawn
an extra agent, produces unstructured output the agent must re-parse. MCP
unavailable → do not fall back to browser; surface the connector gap per
silent-skip rule, let the user decide.

---

## Stage 1: Detect the ticket key

Jira key matches `[A-Z][A-Z0-9]+-\d+` (letters/digits, hyphen, digits).
Search in priority order; stop at first hit:

1. **Current branch name** — `git rev-parse --abbrev-ref HEAD`. Teams
   often encode the key (`feat/<KEY>-<slug>`, `<key>-<slug>`).
2. **Most recent commit message** — `git log -1 --pretty=%B`. Check
   subject and body.
3. **PR title and body** — during PR creation/update,
   `gh pr view --json title,body`.
4. **Recent user prompts this session** — user often pasted the ticket
   URL/key when assigning work.

- Normalize matches to UPPERCASE.
- Multiple distinct keys → prefer branch-name key; still ambiguous →
  **ask** before transitioning anything:

  > "Found Jira keys {KEY-A, KEY-B}. Which one is the work for
  > this branch?"

- **No** key found → do not invent one. Skip transitions; in Stage 3 ask
  once whether a Jira ticket exists; if they say no, record it and stop
  offering for the rest of the branch.

---

## Stage 2: Start work — claim the ticket

**HARD RULE — claim the ticket as one atomic action.** On the first detected
development intent on a ticket each branch, four things fire together as one
"claim": assign-to-user **and** In Progress **and** active sprint **and** a
start comment. Never ship a subset.

- "Development intent" = any edit, commit, or PR work on a branch with a
  detected key — **not** only the literal first commit. A first-commit signal
  may never be observed (mid-branch join, resumed session, edit-before-commit).
- **Self-healing:** if Stage 2 has not completed this branch, run the whole
  claim now, whatever point you joined at. Verify against live ticket state
  (assignee, status, sprint) so a partial prior run finishes.

Fetch the detected ticket's current state, decide what to change.

```
mcp__claude_ai_Jira_Confluence__getJiraIssue(issueIdOrKey="<KEY>")
mcp__claude_ai_Jira_Confluence__lookupJiraAccountId(searchString="<git user.email>")
```

Compare current `status` and `assignee` against desired state:

- `assignee` unset → assign to the user. Already set to someone else → defer
  to the conflict table (do not silently reassign).
- `status` not already `In Progress` (or forward-equivalent like
  `In Review`/`Done` — never regress) → transition to `In Progress`.

Get available transitions before posting:

```
mcp__claude_ai_Jira_Confluence__getTransitionsForJiraIssue(issueIdOrKey="<KEY>")
```

- Match transition by name (case-insensitive contains `in progress`).
- No matching transition from current state → leave status alone, report
  the gap once.

Apply changes via:

```
mcp__claude_ai_Jira_Confluence__editJiraIssue   # for assignee
mcp__claude_ai_Jira_Confluence__transitionJiraIssue  # for status
```

Then run **Active-sprint assignment** and **Progress comment** subroutines
(below) to complete the claim. Report one line:

> "Jira: {KEY} → In Progress, assigned @<user>, sprint <name>, comment posted."

### Active-sprint assignment (subroutine)

Invoked after status transition in Stage 2 (→ In Progress) and Stage 4
(→ In Review). Failure mode: a ticket with no sprint lands in the
backlog — invisible on the sprint board, absent from velocity tracking.

- Find the active sprint on the ticket's project board:

  ```
  mcp__claude_ai_Jira_Confluence__searchJiraIssuesUsingJql(
    jql="project = <PROJECT> AND sprint in openSprints()")
  ```

  Read the sprint field from any returned issue → active sprint id.
- Set it on the ticket via `editJiraIssue`. Sprint field id is custom per
  instance (commonly `customfield_10020`) → resolve from issue/field
  metadata rather than assuming the number, then write the value in the
  shape the field expects (often `[{ id: <sprintId> }]`).
- Skip silently when no active sprint exists or field unavailable — not
  every board runs sprints.

### Progress comment (subroutine)

Invoked at each lifecycle change — Stage 2 (claim), Stage 3 (PR opened), Stage 5
(merged) — so watchers see progress on the ticket without opening the PR. The
missing-comment gap this prevents: a ticket that silently advances states with
no narrative of what was done.

- Post via `addCommentToJiraIssue(issueIdOrKey="<KEY>", commentBody="<note>")`.
- **Auto — no per-comment confirmation** (same exemption as auto-assign);
  lifecycle comments are additive, factual status notes, not user-voice prose.
- One line, factual, link the artifact — no marketing tone:
  - Stage 2: `` Started work on branch `<branch>`. ``
  - Stage 3: `PR opened: <pr-url>.`
  - Stage 5: `Merged via <pr-url>.`
- **Idempotent:** before posting, scan recent comments for an identical
  lifecycle note this branch; skip if already present — avoids duplicate spam on
  re-runs and self-healing reruns.
- Skip silently on comment-write failure — never block the dev workflow.

### Ticket description quality check

Run **Description quality gate** subroutine (below). Invoked from every
writable stage — Stage 2 (start), Stage 3 (PR created), Stage 4 (PR
ready) → a session joining mid-branch still gets a checkpoint before
reviewers see the ticket.

---

## Stage 3: PR title and description sync

When `wk-pr` creates/updates a PR for a branch with a detected key,
enforce two things.

### Title suffix

Every PR title carries the key in **square brackets** at the end of the
subject:

```
feat(auth): ✨ OAuth login [<KEY>]
fix(ci): 💚 pin dependency [<KEY>]
```

- One key per title. Work spanning multiple tickets → choose the primary
  one, reference others in the body.
- Square brackets, no parens, no colon prefix. Format `[<KEY>]`.
- Bracket suffix sits **after** the conventional-commit subject and any
  classifier emoji → last token in the title.
- Title already has a key suffix → do not duplicate. Existing key wrong →
  ask before replacing.

### Description reference

PR body must include a section linking back to the ticket so reviewers can
navigate to context:

```markdown
## Ticket

[<KEY>](https://<your-domain>.atlassian.net/browse/<KEY>) — <ticket summary>
```

- Place `## Ticket` near the top, just under the auto-generated
  `## Summary`.
- Pull `<ticket summary>` from the Jira issue (`fields.summary`) so the
  link carries human context. Use the canonical Atlassian URL the MCP
  returns.
- `wk-pr` already built a description → **insert** the `## Ticket` section
  rather than overwriting the rest. Section already exists → refresh its
  content if the ticket summary changed.

**HARD RULE:** Any `gh pr edit --body` issued by this skill routes through
`wk-gh` — the canonical outbound footer per `wk-gh` Step 4 stays at the
very end of the body, after the `## Ticket` insertion. Do not strip the
footer when editing; preserve it exactly once.

### PR-opened comment

On PR **creation** only (skip on PR updates), run **Progress comment**
subroutine → post `PR opened: <pr-url>`. The open event is commented once.

### Description quality check (Stage 3)

Run **Description quality gate** subroutine. PR-creation time exposes
title + summary → pre-fills `Problem` / `Context` with high confidence.

---

## Stage 4: PR ready → In Review

When `wk-pr` flips a PR draft → ready (`gh pr ready`), or the agent
observes a non-draft PR for the first time on the branch → transition the
ticket:

```
mcp__claude_ai_Jira_Confluence__getTransitionsForJiraIssue(issueIdOrKey="<KEY>")
mcp__claude_ai_Jira_Confluence__transitionJiraIssue(issueIdOrKey="<KEY>", transition={ id: "<resolved>" })
```

- Match transition name on case-insensitive contains `in review` /
  `code review` / `review` (that priority — `in review` strongest). Boards
  naming it `Ready for Review` match too.
- Do not regress: ticket already `In Review` or further forward → leave
  alone.
- Only forward transition is `Done` → stop and ask: board has no review
  state, Stage 4 is a no-op for this team.
- After transition → run **Active-sprint assignment** subroutine (Stage
  2) so a ticket that skipped Stage 2 still lands on the board.

Report once per state change:

> "Jira: {KEY} → In Review."

### Description quality check (Stage 4)

Run **Description quality gate** subroutine. PR-ready is the last natural
writable checkpoint — a session starting mid-branch (after initial commit
but before ready) → this is the only run that fires. Skipping it leaves
reviewers without the "why".

---

## Description quality gate (subroutine)

Invoked from any writable stage. Idempotent — safe to call repeatedly per
branch; skips silently after the first successful append.

- Evaluate `fields.description`. Treat as **thin** when any hold:
  - Empty, null, or whitespace-only.
  - Body text (after stripping markup) fewer than 40 characters.
  - Body repeats only the ticket summary or a placeholder (`TBD`, `n/a`,
    `see slack`, etc.).
- Thin → propose appending a structured context block. Never overwrite
  existing content — wrap it as `<existing details>`.
- Pre-fill `Date` with today's date (UTC, `YYYY-MM-DD`). Pre-fill
  `Problem` / `Decision` / `Trade-offs` / `Context` from the
  highest-signal source available at this stage (branch name, recent
  prompts, PR title/body, linked commits); leave empty otherwise.
- Append template:

  ```
  <existing details>

  ---

  Date: <YYYY-MM-DD>
  Problem:
  Decision:
  Trade-offs:
  Context:

  ---
  ```

- Confirm before writing — Manual ticket operations HARD RULE applies.
  Present the proposed merged description, wait for explicit approval,
  then call `editJiraIssue`.
- Skip silently when description already exceeds the thinness threshold OR
  this branch already had a successful enrichment append this session.

Report once on append:

> "Jira: {KEY} description enriched with context block."

---

## Stage 5: PR merged → Done

Agent observes PR merged (`gh pr view --json state` returns `MERGED`) →
transition the ticket to `Done`:

- **Run the Child-completion gate first** — never transition to `Done`
  while children remain open.
- Match transition name on case-insensitive contains: `done` first, then
  `closed`, then `resolved`. Pick the first that exists.
- Ticket already `Done`/`Closed`/`Resolved` → no-op.
- Multiple "done-like" transitions (e.g. `Done` and `Won't Do`) → always
  pick `Done`. **Never** auto-pick a cancellation/won't-do/duplicate
  transition — those require human judgment.
- PR merged but build/deploy gated behind a separate post-merge process
  (e.g. team's "Done" requires production deploy verification) → respect
  it: board workflow with a separate `Deployed`/`Verified` stage between
  `In Review` and `Done` → move only one step forward and report. Do not
  skip stages.

After the transition, run **Progress comment** subroutine → post
`Merged via <pr-url>`. Report:

> "Jira: {KEY} → Done. PR #<N> merged."

---

## Child-completion gate (subroutine)

**HARD RULE:** Never transition any item to a terminal state (`Done` /
`Closed` / `Resolved`) while it has children not yet in a terminal state.
Failure mode: closing an epic/parent with open children buries unfinished
work — invisible on the board, falsely counted complete. The parent's
state must never get ahead of its children.

- Invoked before every terminal transition — auto (Stage 5) and manual
  (terminal-state row, Manual ticket operations).
- Query open children via JQL (covers subtasks, epic children, and the
  parent link):

  ```
  mcp__claude_ai_Jira_Confluence__searchJiraIssuesUsingJql(
    jql='(parent = "<KEY>" OR "Epic Link" = "<KEY>") AND statusCategory != Done')
  ```

- Use `statusCategory != Done` (the category, not a named status) so
  every non-terminal state on any board counts as pending.
- Zero open children → proceed with the transition.
- One or more open children → **do not transition.** Surface the blocked
  list and let the user decide via `AskUserQuestion`:

  > "Jira: {KEY} has open children: {<child-key> (<status>), …}.
  > Closing the parent now would bury them. Transition anyway, or hold?"

- Transition only on explicit user approval; default to **hold**.
- JQL errors or the connector lacks `Epic Link`/`parent` support → treat
  as **unverified**, do not auto-transition, report the gap and ask.

---

## Stage 6: Surface ticket context (read-only)

Fires when the trigger was a Jira URL or key mention outside the
development lifecycle (e.g. user pasted a ticket link, asked a question
about a ticket, or a key surfaced in a doc the agent read).

- Fetch the ticket once per session per key (cache in-session):

  ```
  mcp__claude_ai_Jira_Confluence__getJiraIssue(issueIdOrKey="<KEY>")
  ```

- Report a one-line digest before answering the user's actual question:

  > "Jira: {KEY} — {summary} ({status}, assignee: @<them or 'unassigned'>)."

- Do **not** transition, assign, or write. Stage 6 is read-only.
- Do **not** prompt for the description-quality append here — Stage 2 owns
  that, requires development intent.
- Multiple keys in context → surface each once. Do not spam more than 5
  digests per turn — list the remainder by key only.

---

## Manual ticket operations (confirm-first)

User explicitly asks to create, edit, or batch-transition Jira items
outside the auto lifecycle → confirm before any write call. Jira write
operations via the Atlassian MCP connector (`createJiraIssue`,
`editJiraIssue`, and similar write methods) are effectively irreversible —
there is no delete API.

**HARD RULE:** Never call a Jira write method on user-initiated work
without explicit approval of the proposed change set. Auto mode does not
exempt — Jira items are visible to the whole team.

- Default `issueTypeName` to `"Story"` when creating an issue. Pick a
  different type only when the context names one (`Bug`, `Task`, `Epic`).
  Never fall back to `"Task"` as a generic default.

| Operation | Confirmation required | Command pattern |
|-----------|----------------------|-----------------|
| Create issue(s) | Yes — show numbered list of titles before writing | Present draft set, wait for "yes" / "go ahead" |
| Edit issue fields | Yes — if ambiguous source or batch | Show diff of proposed changes |
| Transition to terminal state | Yes — run Child-completion gate, then confirm target state | Block on open children; confirm explicitly |
| Assign to user (auto lifecycle) | No — auto-assign as part of Stage 2 | `editJiraIssue` with assignee |
| Post lifecycle comment (auto) | No — additive factual status note, part of the claim/PR/merge events | `addCommentToJiraIssue` |

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

Never block a commit, push, or PR action on a Jira sync failure — ticket
state is a side-effect of the work, not a precondition for it.

---

## Quick Reference

| Trigger | Stages |
|---------|--------|
| Jira URL or key in prompt / file / context (no dev intent) | 0, 1, 6 |
| Any dev work on a detected ticket, Stage 2 not yet done this branch | 0, 1, 2 |
| `wk-pr` creating/updating PR | 0, 1, 3 |
| `gh pr ready` succeeds | 0, 1, 4 |
| `gh pr view` shows MERGED | 0, 1, 5 |
| Ambiguous: multiple keys found | 1 only — ask |
| MCP unavailable | 0 only — silent skip |

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn jira`).
