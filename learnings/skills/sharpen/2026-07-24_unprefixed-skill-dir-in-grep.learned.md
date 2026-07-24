---
skill: wk-sharpen
date: 2026-07-24
type: gap
severity: medium
---

A coverage grep aimed at `skills/wk-<name>/SKILL.md` hits nothing and reads as "rule absent" — the on-disk directory never carries the `wk-` prefix.

**What happened:** During Step 2 (read the full skill) and the cross-skill coverage
sweep, a grep was issued against `skills/wk-sharpen/SKILL.md`. The tool emitted
`No such file or directory` and returned zero matches. The real path is
`skills/sharpen/SKILL.md` — the `wk-` prefix lives only in the `name:` frontmatter
field, never in the directory name. The mistake was caught because the warning was
visible in the output, and a directory listing then revealed the correct path.

**Root cause:** The skill refers to the edit target as `skills/{skill-name}/SKILL.md`
without stating that `{skill-name}` is the *unprefixed* form, while every user-facing
reference to the same skill uses the prefixed name (`wk-sharpen`, `/wk-sharpen`).
Nothing instructs the agent to normalize. `wk-learn` has an explicit HARD RULE
stripping a leading `wk-` before building a learnings path; `wk-sharpen` has no
equivalent for locating the file it edits.

The dangerous case is silent: a zero-match coverage grep is indistinguishable from a
genuine gap. That inverts Step 3's `already-covered` decision — an existing rule reads
as absent, so the fold duplicates it, or an escalation is skipped because the baseline
rule appears not to exist. Grep tools vary in whether a missing path warns at all, so
the signal cannot be relied on.

**Suggested fix:** State in Step 2 that the target path is
`skills/<name-without-wk->/SKILL.md`, and require any zero-match coverage grep to be
treated as **unverified until the target path is confirmed to exist** — the same
"`No such file` warning is a scan failure, not clean" rule the Step 5 staged-path scan
already carries, generalized to every grep whose emptiness is load-bearing. Cheapest
enforcement: glob the skill directory once up front and reuse the resolved path.
