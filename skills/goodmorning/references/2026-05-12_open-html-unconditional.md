**Rule:** `open "$TODAY_DIR/morning.html"` runs unconditionally after files are written — before any announcement, before any commit/push offer, and regardless of auto mode.

**Why:** In auto mode the agent treated "Would you like to commit and push?" as the terminal step and stopped there, never calling `open`; the user had to ask why the file was not opened.

**Where:** `### Open for review` (Stage 2, after 2c)
