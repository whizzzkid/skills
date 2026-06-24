---
class: principle
---

**Rule** — For a PR whose net diff is under 25 lines AND whose final
adversarial-review verdict is `clear` with zero findings, skip the poll-and-wait CI
loop: mark ready and `gh pr merge --auto --squash`. Record the threshold and
auto-merge intent in the PR body. Any logic-bearing or larger diff takes the full CI
poll.

**Why** — The standard ready-marking sequence (poll CI to completion, then manual
`gh pr ready`) adds disproportionate latency for trivial, low-risk deltas (dead-target
removal, count updates). Auto-merge lets required checks gate the merge without a
human poll loop, while the size + clean-review guard keeps risky changes on the full
path.

**Where** — wk-pr Step 5 (mark ready); wk-workflow Phase 5/6 ready/CI sequence.
