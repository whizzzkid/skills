---
class: principle
date: 2026-07-28
severity: medium
---

# Make agent-consumed fixtures actionable

**Rule:** An end-to-end fixture for an agent-facing export or interchange
format must include a realistic problem statement and desired outcome. Validate
that the downstream consumer can act on the exported result.

**Why:** Archive creation, schema shape, and persisted text prove transport
mechanics. Generic content can satisfy all three while failing the semantic
contract that makes the export useful.

**Where:** Tests claiming to exercise a bundle, note, prompt, report, or other
artifact intended for an agent or automated consumer.
