---
skill: wk-sharpen
date: 2026-07-27
type: gap
severity: medium
verified-against-source: yes
---

A suggested fix can be mechanically true and still un-foldable, because it
contradicts a HARD RULE already installed in the skill it would land in.

**What happened:** A learning correctly diagnosed that a CI agent's
environment-hook failure is reported under the build step's own name with a
synthetic exit status, so the check list cannot distinguish it from a real test
failure. The mechanism was right and verified. But its "Suggested fix" section
prescribed the remedy as raw `curl` calls against the CI provider's REST API —
for listing the failing jobs, reading the log, and retrying.

The target skill opens with a standing HARD RULE that its vendor CLI is used for
every inspection, with REST permitted only when that CLI is unavailable *and*
the user approves, plus an explicit ban on extracting a token to call REST via
`curl` as a workaround. Folding the report's commands verbatim would have
installed, in the same file, a prescribed procedure that its own earlier rule
forbids — the next run would obey whichever it read first.

The fold instead expressed the classification in the CLI's own terms,
cross-referenced the existing retry section rather than restating it, and kept
only the one durable REST detail (a raw log payload carries ANSI escapes and
inline timestamp markers that must both be stripped), scoped explicitly to the
already-approved fallback path.

**Root cause:** Step 1's report-is-a-hypothesis rule interrogates whether the
report's *mechanism* is true, and Step 4 warns off a fix that would relax a
guard. Neither asks the adjacent question: is the prescribed remedy compatible
with the hard rules already installed in the target skill? Step 5's audit does
say "resolve contradictions", but it runs after drafting and is framed as
merging overlapping instructions — by then the conflicting commands are already
written, and a contradiction between a new procedure and an old HARD RULE reads
as two valid options rather than as a defect.

A reporter writes the fix in whatever tooling they happened to use during the
incident. That tooling is incidental to the lesson, but it arrives dressed as
the remedy, and the tighter the report's mechanism, the more authority its
commands borrow.

**Suggested fix:** In Step 4, before drafting, check the report's suggested
remedy against the target skill's existing HARD RULEs and tool-selection rules.
Where they conflict, the installed rule wins: re-express the lesson in the
sanctioned tooling and keep only the details that survive the translation.
Record the rejected form and the rule it violated in the reference file, so a
later pass does not re-derive it from the same report. Generalizes past tooling
— any suggested remedy naming a command, endpoint, or file location the target
skill already constrains gets the same treatment.
