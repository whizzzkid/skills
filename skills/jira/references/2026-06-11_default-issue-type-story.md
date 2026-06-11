---
class: principle
---

- **Rule** — Default `issueTypeName` to `"Story"` when creating a Jira issue;
  pick another type only when the context names one (`Bug`, `Task`, `Epic`).
- **Why** — With no stated default the agent fell back to `"Task"`, which the
  user corrected; an unstated default produces the wrong type on every create.
- **Where** — Manual ticket operations (confirm-first) section, under the
  write HARD RULE.
