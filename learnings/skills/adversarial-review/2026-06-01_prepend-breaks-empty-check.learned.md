---
skill: wk-adversarial-review
date: 2026-06-01
type: gap
severity: high
---

Seeding a body array with a non-empty value before an empty-body collapse check silently breaks the compact form.

**What happened:** The implementation prepended `summary_line` to `body` before the `body.all? { |l| l.strip.empty? }` guard that collapses to a compact "no issues" form. The adversarial subagent caught it as a blocker; the initial implementation missed it.

**Root cause:** The implementation focused on the happy path (summary_line shown when content is present) and did not trace the code path where all findings post inline — in that path, `body` would contain only `summary_line`, the guard would evaluate false, and the full template would render with just one sentence and no findings. The adversarial subagent was prompted to trace this exact path.

**Suggested fix:** When reviewing code that prepends/seeds a collection before a downstream empty-check, explicitly verify whether the seed value itself could cause the check to fail in cases where the intent was "nothing substantive to show." The pattern is: decide the gate on substantive content only, then prepend decorative content after the gate.
