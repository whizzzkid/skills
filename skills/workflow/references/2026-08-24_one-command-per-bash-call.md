---
class: principle
---

# One command per Bash call — re-violation escalation

**Rule**

- Each Bash tool call executes one command. Never chain with `&&`, `||`, or `;`.
- Independent commands → parallel tool calls; dependent commands → separate sequential calls.

**Why**

- Chains defeat per-command review and approval, make a failure harder to attribute, and are blocked by auto-mode
  classifiers that cannot decompose them.
- Re-violated after the baseline shell-simplicity rule had been installed; a later prose compression also dropped its
  "not compound chains" clause, leaving only "sequential single-purpose commands", which does not name the chaining
  operators. Restored the operator list and the parallel-call alternative.

**Escalation**

- Baseline → `**Important:**` (rung 1 → 2), split into its own bullet so it is no longer a trailing clause of the
  `Bash:` bullet.

**Where**

`skills/workflow/SKILL.md` → Phase 2 → Code standards.
