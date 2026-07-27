---
skill: wk-grep
date: 2026-07-27
type: surprise
severity: medium
verified-against-source: yes
---

`grep -s` over a missing path exits 2 on BSD and 1 on GNU, so an exit-status gate passes or fails by machine.

**What happened:** A verification block in a doc gated on `grep -s <pattern> <path>`'s exit status
to mean "pattern absent". On the BSD grep shipped with macOS, a nonexistent path exits 2; GNU grep
exits 1 — the same status as "found nothing". A gate written on one platform silently inverts on
the other, and a missing file reads as a clean pass on GNU.

**Root cause:** `-s` suppresses the error *message* for a missing or unreadable file, not the
distinct exit status, and the two implementations disagree on what that status is. Confirmed by
running it on the target platform rather than inferred.

**Suggested fix:** Never gate on `grep`'s exit status alone when the target path may not exist.
Either test for the file first (`[[ -f "$f" ]] || { echo "FAIL: missing $f"; exit 1; }`) and then
grep, or judge the check on its *output* (`[[ -z "$(grep ... )" ]]`) rather than its status.
Reserve exit-status gates for greps over paths already proven present.
