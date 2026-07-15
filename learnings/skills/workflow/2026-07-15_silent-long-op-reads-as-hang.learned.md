---
skill: wk-workflow
date: 2026-07-15
type: gap
severity: low
---

A long, silent verification loop (repeated multi-minute test runs, CI waits, a hook-blocked retry cycle) reads to the user as a hang, prompting "what happened?" / "you were just hung."

**What happened:** During a PR resolve/merge run the agent re-ran a ~4-minute test suite several times to confirm a flake, and worked through a hook block, all without emitting interim status. The user twice interrupted to ask whether the process was stuck.

**Root cause:** No progress signal between long-running operations. The agent knew each run was expected and roughly how long it would take, but never surfaced that estimate, so silence was indistinguishable from a stall.

**Suggested fix:** Before any operation expected to run >~1 min (full test suite, CI poll, repeated flake-confirmation runs), state what is running and the rough expected duration; on repeated runs, say why the repeat is needed (e.g. "re-running to confirm an order-dependent flake"). Keeps the user from reading normal latency as a hang.
