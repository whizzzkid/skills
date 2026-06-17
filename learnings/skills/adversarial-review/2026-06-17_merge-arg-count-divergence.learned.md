---
skill: wk-adversarial-review
date: 2026-06-17
type: pattern
severity: medium
---

Take the more-args function call when resolving a merge conflict on a call site.

**What happened:** A branch added a function call with N args; main added a required (N+1)th arg to the same call site. The merge produced an add/add conflict. Both sides compiled independently but only the main version was correct.

**Root cause:** The branch was cut before the function signature changed. The conflict looked like "which caller wins" but was actually "which signature is authoritative." The base-branch signature is always authoritative for required args — the branch version is stale by definition.

**Suggested fix:** When an adversarial review sees a conflict on a function call site, check both sides' arg counts against the current function signature in main. If one side is missing a required arg, that side is always wrong regardless of which branch "owns" the call site. Flag it as a correctness defect, not a style preference.
