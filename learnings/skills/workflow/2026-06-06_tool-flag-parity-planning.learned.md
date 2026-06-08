---
skill: wk-workflow
date: 2026-06-06
type: gap
severity: medium
---

Tool replacement in planning phase should include a flag-parity probe.

**What happened:** Replacing a formatting tool (gofmt → goimports) produced a working implementation that required an additional flag (`-local <module>`) for behavioral equivalence — without it, import grouping differed between local and CI invocations. The adversarial review caught this, but it should have been a planning-phase checklist item.

**Root cause:** The planning phase has no step that asks "does the replacement tool require flags to match the replaced tool's behavior?" for tool-swap tasks.

**Suggested fix:** When the plan involves swapping one tool for another with the same role, add a planning step: "verify the replacement tool's default behavior matches the replaced tool's, and identify any flags needed to close the gap." This is especially important for tools that have CWD-sensitive or module-aware behavior.
