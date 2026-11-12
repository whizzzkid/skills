---
class: principle
skill: wk-pr
date: 2026-11-12
severity: medium
---

**Rule** — A new PR's number is an identifier like any other: capture the URL that `gh pr create`
prints on stdout, derive the number from it (`${PR_URL##*/}`), and use only that value in every
follow-up — ticket comment, CI watch, self-review, stack cross-link. Never predict it from the
previous PR in the session.

**Why** — After opening a stacked PR, the next number was extrapolated from the prior one and
written into a ticket comment and a CI watch. Other PRs had opened in between, so both pointed
at an unrelated PR. The failure is a *plausible* value, so nothing in its shape prompts a check.
Hard Rule 4's identifier clause already required command-sourced identifiers, but scoped them to
the PR body; follow-ups outside the body were uncovered, so this is a `partial` extension, not a
re-violation escalation.

**Where** — `wk-pr` → Hard Rule 4 (identifier clause widened to follow-ups + PR number); Step 2
fallback snippet captures `PR_URL` / `PR_NUMBER`.
