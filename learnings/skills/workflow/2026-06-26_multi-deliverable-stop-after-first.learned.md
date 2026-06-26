---
skill: wk-workflow
date: 2026-06-26
type: correction
severity: high
---

Stopped after first deliverable when prompt contained two work items.

**What happened:** A message opened with a noun task ("create a bug ticket") and closed with an imperative ("also make a fix for this"). The agent completed the ticket creation and stopped, requiring the user to explicitly prompt: "why did you stop at ticket creation?"

**Root cause:** The Continuity Rules in wk-workflow already cover this case verbatim: "A message opening with a noun task and closing with an imperative is two work items — commit to the full list before executing the first." The agent failed to apply the rule before starting.

**Suggested fix:** Before executing the first deliverable in a multi-sentence prompt, explicitly enumerate every deliverable in the prompt and commit to the full list. Treat any closing imperative as a second deliverable, not elaboration.
