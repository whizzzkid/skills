---
name: wk-jira
description: >-
  Coordinate Jira ticket state with the dev lifecycle and surface Jira
  context. Auto-invoked on a Jira URL, a key token (`[A-Z][A-Z0-9]+-\d+`)
  in a prompt/branch/commit/PR/agent message, branch start, or PR
  create/draft→ready/merge. Requires the Jira MCP connector. Not
  user-invocable.
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
  version: "2026.08.24-192013"
  internal: false
  model:
    openai: gpt-5.6-terra
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

## Trigger rules

Each stage describes its own trigger. Run only matching stages per invocation.
If undeterminable → default to Stage 1 (detect), report findings, never
guess and transition.

**HARD RULE — auto-invoke on context.** If a Jira URL or key is in the
agent's context → Stage 0 + 1 + 6 run before any response depending on
ticket context. A Jira key/URL in the session-opening prompt is a
development claim — run Stage 0 + 1 + 2 **before** `wk-workflow` Phase 1
planning.

**HARD RULE — footer on every agent-authored Jira body.** Every body this
skill composes ends with the canonical `wk-gh` Step 4 footer — lifecycle
comments, description enrichments, and `gh pr edit --body`.

---

## Stage 0: MCP availability check

```
ToolSearch select:mcp__claude_ai_Jira_Confluence__getJiraIssue,mcp__claude_ai_Jira_Confluence__transitionJiraIssue,mcp__claude_ai_Jira_Confluence__editJiraIssue,mcp__claude_ai_Jira_Confluence__searchJiraIssuesUsingJql,mcp__claude_ai_Jira_Confluence__getTransitionsForJiraIssue,mcp__claude_ai_Jira_Confluence__lookupJiraAccountId,mcp__claude_ai_Jira_Confluence__addCommentToJiraIssue
```

**HARD RULE — MCP-only, cloudId-first.** All Jira reads/writes go through
the MCP connector — never browser, WebFetch, or web-search. On availability:
- Unavailable → skip silently, log one line, let dev workflow proceed. Point
  to https://claude.ai/customize/connectors only when user asks.
- Available → call `getAccessibleAtlassianResources` (no params) as the
  mandatory first API call; cache the returned `cloudId`/hostname. Never
  guess an `<org>.atlassian.net` slug — it 404s when the subdomain diverges
  from the org name.

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

### Verify the key describes this work

**HARD RULE — a detected key is a candidate, not a confirmed match.** An
inherited or copy-pasted key from a branch/commit can point at unrelated work
(a different component, or a Done ticket for another change). Before
transitioning it or writing it into a PR title/body, fetch the issue
(`getJiraIssue`) and confirm `fields.summary`, component/area, and `status`
plausibly describe the current diff.

- Mismatch signals: summary/component names a different service or feature than
  the diff; ticket is `Done`/`Closed`/`Resolved` for unrelated work.
- On mismatch → do not tag the stale key. Surface it, then locate or create the
  correct ticket under the right parent and re-point all references.

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

**HARD RULE — a blocked Jira write is surfaced once, never silently retried.**
Auto mode (and permission classifiers) treat a Jira write as an external-system
write needing explicit intent — a ticket URL/key in the opening prompt counts as
*context*, not *authorization* to modify the ticket. So the claim's transition
can be denied even though this skill considers it auto. On a permission denial:

- Stop. Do not spin on repeated denials, and do not silently swallow the block.
- Tell the user the write was blocked, and ask **once** to either: (a) confirm
  intent — "yes, transition this ticket as we work" — or (b) add a permission
  rule for the Jira MCP write methods.
- Retry only after the user resolves it; otherwise proceed with the dev workflow
  (ticket state is a side-effect, never a precondition — see Conflict handling).

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

Assigns the ticket to the active sprint so it appears on the board. Full
procedure: [`references/active-sprint.md`](references/active-sprint.md).

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

Append `[<KEY>]` as the last token in the title (after emoji):
`feat(auth): ✨ OAuth login [<KEY>]`. One key per title; multiple tickets →
primary in title, others in body. Do not duplicate; wrong key → ask before
replacing.

### Description reference

Insert `## Ticket` section (near top, under `## Summary`) with
`[<KEY>](<atlassian-url>) — <summary>`. Pull summary from `fields.summary`.
Insert into existing body; refresh if changed. Link only the current ticket —
no `Related:`/`Epic:` unless explicitly requested.

**HARD RULE — footer placement in a PR body.** Per the top-level footer rule,
keep the `wk-gh` Step 4 footer at the very end of the body, after the
`## Ticket` insertion; do not strip it when editing — preserve it exactly once.

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

Enriches thin ticket descriptions with a structured context block. Full
criteria, template, and flow:
[`references/description-gate.md`](references/description-gate.md).

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

- Default `issueTypeName` to `"Story"`. Different type only when context names
  one. Never fall back to `"Task"`.
- **Confirm-required:** create, edit (ambiguous/batch), terminal transition
  (child-completion gate first). **Auto (no confirm):** assign (Stage 2),
  lifecycle comments.
- After creating, run Active-sprint assignment on each new issue.

---

## Conflict and missing-state handling

- **Already in target state** → no-op. **No valid transition** → skip, report
  gap once. **Multiple matches** → prefer closest name match, tie-break
  alphabetic.
- **Assignee set to someone else** → do not reassign; report once.
- **Any Jira failure** (auth error, deleted ticket, permission denial) → report
  once, never block a commit/push/PR. Ticket state is a side-effect, not a
  precondition.

---
