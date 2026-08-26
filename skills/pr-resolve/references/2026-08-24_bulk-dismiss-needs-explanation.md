---
class: principle
source: learnings/skills/pr-resolve/2026-08-24_bulk-dismiss-needs-explanation.md
---

# Bulk-dismiss gate must show substance, not just a count

A count-only prompt ("3 Minor findings, dismiss all?") reads as the agent not
having looked at the findings. The bulk-dismiss shortcut skips the per-item
confirmation loop, not the per-item explanation.

Always render each finding's one-line summary (what it flagged, file:line)
before the bulk choice.
