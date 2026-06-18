---
skill: wk-retro
date: 2026-06-18
type: gap
severity: high
---

Step 4 `wk-learn` calls silently dropped when context compaction interrupts the retro response.

**What happened:** The retro entry was written and the session was summarized by compaction before the Step 4 `wk-learn` invocations could execute. The HARD RULE requires invoking `wk-learn <skill>` for each skill-gap bullet in the same retro response — but compaction truncated that response, so the calls never ran. They had to be recovered from the compaction summary in the next session.

**Root cause:** Step 4's "same response" contract is fragile when retro runs near a context limit. The skill has no fallback instruction for recognizing that wk-learn calls were deferred by compaction and must be completed on resume.

**Suggested fix:** Add a Step 4 recovery note: if the session is resumed from a compaction summary that mentions an in-progress retro, the first action is to check whether the wk-learn calls for each "What could've been better" bullet have already been made. If not, make them before any other work. The compaction summary reliably contains the retro entry content — use it as the source of truth for which skills still need a wk-learn call.
