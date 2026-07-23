---
class: principle
---

**Rule** — When merging a PR that is the base of stacked children, retarget every
child onto the merging PR's base, then re-query and confirm each child's
`baseRefName == {base}`. If any child is still based on `{head}` after transient-error
retries are exhausted, STOP — do not run the merge. Report the un-retargeted children
to the user and wait.

**Why** — Merging with `--delete-branch` deletes `{head}`. A child still pointing at
`{head}` loses its base branch and GitHub closes/orphans the child PR. The agent
previously treated retarget as fire-and-forget and merged anyway, silently closing the
stack. A failed retarget is a hard stop, not a warning to continue past.

**Where** — pr-merge Step 6 (stacked-child retarget block), distinct from the benign
transient-500 retry path (retryable) — this rule fires only after retries fail.
