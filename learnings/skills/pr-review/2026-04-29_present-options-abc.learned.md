---
skill: wk:pr-review
date: 2026-04-29
type: gap
severity: medium
---

Phase 5 should always present user-facing options as A/B/C: (A) post pending review, (B) edit one or more comments, (C) skip one or more comments.

**What happened:** The skill's "Present and wait" step in Phase 6 lists three actions in prose, but the agent improvised a different ordering and free-form phrasing ("How would you like to proceed?" with bullets). The user explicitly corrected: always offer A/B/C with "post a pending review" as option A.

**Root cause:** Phase 6's prompt template is a paragraph, not a labeled-options menu. The agent rendered it loosely and dropped the explicit "post pending review" framing in favor of a vaguer "I post the pending review (explicit confirmation)" line. Loose presentation invites user re-prompting.

**Suggested fix:** Update Phase 6's "Present and wait" template to require literal labels:

```
A) Post the pending review now (I will create it; you submit on GitHub)
B) Edit one or more comments — say which numbers and what to change
C) Skip one or more comments — say which numbers to drop

Reply A / B / C (or combine, e.g. "C: skip 2, then A").
```

The hard rule "never post on your own" stays — the user still has to pick A explicitly. The labeling just makes the choice unambiguous and prevents the agent from drifting into prose alternatives.
