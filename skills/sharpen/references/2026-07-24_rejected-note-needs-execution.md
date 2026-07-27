---
class: principle
---

# A recorded rejection is a case to execute, not prose to re-read

**Rule** — when an audit surfaces a `Rejected` / `Deliberately not promoted` note
covering the design about to be adopted, reading it does not discharge it. Extract
the concrete shape the note names, drive it against the artifact **before and after**
the change, and require an identical verdict. Land that shape as a pinned test in the
same pass. When the design is adopted with a compensating rule, rewrite the note to
state what actually holds.

**Why** — a rejection stored as narrative forces nothing to run. A suite can stay
fully green across the regression precisely because it never had a case for the
rejected shape; green then reads as permission to proceed. Driving the artifact
directly across both versions exposed the inverted verdict (old: blocked, new:
allowed) that the suite could not see.

Second failure mode: an over-broad rejection. When only one shape actually depends on
the rejected mechanism, a blanket "this design is unsafe" note misdescribes a problem
that needs one compensating rule — so a later pass faces a false choice between
obeying a too-wide note and silently re-opening the hole it guarded. A stale blanket
rejection gets either wrongly obeyed or wrongly ignored; both are wrong.

**Where** — `SKILL.md` → Step 1 → *HARD RULE: the report is a hypothesis*, adjacent to
the rule that records rejected suggestions in the first place (the write side and the
read side of the same note now sit together).
