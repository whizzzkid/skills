---
skill: wk:pr-resolve
date: 2026-04-30
type: gap
severity: low
---

No guidance on deduplicating multiple bot findings targeting the same line.

**What happened:** Two bots (copilot + {bot}) flagged the same `cat "$CLONE_STDERR"` line. Presented as one combined suggestion (single fix, single commit, replies on both threads). Works correctly but the skill says "for each active comment" with no dedup rule.

**Root cause:** Step 4 "for each active comment" instructs generating one suggestion per comment, even when multiple comments have the same fix.

**Suggested fix:** Add a note in Step 4: when two or more comments target the same path:line with the same concern, merge them into a single suggestion block (citing both reviewers) and apply as one commit; reply from each thread to the same commit SHA.
