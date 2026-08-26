---
class: principle
source: learnings/skills/pr-resolve/2026-08-25_validate-pr-body-drift.md
---

# PR body drift check must validate tags/releases against live state

When the PR body references version tags or release links, the Step 3 drift
check must query the live tags and releases API and flag any mismatch before
triage begins. This sub-step is non-skippable even when Step 2 consumes
significant effort — conflict resolution does not exempt the drift audit.
