---
skill: wk-pr-resolve
date: 2025-06-24
type: correction
severity: high
---

Never open GitHub reply comments with praise ("Good catch!", "Great point!", etc.)

**What happened:** A reply to a reviewer's comment opened with "Good catch!" — a sycophantic opener explicitly forbidden by wk-tone.

**Root cause:** The skill constructs reply bodies without routing through wk-tone discipline. The agent drafted the reply inline rather than applying tone rules, treating "it's just a review reply" as exempt.

**Suggested fix:** Add a hard gate in the reply-drafting step: every reply body must lead with the substance (what changed, what the decision was, the commit SHA) — never a pleasantry, praise, or acknowledgement opener. The wk-tone prohibition on "Good catch!" / "Great point!" / "Thanks!" applies unconditionally to all GitHub-visible text, including short review thread replies.
