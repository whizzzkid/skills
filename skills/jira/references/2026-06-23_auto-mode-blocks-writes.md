---
class: principle
skill: wk-jira
date: 2026-06-23
---

**Rule**

A Jira lifecycle write fired as a dev-work side-effect can be blocked by the
auto-mode / permission classifier (a referenced ticket = context, not
write-authorization). On a permission denial, surface the block once and ask the
user to confirm intent or add a Jira-write permission rule — never silently retry
or spin on repeated denials, and never silently swallow the block.

**Why**

Auto mode treats Jira writes as external-system writes needing explicit intent,
which conflicts with the skill's "development intent = auto" claim assumption.
Silent retries waste turns; silent swallowing leaves the ticket unmoved with no
explanation.

**Where**

Stage 2 (claim) as a HARD RULE after the atomic-claim/self-healing bullets, plus
a Conflict-handling table row.
