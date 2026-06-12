---
skill: wk-workflow
date: 2026-06-12
type: surprise
severity: medium
---

Inner `Open3.capture3` stderr is not forwarded to outer process stderr on success

**What happened:** A fake subprocess was designed to log its received args to stderr so tests could assert on them. The outer script captured the inner process via `Open3.capture3`, which stored the inner stderr in a local variable. On success the outer script never forwarded that variable to its own stderr, so tests asserting on the outer process's stderr for inner-process diagnostic output always received empty.

**Root cause:** `Open3.capture3` captures stdout, stderr, and status independently. The captured stderr is only emitted to the outer process's stderr when the outer script explicitly writes it (e.g., via `warn` or `$stderr.write`). A happy-path exit never does this — the captured stderr is discarded. Tests that captured the outer process's stderr expected to see the inner process's diagnostic output but found nothing.

**Suggested fix:** When writing tests for multi-subprocess scripts, assert on output the outer script emits itself (its own `puts`/`warn` lines) rather than on subprocess stderr. If inner-process arg verification is needed, use a side-channel (a temp file the fake process writes to, a shared env var, or a structured output line the fake echoes to its stdout for the outer script to forward).
