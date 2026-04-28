---
skill: wk:pr-review
date: 2026-04-28
type: gap
severity: medium
---

When deduplicating against bot reviewers, prefer replying with local validation
+ actionable fix over silently skipping.

**What happened:** During a re-review of a PR that already had a bot reviewer
(`{bot}`) post unresolved comments, the skill's deduplication
rule ("never post a new top-level comment that duplicates an existing review
comment") was followed correctly — the agent dropped its overlapping findings
into a "Skipped" section. The user explicitly redirected: "For the comments
that have been flagged by the bot add a comment saying this was validated
locally."

**Root cause:** Phase 5's deduplication guidance treats bot/human reviewers
identically. For human reviewers, silently skipping is correct (they already
made the point and a second voice is noise). For bot reviewers, a skip is a
missed signal — a second-pass agent independently reaching the same conclusion
is *evidence* the issue is real, and replying gives the author confidence to
act. The skill currently captures this only for the re-review flow ("fix
attempted, still wrong" / "no response") and only for the *current user's*
prior comments, not for bot reviewers in the PR.

**Suggested fix:** In Phase 5 ("Deduplicate against existing comments"),
distinguish bot vs. human reviewers when handling overlap. For a duplicate
where the original reviewer is a bot AND the agent has independently confirmed
the issue (via Phase 3 reading or Phase 4 playground):

  - Reply to the existing thread with one line of local-validation evidence
    ("Validated locally — confirmed at <file>:<line>") and a concrete actionable
    fix (snippet, exact pattern, or one-line directive).
  - Do not post a parallel top-level comment. The reply approach preserves the
    "no duplicates" rule while preventing the loss of independent verification.
  - These replies count toward the 6-comment cap, same as new top-level
    comments.

For human reviewers, the existing skip-with-disclosure behavior is correct;
the new branch only fires when the original `user.type` is `Bot` (or login
ends in `[bot]`).

Phase 2 should also surface bot vs. human breakdown in the active-comments
summary so the agent can plan the dedup strategy before Phase 3.
