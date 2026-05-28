---
class: principle
date: 2026-05-28
source:
  - learnings/skills/adversarial-review/2026-05-28_integration-test-plumbing-gap.md
severity: medium
---

- **Rule** — when a script/entrypoint adds a new key→parameter forward, require an integration test that sets the key in a fixture and asserts the downstream behavior fires.
- **Why** — unit tests on the source (serialization) and sink (function behavior) do not cover the wire itself (the key lookup + forward), which is the new code; a bot surfaced the gap.
- **Where** — new sweep 2.22 (Pass-through wiring integration test) in wk-adversarial-review Step 2.
