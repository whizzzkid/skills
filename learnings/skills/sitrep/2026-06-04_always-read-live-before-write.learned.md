---
skill: wk-sitrep
date: 2026-06-04
type: correction
severity: high
---

Always re-read live.md immediately before any write or edit, not just at session start.

**What happened:** During `start`, live.md was read at session bootstrap, then 5 parallel agents ran (~3 min). Stage 4 used `Write` to overwrite the file without re-reading it first. Any edits the user made in SilverBullet during the agent run window would have been silently clobbered.

**Root cause:** The skill spec says "Read `$LIVE_FILE` if it exists" in Stage 1 (carry-over extraction), but does not require a fresh re-read immediately before Stage 4 writes. The gap between Stage 1 and Stage 4 can be several minutes while agents run — long enough for the user to edit the file in the browser.

**Suggested fix:** Add a mandatory re-read step at the start of Stage 4 (and Stage 5 in `end`), immediately before any `Write` or `Edit` call on live.md:
- Re-read `$LIVE_FILE` to capture any changes made since Stage 1.
- Preserve all `[x]` checked lines from the current file; never overwrite checked items with unchecked ones.
- Merge: carry any newly-checked items into the "already done" set rather than re-surfacing them as open.
- Use `Edit` (targeted insertion/replacement) rather than `Write` (full overwrite) wherever possible, as `Edit` requires a read and operates on known anchors — it fails loudly if the file changed rather than silently overwriting.
