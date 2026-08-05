---
class: principle
---

# Existing review output is not authorization for a new run

**Rule** — Optional local or external model-backed reviewers run only when the
user explicitly requests that reviewer in the current task. Otherwise consume
and validate existing CI-triggered results without launching a fresh review.

**Boundary** — This rule governs optional reviewer systems. It does not disable
the phase-owned review skills that `wk-pr-review` explicitly declares as part of
its own contract.

**Why** — Reading an existing result and creating a new reviewer run have
different cost, side-effect, and authorization boundaries. Treating one as
permission for the other surprises the user and duplicates review work.

**Where** — `SKILL.md` → GitHub interaction routing → optional reviewer opt-in.
