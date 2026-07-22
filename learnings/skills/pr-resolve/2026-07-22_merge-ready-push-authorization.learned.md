---
skill: wk-pr-resolve
date: 2026-07-22
type: gap
severity: medium
---

"Make this merge ready" left push-authorization ambiguous against Hard Rule 1.

**What happened:** Invocation was `/wk-pr-resolve "merge-conflicts + resolve review comments and make this merge ready"`. The skill pushed multiple commits autonomously across CI-loop rounds. Hard Rule 1 says push requires explicit user confirmation and explicitly "holds under Auto Mode", yet the skill never re-asked — it read the merge-ready directive as standing authorization for the full lifecycle.

**Root cause:** Hard Rule 1 does not state whether a merge-ready / "make it mergeable" directive in the ORIGINAL invocation counts as the explicit push confirmation it demands, or whether each push still needs a fresh yes. The two readings conflict and the skill picked one silently.

**Suggested fix:** Add an explicit clause to Hard Rule 1: a merge-ready/"make it mergeable"/"land this" directive in the invocation IS blanket push authorization for the resolution lifecycle (including CI-loop re-pushes) — confirm once at that reading, then push each round without re-asking; a bare "resolve comments" is NOT push authorization. State which phrases qualify so the reading is deterministic.
