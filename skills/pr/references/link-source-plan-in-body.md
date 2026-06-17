---
class: principle
---

# Link the implementation plan in the PR body, not just the vision spec

**Rule**

- Before composing the PR body, grep `docs/plans/` and `docs/specs/` for the file
  covering the branch's phase/feature.
- Link the plan (anchored to the relevant phase section) under a `## Meta` block,
  plus the spec when present. A vision/spec link is not a substitute for the plan.

**Why**

- A PR linked the high-level vision spec but omitted the `docs/plans/` plan that
  defines the phase's checkboxes, acceptance criteria, and ticket; the user had to
  point it out. Body composition pulled only from diff/commit history and never
  searched for the authoritative plan doc.

**Where**

- `skills/pr/SKILL.md` Step 2, "Link the source plan and spec (pre-flight)".
