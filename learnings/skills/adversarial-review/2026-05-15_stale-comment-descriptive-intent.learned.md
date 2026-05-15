---
skill: wk-adversarial-review
date: 2026-05-15
type: gap
severity: medium
---

Comment-accuracy sweep misses descriptive intent phrases

**What happened:** Sweep 2.4 grepped for assertive behavioral claims (`always`, `guaranteed`, `never`, `cannot`), but a comment saying "treat that as an empty set" — describing the *intent* of the error path rather than asserting a runtime property — was not caught. The subagent found it: the function actually returns an error, so callers take the error path before seeing the "empty set."

**Root cause:** The 2.4 keyword list targets declarative claim language. Descriptive intent phrases ("treat X as Y", "interpret X as Y", "use X to match Y") are a parallel class that survives refactors when the described behavior is removed.

**Suggested fix:** Extend sweep 2.4 to also grep for intent-describing phrases in changed comments: `treat .* as`, `interpret .* as`, `use .* to match`, `equivalent to`, `mirrors`. Flag any hit where the described behavior no longer appears in the same function body.
