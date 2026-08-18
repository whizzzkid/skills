---
skill: wk-retro
date: 2026-08-18
type: pattern
severity: low
verified-against-source: n/a
---

The compaction-recovery rule worked as designed: a session resuming from a compacted summary that already carried a drafted retro entry with two "what could've been better" bullets, one already routed to `wk-learn` and one not, correctly resumed by making only the missing `wk-learn` call rather than re-running the full retro or re-writing the retrospect log file.

**What happened:** The session summary preserved the exact retro file content and which of its two bullets had already triggered a `wk-learn` call. On resume, the agent used that summary as the source of truth, skipped re-deriving the retro, and made just the one outstanding `wk-learn` call.

**Root cause:** n/a — this is a positive confirmation of existing skill behavior, not a defect.

**Suggested fix:** No change needed; keep the compaction-recovery instruction as-is since it produced the correct minimal resume behavior.
