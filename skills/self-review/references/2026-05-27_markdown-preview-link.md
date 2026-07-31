---
class: principle
date: 2026-05-27
severity: medium
---

- **Rule:** When a changed file is `.md` and the diff adds >50 lines, stage an
  inline comment on the first in-hunk line with a clickable markdown preview.
  Format the path as the code-span label and leave the URL outside backticks.
- **Why:** Reviewers read raw diffs by default; large markdown changes are hard to parse without the rendered view.
- **Where:** New sub-section in Step 2 ("Markdown preview link for large diffs"), uses Step 3.5 line-validation.
- **Escalation:** A code-wrapped URL copied from the original template shipped
  inert. The rule advanced from baseline prose to `Important` and gained a
  final-payload rejection check.
