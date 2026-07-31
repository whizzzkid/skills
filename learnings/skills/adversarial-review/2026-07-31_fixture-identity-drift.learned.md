---
skill: wk-adversarial-review
date: 2026-07-31
type: pattern
severity: medium
verified-against-source: yes
---

Predictable test identities must flow from one typed source into static fixtures.

**What happened:** A temporary browser-extension identity was repeated in two runners and a static
fixture, making a future one-site edit capable of breaking the expected extension origin.

**Root cause:** The static fixture could not import the typed constant directly, and the runners
did not pass the value into the fixture at runtime.

**Suggested fix:** Review stable test identities across code and fixtures as one contract. Keep the
value in typed code and inject it through a local fixture URL or server substitution rather than
duplicating literals.
