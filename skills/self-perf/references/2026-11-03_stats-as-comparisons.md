---
class: principle
---

# Stats as rank and ratio; teammates' exports stay out of git

- **Rule:** Present performance stats as the user's rank and ratio vs team average, quoting only the user's own
  figures. Keep team-wide per-person exports outside `QPR/` or gitignored, checked before Stage 3 stages `QPR/`. Flag
  any org-wide superlative without a source as unverified.
- **Why:** A developer-analytics export carried per-person metrics, names, and emails for the whole team (the
  analytics connector lacked permissions, so a user export was the only path). The user wanted "most on the team,
  ~2.4× average", not raw counts. Stage 3's `git add QPR/` would have committed teammates' data with the corpus.
- **Where:** [`wk-self-perf`](../README.md) → Stage 2 HARD RULE; DX row in
  [`synthesis-template.md`](synthesis-template.md). Filed against `wk-sitrep`; rerouted to the owner of review-cycle
  writing.
