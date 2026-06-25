---
skill: wk-adversarial-review
date: 2026-06-25
type: pattern
severity: low
---

Bot "blocking" finding for missing defensive guard was a false positive when the pre-condition is structurally guaranteed.

**What happened:** A bot reviewer flagged a Major/blocking issue: a value passed to a function could theoretically be empty, silently producing a malformed compound ID. The bot recommended adding an explicit runtime guard.

**Root cause:** The value cannot be empty at that call site — the upstream function returns an error on failure (which the caller short-circuits on), and the success path always produces a non-empty value by OS-level contract. A test locks this pre-condition. The bot's analysis did not account for the structured error-return path.

**Suggested fix:** When a bot flags an empty-value risk, trace the upstream error path before treating it as a blocker. If the producer either returns an error (and the call site short-circuits) or guarantees a non-empty output on success, and a test pins the pre-condition — the finding is a false positive. Document the analysis in the dismissal reply so reviewers understand why the guard is absent.
