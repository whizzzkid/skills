---
class: principle
---

**Rule** — Exclude ephemeral working docs (plan docs, scratch notes, agent
handoff files) from commits. Only settled docs (specs, ADRs) belong in history.
Before `git add` on any docs path, confirm the repo commits that directory.

**Why** — Staging everything under `docs/` blindly leaks working artifacts into
the PR. Many repos track `docs/specs/` and `docs/adr/` but treat `docs/plans/`
(and equivalents) as ephemeral — committing them pollutes history with content
the repo's convention never intended to keep.

**Exception** — User-explicitly-directed in-repo artifacts are intended
deliverables, not scratch. When the user directs artifacts to a specific in-repo
path (not a known-ephemeral dir), stage them with the work by default. Withholding
them as "ephemeral" forces the user to ask again to include them.

**Where** — wk-commit, "Exclude ephemeral working docs from commits", before the
staged-set verification step.
