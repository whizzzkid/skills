---
skill: wk-adversarial-review
date: 2026-07-30
type: correction
severity: high
verified-against-source: yes
---

An explicit project or session opt-out for an automated review tool is a final waiver and outranks
the tool-presence probe.

**What happened:** The user had already instructed the agent not to run an optional automated
review tool in the repository. The agent later treated the adversarial-review probe as mandatory,
ran the tool anyway, and repeated a previously corrected mistake.

**Root cause:** The skill checks whether a second-opinion tool is installed before it checks for an
explicit user waiver. This reverses the authority order and makes tool availability override the
user's stated project boundary.

**Suggested fix:** Resolve user opt-outs before probing or dispatching automated review tools. Once
the user waives a tool for a project or session, record that waiver in the active review context,
skip the tool without re-litigating it, and complete the merge gate using the remaining focused
review and required CI evidence.
