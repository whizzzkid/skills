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
  version: "2026.10.09-184159"
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

Keep Jira ticket state in lockstep with the PR lifecycle; flip state on the user's behalf:
```
Start work ──► In Progress + assign + active sprint + comment
PR opened  ──► title = "<conventional>: <subject> [BOARD-NUM]", description refs ticket
PR ready   ──► In Review
PR merged  ──► Done + comment
```

## Trigger rules — run only matching stages; undeterminable → Stage 1, report, never guess

**HARD RULE — auto-invoke on context.** Never assume "wasn't told to look up Jira": Jira URL/key in context → Stage
0+1+6 before any response depending on ticket context. Skip only when MCP unavailable.

**HARD RULE — wk-jira claim precedes wk-workflow Phase 1.** Key in session-opening prompt is a development claim →
Stage 0+1+2 (full claim) before Phase 1 planning; never let `wk-workflow` fire first and skip it.

**HARD RULE — footer on every agent-authored Jira body.** Canonical `wk-gh` Step 4 footer on lifecycle comments,
description enrichments, `gh pr edit --body`. A terse lifecycle comment is no exemption — every agent-authored
outbound body.

## Stage 0: MCP availability check

```
ToolSearch select:mcp__claude_ai_Jira_Confluence__getJiraIssue,mcp__claude_ai_Jira_Confluence__transitionJiraIssue,mcp__claude_ai_Jira_Confluence__editJiraIssue,mcp__claude_ai_Jira_Confluence__searchJiraIssuesUsingJql,mcp__claude_ai_Jira_Confluence__getTransitionsForJiraIssue,mcp__claude_ai_Jira_Confluence__lookupJiraAccountId,mcp__claude_ai_Jira_Confluence__addCommentToJiraIssue
```

**HARD RULE — MCP-only.** Never read/write Jira via browser/WebFetch/web-search. Unavailable → skip silently (no
browser fallback), let workflow proceed.

**HARD RULE — resolve cloudId first.** `getAccessibleAtlassianResources` before any other Jira/Confluence call; use its
UUID `cloudId` for every later call and cache `cloudId`/hostname. Never guess `<org>.atlassian.net` or derive it from
the org name (404s).

## Stage 1: Detect the ticket key

Match `[A-Z][A-Z0-9]+-\d+`; take the first hit: 1) branch name (`git rev-parse --abbrev-ref HEAD`) 2) last commit
(`git log -1 --pretty=%B`) 3) PR title/body (`gh pr view --json title,body`) 4) recent user prompts. Normalize to
UPPERCASE. Multiple keys → prefer branch name; ambiguous → ask. No key → skip transitions; ask once whether a ticket
exists; "no" → stop offering.

**HARD RULE — detected key is candidate, not confirmed.** Before transitioning it or writing it into a PR title/body,
fetch (`getJiraIssue`) and confirm `summary`/component/`status` plausibly match the diff. Mismatch (different service,
Done for unrelated work) → do not tag; surface, locate or create the correct ticket under the right parent, re-point
all references.

## Stage 2: Start work — claim the ticket

**HARD RULE — atomic claim.** First development intent per branch fires four things together: assign-to-user + In
Progress + active sprint + start comment. Never a subset. Development intent = any edit, commit, or PR work — not
only first commit. Self-healing: if Stage 2 incomplete, run full claim now against live ticket state.

**HARD RULE — blocked write surfaced once.** A key in the prompt is context, not write authorization. Permission
denial → stop (never spin or silently swallow), tell user, ask once to confirm intent or add permission rule. Retry
only after resolution; otherwise proceed (ticket state is side-effect, never precondition).

```
mcp__claude_ai_Jira_Confluence__getJiraIssue(issueIdOrKey="<KEY>")
mcp__claude_ai_Jira_Confluence__lookupJiraAccountId(searchString="<git user.email>")
```

`assignee` unset → assign; someone else → do not reassign, report. `status` not `In Progress` → transition; already
forward (`In Review`/`Done`) → never regress. Get transitions, match case-insensitive `in progress`, apply:

```
mcp__claude_ai_Jira_Confluence__getTransitionsForJiraIssue(issueIdOrKey="<KEY>")
mcp__claude_ai_Jira_Confluence__editJiraIssue       # assignee
mcp__claude_ai_Jira_Confluence__transitionJiraIssue  # status
```

Then run Active-sprint assignment ([`references/active-sprint.md`](references/active-sprint.md)) and Progress comment;
report "Jira: {KEY} → In Progress, assigned @<user>, sprint <name>, comment posted."

**Progress comment (subroutine)** — at each lifecycle change via `addCommentToJiraIssue`, auto (no confirmation), one
factual line linking the artifact: Stage 2 `` Started work on branch `<branch>`. ``; Stage 3 `PR opened: <pr-url>.`;
Stage 5 `Merged via <pr-url>.` Idempotent: scan recent comments, skip if present. Skip silently on failure.

**Description quality gate (subroutine)** — run at every writable stage (2/3/4), so a mid-branch join still gets a
checkpoint. Criteria, template, flow: [`references/description-gate.md`](references/description-gate.md).

## Stages 3–5: PR sync, In Review, Done

Follow [`references/pr-stages.md`](references/pr-stages.md) (title/`## Ticket` sync and footer placement, In Review
transition, Done transition, Child-completion gate): Stage 3 when `wk-pr` creates/updates a PR with a detected key;
Stage 4 on draft → ready (`gh pr ready`) or non-draft first observed; Stage 5 when PR state = `MERGED`. Run the
Child-completion gate before every terminal transition, auto (Stage 5) and manual.

## Stage 6: Surface ticket context (read-only)

Jira URL/key outside the dev lifecycle → fetch once per session per key: "Jira: {KEY} — {summary} ({status},
assignee: @<them>)." No transitions, no writes. Max 5 digests per turn; list remainder by key.

## Manual ticket operations (confirm-first)

User-initiated creates/edits/batch-transitions → confirm before any write; Jira writes are irreversible (no delete
API). **HARD RULE:** never write without explicit approval of the change set on user-initiated work. Auto mode does
not exempt. Default `issueTypeName`: `"Story"`. Auto (no confirm): assign (Stage 2), lifecycle comments. After
creating → Active-sprint assignment.

## Conflict and missing-state handling

Already in target → no-op. No valid transition → skip, report once. Multiple matches → closest name, tie-break
alphabetic. Assignee is someone else → do not reassign; report once. Any Jira failure → report once, never block
commit/push/PR; ticket state is side-effect, not precondition.

## Post-Completion

Invoke `wk-learn jira`.
