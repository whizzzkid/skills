---
skill: wk-workflow
date: 2026-05-21
type: gap
severity: medium
---

When adding a coercion (.to_s, .to_i, &.to_s, etc.) to one constructor argument or field, audit all arguments of the same semantic class in the same pass.

**What happened:** Two constructor args (`pr_number`, `build_number`) received `&.to_s` coercions, but `commit_sha` — same semantic class (external ID, nullable) — was missed. The adversarial review caught it before push.

**Root cause:** The fix was applied to the immediately visible cases without asking "are there other arguments that should receive the same treatment?"

**Suggested fix:** When coercing one argument in a constructor or method call, grep the surrounding parameter list for any argument with a similar name pattern or semantic purpose (IDs, counts, nullable externals). Update all in the same commit.
