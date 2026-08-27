# Classifier Splits External-Write Confirmation

**Source:** `learnings/skills/pr-resolve/2026-08-27_classifier-splits-external-write-confirmation.md`
**Severity:** medium | **Type:** gap

## Incident

Combined push+reply+resolve plan confirmed with one "yes", but auto-mode
classifier denied reply-posting and thread-resolution separately — three
sequential confirmations needed where one was pitched.

## Root cause

Classifier scopes consent per external-write action class (git push vs. POST
comment vs. GraphQL resolve). An umbrella "yes" to a multi-step plan does not
flow through to each downstream class.

## Resolution

Added "Auto-mode sequential consent" note to Step 7 confirmation in SKILL.md:
when a downstream action is denied after plan approval, re-confirm only the
narrow blocked action — never re-pitch the full plan.
