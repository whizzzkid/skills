---
skill: wk:pr-resolve
date: 2026-04-30
type: pattern
severity: medium
---

When two or more bots independently flag the same issue, treat it as a signal that the fix was incomplete — not just that two bots ran the same check.

**What happened:** PR #NNN repeatedly saw both Copilot and {bot} flag the same finding independently (credential exposure, cross-doc inconsistency, rollout item naming). Each was resolved as a separate finding. In several cases this happened because the "fix" corrected the specific line flagged but not the underlying pattern, so the next push triggered the bots to find a sibling instance.

**Root cause:** Multi-bot convergence on the same issue in the same review cycle was treated as coincidence (two bots, same check). The signal it carries — "the prior fix was incomplete" — was not acted on.

**Suggested fix:** When two or more bots flag the same category of issue (even on slightly different lines or files) in the same review cycle:
1. Do NOT resolve them as independent findings. Merge them into one finding (per Step 4's merge rule) if they target the same concern.
2. Step back and ask: "Is this a sign that my previous fix on this topic was incomplete?"
3. Search the full PR diff for all instances of the vulnerability/inconsistency class before writing any fix.
4. Confirm the fix addresses all instances, then reply from all flagging threads simultaneously with one commit SHA.
