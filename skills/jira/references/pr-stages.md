# Jira PR-lifecycle stages (3–5) and Child-completion gate

Loaded from SKILL.md. Progress comment, Active-sprint assignment, and Description quality gate are the SKILL.md
subroutines.

## Stage 3: PR title and description sync

When `wk-pr` creates/updates a PR with a detected key:

- **Title:** append `[<KEY>]` as last token (`feat(auth): ✨ OAuth login [<KEY>]`). One key per title; multiples →
  primary in title, others in body.
- **Description:** insert `## Ticket` (under `## Summary`) with `[<KEY>](<url>) — <summary>`; refresh if changed.
  **HARD RULE — footer placement:** `wk-gh` Step 4 footer stays at very end, after `## Ticket`; never strip it when
  editing — exactly once.
- On creation only → Progress comment `PR opened: <pr-url>`. Run the description gate (PR creation pre-fills
  `Problem`/`Context`).

## Stage 4: PR ready → In Review

Draft → ready (`gh pr ready`) or non-draft first observed → transition:

```
mcp__claude_ai_Jira_Confluence__getTransitionsForJiraIssue(issueIdOrKey="<KEY>")
mcp__claude_ai_Jira_Confluence__transitionJiraIssue(issueIdOrKey="<KEY>", transition={ id: "<id>" })
```

Match case-insensitive: `in review` > `code review` > `review`. Do not regress. Only forward = `Done` → stop and ask
(no review state). After transition → Active-sprint assignment; report "Jira: {KEY} → In Review."; run the
description gate (last checkpoint before reviewers).

## Stage 5: PR merged → Done

PR state = `MERGED` → run the Child-completion gate first, then transition to `Done`: match case-insensitive `done` >
`closed` > `resolved`; never auto-pick cancellation/won't-do; board with `Deployed`/`Verified` stage → one step
forward only; already terminal → no-op. Progress comment `Merged via <pr-url>`; report "Jira: {KEY} → Done. PR #<N>
merged."

**Child-completion gate (subroutine).** **HARD RULE:** Never transition to terminal state (`Done`/`Closed`/`Resolved`)
while children are non-terminal — closing a parent buries unfinished work. Invoked before every terminal transition,
auto (Stage 5) and manual.

```
mcp__claude_ai_Jira_Confluence__searchJiraIssuesUsingJql(
  jql='(parent = "<KEY>" OR "Epic Link" = "<KEY>") AND statusCategory != Done')
```

Zero open → proceed. Open children → surface list, ask user, default to hold. JQL error → unverified, ask.
