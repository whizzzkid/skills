---
skill: wk-workflow
date: 2026-08-05
type: gap
severity: medium
verified-against-source: yes
---

Capture user corrections in the response where they occur.

**What happened:** Multiple planning redirects were first converted into actionable skill learnings during the end-of-session retrospective.

**Root cause:** The workflow's live-capture requirement was not invoked when the corrections arrived, so the retrospective had to reconstruct them from conversation history.

**Suggested fix:** Treat every user correction or scope redirect as an immediate wk-learn trigger before continuing the task.
