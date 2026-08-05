---
skill: wk-workflow
date: 2026-08-05
type: correction
severity: medium
verified-against-source: yes
---

Learning capture must happen in the response that surfaces the lesson.

**What happened:** A user redirection and a self-caught API race were first routed to `wk-learn` during retrospective closeout instead of immediately when they occurred.

**Root cause:** The workflow treated post-completion learning as one batched closeout step despite its live-capture rule.

**Suggested fix:** Invoke `wk-learn` in the same response as each correction, redirection, or self-caught error, then resume the active task; keep the retrospective for deduplication and promotion.
