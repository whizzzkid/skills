---
skill: wk-testing-skeleton
date: 2026-07-28
type: gap
severity: medium
verified-against-source: yes
---

Use semantically actionable fixture content when validating an agent-consumed export.

**What happened:** A full export flow proved ZIP mechanics and evidence shape, but its generic note
did not describe a desired outcome, so the exported bundle could not support a real fix trial.

**Root cause:** The behavioral test asserted that edited text persisted without checking whether the
fixture represented the downstream consumer contract the same test claimed to exercise.

**Suggested fix:** Require end-to-end fixtures for agent-facing formats to contain a realistic
problem statement and desired outcome, then validate that the consumer can act on the result.
