---
skill: wk-self-review
date: 2026-05-26
type: correction
severity: high
---

Post the pending self-review immediately; never ask whether to post it.

**What happened:** Agent asked "Want me to post this?" before posting, requiring an extra user round-trip.

**Root cause:** Agent treated posting as optional and gated it behind user confirmation.

**Suggested fix:** wk-self-review Step 4 posts the pending review unconditionally after Step 3 proposes comments. The user reviews and submits (or edits/dismisses) in the GitHub UI. No confirmation prompt before posting.
