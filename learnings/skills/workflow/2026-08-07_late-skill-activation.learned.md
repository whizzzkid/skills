---
skill: wk-workflow
date: 2026-08-07
type: correction
severity: low
verified-against-source: n/a
---

Check command-level skill triggers before the first tool invocation.

**What happened:** The agent loaded the main task skills but ran a version-manager command before loading its
tool-specific skill.

**Root cause:** Skill selection happened only at task classification time and was not repeated against the concrete
commands chosen during execution.

**Suggested fix:** Before each first use of a CLI or subsystem, compare the concrete command against available skill
triggers and load any newly applicable skill before running it.
