---
skill: wk-pr-resolve
date: 2026-06-19
type: correction
severity: high
---

Judgment-required items presented as a batch again despite an already-distilled rule prohibiting it.

**What happened:** Three judgment-required findings (test-coverage gaps × 2, code duplication) were presented together in one message, allowing the user to respond with a single batch string (`a a d`). The user had to ask retroactively why decisions were not taken one-by-one.

**Root cause:** The one-at-a-time rule was rationalized away — the three items appeared in a pr-resolve flow that had already classified them, and batching felt like a natural summary step. The existing distilled learning names this exact trap but it recurred anyway.

**Suggested fix:** Add a pre-emit gate at the top of Step 5 output: count `Comment {n}` headers in the drafted message; if count > 1, hard-stop and split before sending. The check must fire even when items feel similar or the flow is already in a "listing" mode. Recurrence of a distilled learning is a signal the gate needs to be mechanical (count-based), not intention-based.
