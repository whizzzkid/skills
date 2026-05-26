---
class: principle
date: 2026-05-26
source: learnings/skills/pr-review/2026-05-26_auto-post-pending-review.md
---

- **Rule:** Phase 6 auto-creates the pending (draft) review immediately after the Phase 5 summary; no terminal A/B/C confirmation gate. The pending review is a draft — the user submits it from the GitHub UI, which is the human-in-the-loop checkpoint. Edits and skips happen in the GitHub UI on the draft, not via terminal prompts. User can opt out by saying "don't post" / "wait" / "let me review first" before the summary is presented.
- **Why:** User edits inline comments in the GitHub UI and found the A/B/C terminal prompt redundant friction. The pending-review draft state already provides the human gate (Submit button); the prompt re-asked for consent the GitHub UI itself enforces.
- **Where:** Phase 6 HARD RULE rewritten to auto-create the draft; "Present and wait" subsection replaced by "Pre-summary opt-out"; cross-references in line 619-ish ("user-approval gate") and the bot-thread reply (b) authorization updated.
