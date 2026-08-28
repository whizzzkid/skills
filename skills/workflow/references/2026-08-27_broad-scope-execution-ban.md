---
class: principle
date: 2026-08-27
skill: wk-workflow
---

# Interpret user execution bans broadly

- **Rule:** "Don't run {tool} locally" bans all heavy local execution against
  that tool's repo — full test suites, dev servers, build steps — not just the
  named product action. Prefer changed-file-only validation; confirm scope
  before launching a full local run.
- **Why:** Agent read "don't run {tool} locally" as banning only the product
  action, then launched the repo's full test suite in the background — still a
  heavy local run the user intended to prohibit.
- **Where:** wk-workflow Autonomy Rules, new bullet after stop-and-ask
  paragraph.
