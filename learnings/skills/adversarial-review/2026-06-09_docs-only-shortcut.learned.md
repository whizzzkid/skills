---
skill: wk-adversarial-review
date: 2026-06-09
type: correction
severity: high
---

Never short-circuit the adversarial subagent dispatch for "docs-only" diffs — skill instruction files are executable specifications and the subagent finds real logic bugs in them.

**What happened:** On a resolve-cycle push whose diff was entirely markdown files, the mechanical sweeps ran but the full adversarial subagent dispatch was skipped with the rationale "docs-only, no security surface." The next Fresh Eyes review round found two real bugs (jq null-string guard gap, unconditional guard assumption) that the subagent would have caught.

**Root cause:** The "docs-only" exemption pattern is explicitly forbidden by the skill's Hard Rules but was applied anyway under time pressure. Skill instruction files behave like code — logic errors in them produce runtime failures exactly as if they were in source.

**Suggested fix:** Add an explicit note to the skill: `.md` files that are skill instructions or executable specifications are NOT exempt from the adversarial subagent dispatch; the "docs-only" exemption applies only to changelog entries, plain prose documentation, and files with no executable logic.
