---
skill: wk-workflow
date: 2026-06-02
type: gap
severity: medium
---

Phase 1 should enumerate authoring-guide docs that list rules by count when a check/rule file is being modified.

**What happened:** A check skill file update added a new content-quality rule (4th item). An authoring guide doc in the same repo had a "three things" bullet list enumerating the rules. The plan did not include syncing the authoring guide; the gap was caught by the adversarial sweep instead.

**Root cause:** Phase 1 cross-doc enumeration planning only looked at spec/plan docs. Authoring guides that enumerate rules by count ("X things you must include") were not in scope for the planning pass.

**Suggested fix:** Add a Phase 1 probe: when the diff modifies a check/validator/rule file, grep for authoring guides (README, docs/repository-checks, docs/how-to) that enumerate the rule set by count ("N things", "three items") and add those docs as explicit sync targets in the plan, before implementation starts.
