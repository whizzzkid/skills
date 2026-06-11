---
skill: wk-adversarial-review
date: 2026-06-11
type: correction
severity: medium
---

Adversarial subagent can falsely claim a refactor introduces a behavioral change; cross-check removed lines before acting.

**What happened:** A subagent reviewed a pure extraction refactor and flagged that a `-L` flag was "newly introduced" to a curl download call. In fact, the `-L` flag was present in the removed inline block and simply moved into the extracted helper — the behavior was identical. The subagent's finding read as a blocker-class concern but was factually wrong.

**Root cause:** The subagent processed a diff but either missed the removed lines or reasoned incorrectly about the before-state. "Before" behavior can only be assessed by reading the removed (`-`) lines in the hunk, not just the added (`+`) lines.

**Suggested fix:** When an adversarial subagent claims a refactor commit introduces a behavioral change, always cross-check the claim against the removed lines in the exact diff hunk before acting on it. If the removed lines contain the same flag/value, the claim is a false positive and can be dismissed with that finding logged.
