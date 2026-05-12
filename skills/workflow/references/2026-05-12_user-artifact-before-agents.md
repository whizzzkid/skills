---
name: user-artifact-before-agents
description: Read user-provided URLs/IDs/paths before dispatching exploration agents.
---

- **Rule:** Scan the user's last message for concrete references (URL, PR
  number, file path, error line, build ID) and fetch/read them directly
  before spawning parallel exploration `Agent` calls.
- **Why:** The user has already scoped the investigation; running parallel
  agents over an unread artifact wastes turns and signals inattention.
- **Where:** "Investigate user-provided artifacts first" at the top of
  Phase 1 in `workflow/SKILL.md`.
