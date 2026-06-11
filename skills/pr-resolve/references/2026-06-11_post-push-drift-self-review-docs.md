---
class: principle
---

- **Rule** — On every push, re-check self-review comment drift and docs drift,
  not just the PR body: correct/resolve submitted self-review threads whose
  code changed this session, and run `wk-docs` against the touched files.
- **Why** — A fresh push strands the agent's own self-review rationales and
  the docs it described pre-fix as readily as the PR body; syncing only the
  body leaves both misleading reviewers.
- **Where** — Step 8.5, new sub-section "Also re-check self-review and docs
  drift after the same push".
- **Note** — The three sibling requests (post-resolution CI loop, end-of-session
  retro, pre-push adversarial review + learn) were already covered by Step 9.5,
  Step 11, and Hard Rule + Step 9.4 respectively; only the self-review/docs
  drift gap was new.
