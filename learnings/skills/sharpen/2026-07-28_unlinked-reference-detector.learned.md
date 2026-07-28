---
skill: wk-sharpen
date: 2026-07-28
type: gap
severity: medium
verified-against-source: yes
---

Nothing detects a `references/` file that no `SKILL.md` links, and filename shape cannot
tell a curated shared procedure from a legacy per-learning record.

**What happened:** The run landed a rule making an `already-covered` verdict read the
skill body *plus every linked reference*, with an unlinked per-learning record explicitly
proving nothing at runtime. Auditing the reference dir afterwards, 23 of the undated
reference files are linked from nowhere. Most are per-learning distillation records
written before the dated-filename convention — correctly unlinked. But at least one reads
as a curated shared procedure (Rule / Why / Where structure, no single-incident framing)
and is still unlinked, so its content is unreachable at runtime by the very test the run
just installed.

**Root cause:** Two compounding gaps, both confirmed against the source.

- The dated-filename convention (`YYYY-MM-DD_slug.md`) is the only signal separating a
  per-learning record from a curated procedure reference, and it only covers files written
  after it was adopted. Enumerating undated files therefore mixes both classes, so a run
  auditing reachability cannot classify by filename.
- The link hook checks only the forward direction — every link resolves to a file. Driving
  it over the current tree passes while 23 references are linked from nowhere, so no gate
  sees an orphaned relocation. The reverse check (every curated reference is linked from
  some `SKILL.md`) does not exist.

Whether any specific orphan is a *relocated* block rather than a legacy record is
`(unverified — inferred from structure)`; only reading each candidate against the skill
body settles it.

**Suggested fix:** Give the Drift check a reachability item: enumerate `references/`,
subtract the set `SKILL.md` links, and require every survivor to be classifiable as a
per-learning record. Class must come from the file's own frontmatter, not its filename —
the `class:` field already exists in the reference template, so widen it to distinguish
a distillation record from a curated shared procedure and key the audit on that. Prefer
a hook over a prose bullet, since the relocation that orphans a reference and the pass
that would notice are the same pass.
