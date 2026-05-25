---
class: principle
date: 2026-05-25
source: learnings/skills/wk-pr-update/2026-05-22_prefer-merge-over-rebase.md
---

- **Rule:** Merge is the default integration strategy for incorporating base-branch advances onto a PR branch. Rebase rewrites SHAs, requires force-push, and detaches review-thread anchors; merge preserves all three. Reserve rebase only for explicit "I want linear history" user opt-in. Patch-replay remains correct for branches ≥5 commits ahead with no prior base-merge.
- **Why:** Agent reflexively rebased to keep linear history; force-push friction and lost review anchors outweighed the cosmetic benefit. User flagged the reflex.
- **Where:** Stage 2 strategy matrix — flipped "< 5 (no prior base-merge)" from Rebase to `git merge "$BASE_REF"`; added a HARD RULE and a "User asked for linear history → Rebase" opt-in row; description-frontmatter aligned.
