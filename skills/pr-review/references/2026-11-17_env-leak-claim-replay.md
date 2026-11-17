---
class: principle
---

# Replay env-dependent claims in an isolated environment

**Rule**

- A claim whose truth depends on environment ("fails locally", "CI-only", "N examples fail here, not N-2") → replay
  under `env -i HOME="$HOME" PATH="$PATH"`, never the reviewer's own shell.
- Then add each gating variable singly and rerun, so every difference in the result is attributed to one variable.

**Why**

- A review refuted an author's env-dependent failure count, but its replay had inherited CI-like variables from the
  reviewer's shell. Under a bare environment the author's count held, and each extra failure appeared only once its
  gating variable was set. An inherited env makes a "local" run CI-like, so a refutation built on it is invalid.

**Where** — `SKILL.md` → Phase 1 → Claims bullet (env-dependent sub-bullet).

**Already covered (not folded)** — the same report's note that an own pending draft can be submitted with a
replacement body via `POST /reviews/{id}/events` (no delete+recreate) is already installed: Phase 2 "Own pending
draft" no-delta path and `posting-pending-review.md` → "No-delta shortcut" / "Submit as approval".
