---
skill: wk-workstyle
date: 2026-11-20
type: practice
severity: low
verified-against-source: n/a
source: learnings/retrospect/2026-11-20_session-6 (What worked)
---

Settle a formatter-vs-convention conflict with the convention's own formatter, run on scratch copies.

**What happened:** The project formatter's output conflicted with the style the repo's code follows. Running the
convention's own formatter on scratch copies of the files gave the expected output directly, with no hand-guessing and
no churn in the working tree.

**Suggested fix:** When the configured formatter and the repo convention disagree, use the convention's formatter on
scratch copies as the oracle.
