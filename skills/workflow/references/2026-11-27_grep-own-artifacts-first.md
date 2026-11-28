---
class: principle
source: learnings/skills/workflow/2026-11-27_grep-own-artifacts-first.learned.md
---

# Read the artifact before asserting it lacks something

**Rule** — Before claiming a doc or code artifact (your own included) is missing something, grep it in the same turn
and quote the proving line; otherwise state the gap as unverified.

**Why** — The agent told the user a record it had written omitted an alternative and proposed adding it; opening the
file to edit showed the alternative already named and rejected. The claim came from memory of the session summary, not
the file, and cost the user a correction. The existing *Verify mechanism before offering options* rule covers claims
about an external tool's behavior, not claims about an artifact's contents, so this is `partial`, not
`already-covered`.

**Where** — `skills/workflow/SKILL.md` → Mandatory Activation → Autonomy Rules, bullet after *Verify mechanism before
offering options*.

**Byte reclaim** — The body sat at its ceiling; the inline *Layer responsibility / Two-sided flow survey / Identifier
composition* bullet (lower-frequency code standards, no gate checks) moved verbatim to `code-standards-extended.md`,
whose pointer stays inline in Code standards.
