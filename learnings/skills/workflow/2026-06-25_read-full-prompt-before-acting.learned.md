---
skill: wk-workflow
date: 2026-06-25
type: correction
severity: high
---

Read the entire prompt before deciding which steps to perform.

**What happened:** A prompt asked to both create a ticket AND fix code ("Fix this for all the hidden comment types"). Only the ticket-creation portion was executed. The implementation directive at the end of the prompt was missed, requiring the user to repeat the request with frustration.

**Root cause:** The agent parsed the first deliverable (create ticket) and stopped without reading to the end. A multi-sentence prompt with a trailing imperative ("Fix this") was treated as complete after the first noun phrase.

**Suggested fix:** Before starting any task, read the full prompt to the end and enumerate every deliverable. A prompt that begins with a noun task ("create a ticket") and ends with an imperative verb ("fix this") contains two work items. Never commit to executing only the first deliverable until the full list is known.
