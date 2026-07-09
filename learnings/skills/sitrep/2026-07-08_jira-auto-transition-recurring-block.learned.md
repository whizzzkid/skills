---
skill: wk-sitrep
date: 2026-07-08
type: gap
severity: medium
---

Jira auto-transition (Stage 2b) is consistently denied by the harness's external-write permission classifier, not a one-off — this is now the second consecutive run where the exact same ticket hit the exact same denial.

**What happened:** Stage 2b attempted `transitionJiraIssue` for a ticket whose linked PR had merged. The harness's auto-mode classifier denied the write as an "unrequested modification of an external system item the agent didn't create this session," with no path to pre-authorize it. This is the same ticket, same failure, as the prior run's Stage 2b attempt.

**Root cause:** The skill's auto-transition step assumes a one-shot external write will succeed or fail independently each run. In practice, the harness's write-permission classifier blocks this category of action deterministically (not stochastically) whenever a session didn't itself create/touch the target item — so retrying on a later day produces the identical denial rather than a fresh outcome.

**Suggested fix:** After a Stage 2b denial, tag the ticket with a `manual_transition_blocked` marker (e.g., in a per-ticket note or the dismissed-registry-adjacent state) so subsequent runs can render it as "🔁 blocked N consecutive days" instead of silently re-attempting the same denied write every single day. Consider skipping the re-attempt entirely once one denial is recorded for a ticket, and instead just re-verify the merge state and keep it pinned in ASAP until the user manually transitions it in Jira.
