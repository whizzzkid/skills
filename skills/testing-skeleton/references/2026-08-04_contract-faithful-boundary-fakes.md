---
class: principle
---

# Enforce external API contracts in boundary fakes

**Rule:** Pair prerequisite configuration or permission assertions with an adapter test whose fake rejects unsupported
arguments and reproduces the documented return and async-completion shape.

**Why:** A prerequisite can be correct while the adapter still invokes the external API with an obsolete signature.

**Where:** Tests for adapters that call permission-, configuration-, or capability-gated external APIs.
