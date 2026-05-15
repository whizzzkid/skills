---
skill: wk-pr-resolve
date: 2026-05-15
type: gap
severity: high
---

Step 5 judgment-required comments were batched into a single message instead of presented one at a time.
User had to correct this explicitly: "why did you not ask for my judgement on these one-by-one?"

**What happened:** Two judgment-required findings (`runValidate` test coverage, `coreCheckNames` duplication)
were summarized together with their options in a single message. The skill hard-rules one comment per message —
"Emit exactly one `Comment {n}/{total}` block per message, then stop and wait for the reply" — but the constraint
was dropped because the items looked similar and batching seemed efficient.

**Root cause:** The "One comment per message" hard rule has a known rationalization trap: "they're all the same
category / to save round-trips." The skill names this trap explicitly but the reviewer still fell into it.

**Suggested fix:** Before emitting ANY Step 5 output, mentally confirm: "Am I about to put two `Comment {n}`
headers in one message?" If yes, stop and split. Auto mode does not suspend this rule — it only removes
permission-asking for low-risk work, not the one-at-a-time consultation structure.
