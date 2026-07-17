---
skill: wk-pr-review
date: 2026-07-17
type: correction
severity: medium
---

A substantive new finding gets its own line-anchored inline comment — never bury it inside a reply on an unrelated thread.

**What happened:** A simulation surfaced a new finding (a precision cap voiding a recall pass). I appended it to a reply on the existing repeatability thread (a different line) rather than anchoring it at the line where the relevant logic lives. The user asked "did you add the inline comment for the new finding?" — because it had no discoverable anchor.

**Root cause:** Folding a distinct finding into a reply on a thematically-adjacent thread hides it: it does not appear at its own code location, does not survive as an independent thread, and reads as commentary on the parent finding rather than a standalone issue. Thread-relatedness is not the same as line-relatedness.

**Suggested fix:** Every distinct finding anchors at the diff line its subject lives on, as its own comment (pending draft if composing a full review; a direct live inline comment if the review is already submitted). Reserve replies for genuinely continuing an existing thread (adding evidence to that same finding). Before posting a finding as a reply, ask: does this belong at a different line than the parent thread? If yes → new anchored comment.
