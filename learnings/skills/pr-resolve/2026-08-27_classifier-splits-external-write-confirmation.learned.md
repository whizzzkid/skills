---
skill: wk-pr-resolve
date: 2026-08-27
type: gap
severity: medium
verified-against-source: no
---

A single blanket "yes" to a combined push+reply+resolve plan does not clear the reply-post and thread-resolve steps; the auto-mode classifier denies each external-write class separately.

**What happened:** Presented one plan ("push the commits, reply to the 8 threads, resolve them, re-run CI"), the user answered "yes", and the push proceeded. But posting the threaded replies was denied by the auto-mode classifier ("the yes covered push, not reply-posting"), and after that cleared, resolving the threads was denied again ("the yes covered push and replies, not resolution"). Three separate "yes" answers were needed for what was pitched as one confirmation.

**Root cause:** (unverified -- inferred from symptom) The classifier scopes consent per external-write action class (git push vs. POST comment vs. GraphQL resolve) and does not treat an umbrella "yes" to a multi-step plan as consent to each downstream class. The skill's land-intent authorization model assumes one confirmation flows through push -> reply -> resolve, which the classifier does not honor.

**Suggested fix:** In the confirm/push steps, warn that when replies and thread-resolution are batched behind one "yes", the auto-mode classifier will likely re-prompt per action class; either request an explicit per-action "yes" up front (list push, reply, resolve as distinct confirmations) or expect and narrate the sequential re-asks so they do not read as an error. Do not re-pitch the whole plan on each denial -- ask only the narrow blocked action.
