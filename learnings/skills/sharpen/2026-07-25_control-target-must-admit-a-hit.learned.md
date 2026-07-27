---
skill: wk-sharpen
date: 2026-07-25
type: gap
severity: high
verified-against-source: yes
---

A positive control run against a structurally-unhittable target is dead, and its zero reads exactly like a confirmed drain.

**What happened:** A prior run's readability control for the global learnings inbox
returned zero and was read as "source drained". The scan was rooted at the installed-skills
directory, whose entries are symlinks to the real skill store. `find -type f` does not
descend into symlinked directories, so the probe returned zero regardless of content. The
control shared the scan's blind spot, so it could not have moved off zero for any input —
it confirmed nothing while reading as confirmation.

**Root cause:** The control was chosen for topical proximity (same tree, same file type)
rather than for structure. Verified against the source this run: `find <skills-root>
-mindepth 2 -type f` returns `0` while `find -L` over the identical root returns `940`, with
64 symlinked entries at depth 1. A control only carries evidence when the target can
actually produce a hit under the exact invocation form being validated.

**Suggested fix:** Require the control target be chosen so a hit is structurally reachable
by the scan's own invocation form, and require the re-proof to use a mechanism that does not
share the scan's blind spot. Concretely: plant an in-place canary inside the scanned tree and
re-run the identical form, and corroborate with a traversal that resolves what the scan
skips (`ls -laR`, `find -L`). A control that returns zero on a known-present input is dead
and indicts the control, never the source.
