---
skill: wk-pr
date: 2026-04-29
type: gap
severity: high
---

PR skill assumed `main` was the base branch and did not detect when the
current branch was forked from a non-default branch.

**What happened:** Created a PR for `refactor/BOARD-NUM-cli-runner` with
default base (`main`). The branch was actually forked from another
in-flight branch (`feat/{repo}-status-comment`), so the diff against
`main` included unrelated commits from the parent branch and the PR
became implicitly stacked without the `[Part X/Y]` annotation or
`--base` flag. CI failed against the wrong base.

**Root cause:** Step 1 of the skill measures scope with
`git diff main...HEAD --stat` and Step 2 creates the PR via
`gh pr create --draft` with no `--base` flag — both assume the default
branch is the correct base. There is no detection of the actual fork
point or check for whether the current branch is downstream of another
open PR's branch.

**Suggested fix:** Before measuring scope or creating the PR, detect
the true base branch:

1. Find the branch's most recent merge-base with each candidate base.
   Candidates = the default branch + every open PR's `headRefName`
   (the user's own and others'). The closest merge-base wins.
2. If the closest base is NOT the default branch, surface this to the
   user: "This branch was forked from `<base>`, which has an open PR
   (#N). Should I create this PR with `--base <base>` and treat it as
   stacked, or rebase onto the default branch first?"
3. Apply the chosen base to BOTH the diff measurement
   (`git diff <base>...HEAD`) AND the `gh pr create --base <base>`
   invocation.
4. When stacking is chosen, add the `[Part X/Y]` suffix per the
   existing stacked-PR convention and inject the `## Stack` section.

The fork-point detection logic should run unconditionally — even on
branches the user thinks were forked from `main` — because silent
mis-basing is hard to recover from after CI runs and reviewers start
reading.
