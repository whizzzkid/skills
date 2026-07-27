---
skill: wk-sharpen
class: principle
---

**Rule** — In batch mode, re-list the inbox immediately *before* folding each item, not
only at scan-open and after each fold-commit. An item that has vanished since the opening
listing proves a concurrent writer whatever the timestamps say → unclaimed backlog.

**Why** — The processed-state marker *is* a rename, and `mv` preserves mtime while
advancing only ctime. A peer's claim therefore leaves the claimed file with exactly the
mtime an unclaimed file would have, so the prescribed ownership test is structurally blind
to the claim direction. Commit recency does not compensate: a peer mid-fold is uncommitted
by definition, so a cold log is the *expected* reading during precisely the window when
collision risk is highest. Both prescribed signals fail the same way, so their agreement
carries no information and must never be read as corroboration.

**Verified** — Reproduced directly rather than inferred: created a file, recorded
`mtime`/`ctime`, renamed it, re-stat'd. mtime unchanged, ctime advanced by the elapsed
interval. The parent directory's mtime *does* advance on the rename, but that signal is
per-directory, not per-item, so it cannot attribute a claim to a specific file.

**Rejected suggestion** — The report proposed comparing each item's **ctime** against the
run's start as the primary corroborating signal. Not adopted: a claim renames the file to
`*.learned.md`, which removes it from the unprocessed listing entirely, so the re-list
already detects every completed claim that a ctime comparison would. ctime adds a second
reading of the same event while still failing to detect the case that actually matters —
a peer mid-fold that has not yet renamed or committed anything. The re-list is the
load-bearing fix; ctime was dropped as redundant rather than folded as a second gate.

**Where** — wk-sharpen batch mode, Source 2 ownership and re-scan rules.
