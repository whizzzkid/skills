---
class: principle
---

# A reachability gap is decidable differentially, not by classifying references

**Rule** — Detect an orphaned relocation by comparing a `SKILL.md` against its own
previous version: a `references/…md` pointer `HEAD` carried must still be carried, by
some tracked file under the skill dir, unless the reference is deleted in the same
commit. Never try to classify a reference as record-vs-curated first.

**Why** — Forward link checking cannot see this failure at all: the broken thing is the
*absence* of a link, not a link to a missing file. And the obvious fix — sweep
`references/`, flag every unlinked file — is unavailable, because per-learning
distillation records are unlinked by design. The differential form sidesteps
classification entirely and is exact.

## What the source disproved

The report inferred that at least one unlinked reference was a curated shared procedure
orphaned by a relocation, marking it `(unverified — inferred from structure)`. Driven
against the source, that inference fails twice:

- **Structure cannot discriminate.** The reference template mandates Rule / Why / Where
  for *every* `class: principle` file, so a record and a relocated procedure are
  structurally identical by construction. Every undated orphan carries `class: principle`
  and most carry no `# ` heading at all.
- **No orphan exists.** `git log -S '<basename>' -- <skill>/SKILL.md`, run per candidate
  against a live canary (a known-linked reference returns hits), shows **zero** history
  hits for every orphan: none was ever linked, so no pointer was ever dropped. They are
  records, exactly as Step 7 prescribes.

So the report's `type: gap` holds — the detector is genuinely missing, confirmed against
`check-links.sh`, which excludes `references/` in its own scope comment — but its
`class:`-widening remedy solves a problem the tree does not have. Widening `class:` would
have required classifying every existing reference and backfilling a field, to catch a
case the differential check catches with no migration at all.

**Rejected — a whole-directory reachability sweep.** Scored under this fold's shape (add
a gate, no schema change, no backfill). It reports every per-learning record as a
violation, so it can only work behind a new frontmatter role field applied to all
existing references first. Reopen only if a *role* field lands for an independent reason.

**Rejected — a Drift-check prose bullet as the sole fix.** Scored under the same shape.
The pass that relocates content is the pass that would notice the missing pointer, so the
reminder and the mistake share a failure. The prose rule already existed at Step 7.5
("write the pointer at the cut site"); the missing half was a gate, which is why this is
`partial`, not `already-covered`.

**Classification** — `partial`. The pointer-at-the-cut-site rule was already installed and
is cited above; the newly distilled part is the detector and the disproof of
classify-by-structure.

**Escalation — none.** The prose rule was never violated: zero orphans exist in the tree.
A missing detector for a rule nothing has broken is a gap, not a re-violation.

**Verification** — six cases driven against the hook, each arm's verdict checked, plus a
live repo-wide control:

| case | expectation |
| ---- | ----------- |
| nothing staged | pass (early exit) |
| `SKILL.md` staged unchanged | pass |
| pointer dropped, file kept | **blocked** |
| pointer dropped, file deleted too | pass (retirement) |
| pointer moved into a sibling reference | pass (transitive) |
| only a self-mention remains | **blocked** |

The repo-wide arm was **dead on first run** — staging unchanged files produces no diff, so
the hook early-exited and the green was vacuous. Rebuilt by appending one blank line to
every `SKILL.md` blob, making the diff real while leaving links untouched: 63 skills
staged, zero false positives.

**Where** — `SKILL.md` → Step 7 Drift check, cross-references-resolve item; gate in
`.githooks/check-reference-orphans.sh`, wired in `lefthook.yml`, documented in
`.githooks/README.md`.
