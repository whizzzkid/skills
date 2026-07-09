---
skill: wk-pr-resolve
class: principle
---

**Rule** — Before replacing a PR description with a whole-body edit, capture the
original first (`gh pr view --json body`). Diff the new body against the captured
original, not against a reconstruction.

**Why** — A whole-body replace performed without first saving the pre-edit text
leaves no ground truth for drop-detection; you can only diff against a
reconstruction, which cannot prove nothing was silently dropped.

**Where** — wk-pr-resolve Step 3 (agent-observed drift).
