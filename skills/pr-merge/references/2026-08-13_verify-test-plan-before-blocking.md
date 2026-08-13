---
class: principle
skill: wk-pr-merge
date: 2026-08-13
---

- **Rule:** Step 5 triages unchecked action items by verifiability before
  blocking. Verifiable items (UI rendering, test output, CLI behavior, dev
  server state) are attempted first; only genuinely unverifiable items
  (production access, external system, manual judgment) block immediately.
- **Why:** The agent defaulted to surfacing unchecked test-plan items as
  paperwork blockers requiring user waiver, even when it could verify them
  itself (e.g., by spinning up a devcontainer). This turned the agent into a
  gatekeeping clerk instead of a productive collaborator.
- **How to apply:** When Step 5 encounters `- [ ]` items, classify each as
  verifiable or unverifiable. Attempt verification of verifiable items; check
  off those that pass; report failures with observed evidence. Block only on
  items the agent genuinely cannot verify.
