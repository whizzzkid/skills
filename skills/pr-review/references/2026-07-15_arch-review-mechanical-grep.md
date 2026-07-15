---
class: principle
---

**Rule** — In Phase 1, mechanically grep the changed-file list for
`docs/(specs|adr|arch|design|rfc)/` (and the filename-keyword triggers). A match
is an un-skippable gate that invokes `wk-arch-review` before Phase 3 — not a
judgment call.

**Why** — The unconditional-trigger HARD RULE already existed but was skipped
because the diff "looked like" a routine code review, so a new spec-doc addition
went un-arch-reviewed. A described trigger that relies on the agent noticing is
skippable; a grep command wired into the phase is structural.

**Where** — wk-pr-review, "Detect architecture-level changes"; escalated the
existing HARD RULE to a mechanical grep gate (re-violation, notch: structural).
