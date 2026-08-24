---
class: principle
---

**Rule:** Prefer simple sequential shell commands over compound chains (`&&`, pipes, subshells). Auto-mode permission classifiers block commands they cannot decompose. Surface denials to the user; never silently restructure.

**Why:** Complex compound commands are opaque to the harness permission classifier, which must approve each tool call. A single piped chain mixes read and write intent, making it impossible for the classifier to grant narrow permission. Sequential commands let the classifier approve each step independently.

**Where:** `SKILL.md` → Phase 2 Code Standards → Shell simplicity bullet.
