---
class: principle
skill: wk-sharpen
date: 2026-07-24
severity: medium
---

**Rule** — A reproduction that disproves *or merely sharpens* the reported mechanism voids the
pre-verification draft. Re-derive the fold from the source's semantics; never keep the draft and
correct its wording. Prefer the formulation the source can be driven to demonstrate.

**Why** — The prior rule treated verification as a pass/delete filter on the report's mechanism,
with no step that re-opens the edit once the real mechanism is in hand. The natural move after a
disproof is therefore to keep the draft and reword it, which silently inherits the report's framing
and its vagueness. In the originating case the report inferred "compound-command shapes and quoting
attract the block"; the source showed shape-insensitive whole-payload token scanning, so no single
call may hold both a search verb and an out-of-repo path. The draft would have documented "the
compounding itself is the blocked element" — vague, and unverifiable by a later run. The corrected
mechanism also surfaced a second lever the report had only guessed at (the file-write guard warns
rather than blocks), which no amount of rewording the draft would have produced. A corrected
mechanism changes *what the rule says*, not only how it reads, and usually upgrades a heuristic
remediation to a deterministic one.

**Where** — Step 1's report-is-hypothesis HARD RULE, appended to the confirm/delete bullet, since
it is the missing third branch of the same decision (confirm → keep; disprove → delete; disprove or
sharpen → re-derive).

**Rejected** — Nothing relaxed. No escalation: the existing rule did not fail, it fired correctly
and terminated one step early, so this is a gap fold rather than a re-violation.
