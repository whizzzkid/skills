---
skill: wk-pr-resolve
date: 2026-04-27
type: gap
severity: medium
---

Skip triage prompts when the fix is obvious and the "skip" rationale is empty.

**What happened:** During PR #NNN resolve, three bot findings were unambiguous
docs fixes (broken link to a renamed spec file, stale env-var references that
contradicted the PR's stated intent of inverting allowlist → denylist). Each
was presented through the full triage prompt (a/e/d/t/s/r) even though there
was no judgment call — the "Why this could be skipped" field for each was
literally "No valid reason — broken link / stale reference." User feedback:
"when the fix is obvious and it cannot be skipped, such comments should not
be triaged, only questions that need my input should be asked."

**Root cause:** Step 5 currently presents every active comment via the same
consultation prompt regardless of whether a real judgment call exists. The
suggestion format already captures this — when "Why this could be skipped"
reduces to "no valid reason," the prompt is a no-op interaction.

**Suggested fix:** In Step 4, classify each suggestion as either
`obvious-fix` (skip rationale is empty / "no valid reason" / the fix
mechanically follows from a previous user-approved change in this same PR)
or `judgment-required` (real tradeoff, false-positive possibility, scope
question, multiple valid approaches). In Step 5:

- For `obvious-fix` findings: bundle into a "Will auto-apply" preview list
  shown once at the top, default to `(a)`, and proceed without per-comment
  prompts. Still create one commit per finding (Hard Rule 7) and reply +
  resolve as normal.
- For `judgment-required` findings: present one at a time as today.

The user can override with a single "review each one individually" reply if
they want the old behavior. This preserves the one-at-a-time discipline for
real decisions while removing ceremony from mechanical fixes — especially
common in post-rename / post-inversion cleanup PRs where the bot surfaces
many "you missed this reference" findings that are all the same kind of
fix.
