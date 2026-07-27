---
class: principle
skill: wk-commit
date: 2026-07-27
severity: high
---

**Rule** — The trailer set this skill adds on its own initiative is closed to
`Assisted-by:`. Any other trailer lands only where the user or an invoking skill
explicitly directs it for that commit — never inferred from sibling commits, from
branch history, or from the mere availability of an employee-email env var. A
trailer edit on already-pushed commits is a history rewrite whose real cost is the
fan-out of SHAs recorded outside git.

**Why** — The skill mandated `Assisted-by:` but said nothing about the trailers it
does *not* want, so "what do sibling commits look like?" filled the gap and a
human co-author trailer was stamped onto every commit on a branch. Two pre-existing
instances actively invited the copy: the HEREDOC example carried an unconditional
`Co-Authored-By:` line, and the `Assisted-by:` bullet read "place alongside any
`Co-Authored-By:` / `Generated with` trailers" — over-general phrasing that reads
as an expectation rather than a conditional. Both were corrected in the same pass.

The correction cost is what makes this high severity: rewriting the branch changed
every SHA, invalidating the per-item landing SHAs already recorded in a plan doc,
the PR body, and a tracking issue. Those had to be remapped old→new by hand. The
same-session retrospect independently recorded the recovery sweep (enumerate every
recorded SHA, re-verify each with an ancestry check) as a practice that worked, so
the sweep is folded as a rule rather than left to be re-derived.

**Compatibility** — the closed-set rule is phrased to admit "an invoking skill's
explicit directive" so it does not contradict `wk-pr-takeover` (co-author trailers
for the original author) or `wk-pr-resolve` (PR-author co-author per commit), both
of which direct a co-author trailer as part of their own documented flow.

**Where** — `wk-commit` → new HARD RULE *the trailer set is closed* (after the
`Assisted-by:` section, before the never-fabricate-an-email rule); the
never-fabricate rule's `$WK_SKILLS_EMPLOYEE_EMAIL` bullet gained an "once directed"
qualifier; the SHA fan-out bullet joined *Preserve signatures when rewriting
history*.
