---
class: principle
---

# An auto-action that leaves a draft is not a completed action

**Rule** — rendering an auto-action done records that the *launch* happened, not
that the work finished. When the action leaves an artifact the user must still
act on (an unsubmitted review draft, an unsent reply, an uncommitted block), it
stays open work: re-query it on every run and re-surface it until the artifact
reaches a terminal state. Query the class org-wide each run — re-verifying only
the specific resource IDs a prior run happened to touch finds nothing once the
prior run's report is out of scope.

**Why** — a launched-and-forgotten draft produces no signal anywhere. It is
invisible in the done column (marked complete), invisible in the open column
(never surfaced), and invisible to the external service (the draft exists but
nobody is queried about it), so it accumulates silently for days. Only a
standing sweep keyed on the artifact's non-terminal *state* closes the loop; a
one-off manual re-check is a catch, not a control.

**Where** — `SKILL.md` → Rendering contract (*Mark done only what is terminal*),
Stage 2 GitHub agent (own `PENDING` review sweep), Stage 7 (launched draft is
not terminal).
