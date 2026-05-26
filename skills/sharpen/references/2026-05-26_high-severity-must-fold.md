---
class: principle
date: 2026-05-26
source: user-request via /wk-sharpen skills/sharpen/ — audit of 47 high-severity .learned.md files (44 had no per-learning reference, 6 were unlogged, 1 had an unrecognized action). The pattern: high-severity items get renamed to .learned.md but the rule never lands in SKILL.md or the log entry is lost — the agent keeps forgetting.
---

- **Rule:** Every `severity: high` (or higher) learning MUST land in the target SKILL.md as a new rule, HARD RULE, or sub-step before the source file is renamed to `.learned.md`. One-off classification does not apply at high severity. `already-covered` requires citing specific SKILL.md line numbers that encode every rule in the learning. `.distilled-sources.log` action must be `distilled` for must-folds. Reference-file-only routing is forbidden at this severity.
- **Why:** Audit found 6 high-severity learnings unlogged and 1 with an unrecognized action — the renames happened but the coverage was unverifiable, so the original incidents will recur and the agent will re-discover the same fixes.
- **Where:** New "IMPORTANT — high-severity learnings are not optional" annotation block placed above Step 1, before any other instruction the agent reads on entry.
