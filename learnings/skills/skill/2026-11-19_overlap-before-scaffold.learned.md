---
skill: wk-skill
date: 2026-11-19
type: gap
severity: low
verified-against-source: yes
---

The collision guard only catches an exact directory-name match. It misses an existing skill that already does most of the requested job.

**What happened:** The user requested a new skill to batch dependency-upgrade PRs. Steps 1–2 reported `CLEAR` because no
directory had that name. An existing skill already covered most of the behavior, and that only surfaced from a manual
`ls`. The user chose to extend the existing skill rather than add a duplicate.

**Root cause:** Step 2's collision check is `test -d skills/<name>`. That is a name match, not a capability match.

**Suggested fix:** Add a sub-step after Step 2: grep the descriptions in `skills/*/SKILL.md` for the request's key nouns.
On a substantial overlap, ask whether to extend that skill (via `wk-sharpen`) or create a new one before scaffolding.
Also draft example PR or issue numbers as `#NNN` placeholders, because the `check-pr-numbers` hook rejects literal
numbers in markdown.
