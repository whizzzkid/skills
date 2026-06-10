---
skill: wk-learn
date: 2026-06-09
type: gap
severity: medium
---

Route tool/command/CLI-specific learnings to a dedicated `wk-<tool>` skill file, not to the catch-all wk-adversarial-review or wk-workflow bucket.

**What happened:** A curl-specific quirk (-s vs -sS) was captured under wk-adversarial-review because that skill surfaced the finding. But the lesson belongs to curl, not to the review process — future sessions working with curl should load it regardless of whether an adversarial review is running.

**Root cause:** wk-learn has no guidance on when to break learnings out into a new per-tool skill vs appending to the calling skill. Tool-specific knowledge (curl flags, jq null output, gh CLI auth, bk CLI scopes) recurs across many skills and should be self-contained and auto-invocable.

**Suggested fix:** Add a routing rule to wk-learn: when a finding is specific to a named CLI tool, command, or external app (curl, jq, gh, bk, docker, git, aws, etc.) rather than to a workflow step, route it to `wk-<tool>` instead of the calling skill. The `wk-<tool>` skill should declare `model-invocable: true` so the agent auto-loads it whenever it is about to invoke that tool. A new `wk-<tool>` skill is worth creating when it would accumulate ≥2 distinct non-obvious findings for the same tool.
