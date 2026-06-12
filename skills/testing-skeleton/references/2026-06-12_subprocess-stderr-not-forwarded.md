---
class: one-off
date: 2026-06-12
---

- **Scenario:** Testing a script that wraps an inner subprocess (e.g. Ruby
  `Open3.capture3`) and asserting on diagnostic output the inner process writes
  to stderr.
- **Symptom:** The assertion on the outer process's stderr is always empty.
  `Open3.capture3` captures inner stdout/stderr/status into local variables; on
  a happy-path exit the outer script never writes the captured stderr back to
  its own stderr, so it is silently discarded.
- **Fix:** Assert on output the outer script emits itself (`puts`/`warn`),
  not on swallowed inner-process stderr. For inner-arg verification use a
  side-channel: a temp file the fake process writes, a shared env var, or a
  structured stdout line the fake echoes for the outer script to forward.
- **Why not promoted:** Narrow to multi-subprocess script testing; the general
  principle ("assert on the boundary you actually observe") is already covered
  by behavioral-assertion rules in wk-workstyle-testing.
