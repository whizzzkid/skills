---
class: principle
---

**Rule:** A specialized second-opinion tool's finding in its own domain
(error-handling, type-precision, test-coverage) stands even when the general
adversarial subagent cleared the same code. The two are complementary, not
redundant — never dismiss a specialized finding as a false positive on the
grounds that the general review passed.

**Why:** LLM subagents reason about logic and correctness semantically but miss
low-level distinctions (e.g. error-type precision in a typed language).
Specialized checks run prompts calibrated for those exact concern classes and
catch gaps the general pass cannot.

**Where:** Step 2 sweep catalog, row 2.0 (second-opinion fold) — fix column.
