---
class: principle
---

- **Rule**: Config-schema additions (new YAML field, new env var, new JSON output field, new CLI flag) MUST land with a `docs/specs/` entry in the same or immediately following commit — never deferred.
- **Why**: Multi-commit features routinely shipped without doc updates; the user had to redirect with "document these changes and update the spec too." Config schema is a public surface — docs/specs is part of "feature complete," not follow-up.
- **Where**: wk-workflow Phase 2 commit-boundary checklist (`wk-docs` invocation bullet).
