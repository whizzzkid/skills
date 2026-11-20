---
skill: wk-workflow
date: 2026-11-20
type: correction
severity: high
verified-against-source: yes
---

Reproduce a race against the unfixed code before implementing its fix.

**What happened:** A ticket described a client-side race (a stale async response stealing focus from a newer one).
The fix was implemented, committed and pushed first; the browser reproduction ran only at verification. The negative
control (guard removed) stayed green: the framework's navigator aborts the in-flight form submission when a new one
starts, so the stale response never renders and the race cannot occur as described.

**Root cause:** The plan ordered "implement → verify" for a bug whose premise was never confirmed. Read in the
framework source: the form-submit path calls stop() on the previous submission before starting the next.

**Suggested fix:** In Phase 1/3, for any race/ordering bug, the first step is a reproduction harness run against
unfixed code. It must go red, or the premise is refuted and the user is asked before any edit. Also, a manual-test
env override (auth flags) injected into a shared container leaks into test-env spec runs; unset those vars for specs.
