---
skill: wk:workflow
date: 2026-04-29
type: correction
severity: high
---

After commit + push, agent stopped without invoking wk:pr.

**What happened:** Agent committed and pushed a one-line test fix, then ended the turn. User had to prompt "did not create a PR?" Phase 5 of wk:workflow explicitly says "After code review passes, invoke `wk:pr` automatically. Do not ask for permission." Agent treated the small task as not warranting a PR, then on follow-up still asked permission instead of just opening it.

**Root cause:** Two violations chained:
1. Agent rationalized that a tiny single-commit fix didn't need the full PR phase ("this is small" — explicit red flag in using-superpowers).
2. When user pushed back, agent asked "Want me to open one?" instead of executing — Autonomy Rules table says "Tests pass, review clean → Invoke `wk:pr` / Do NOT ask 'would you like a PR?'"

**Suggested fix:** Strengthen Phase 5's mandatory framing — every push to a branch without an existing open PR triggers `wk:pr`, regardless of diff size. No "small fix" exemption. The autonomy table already covers this; consider making it the very first rule in Phase 5 (before describing what wk:pr does), so it's impossible to read past.
