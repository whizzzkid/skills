---
skill: wk-pr-update
date: 2026-11-26
type: correction
severity: low
verified-against-source: n/a
---

"Make sure nothing broke after the conflict resolution" means verify behavior, not regenerate artifacts.

**What happened:** After resolving a conflict that only touched lines already present on both sides, the user asked to
confirm the screenshots were still valid and nothing broke. The agent began a capture script that overwrote the PR's
verified screenshots. The user interrupted: only verification was wanted. Because the interrupted run may have
partially overwritten files, they had to be restored from a backup.

**Root cause:** A recent "always re-shoot after a fix" learning was over-applied. A conflict resolution that keeps one
side's lines verbatim is not a visual fix, so the right check is measured behavior against the prior run (sizes,
computed styles, state transitions, console errors), not new captures.

**Suggested fix:** In Stage 5 (re-validate), when the merged net diff matches the pre-merge branch diff, run a
read-only behavior check that asserts the same measured properties as the last capture run. Regenerate screenshots
only if a measured value changed. Before any capture that overwrites existing evidence, back the files up first.
