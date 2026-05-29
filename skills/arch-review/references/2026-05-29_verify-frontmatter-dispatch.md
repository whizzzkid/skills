---
class: principle
skill: wk-arch-review
date: 2026-05-29
---

# Verify config/frontmatter is actually consumed by the runtime

- **Rule:** When a system declares behavior in config/frontmatter (file-scope,
  routing, dispatch metadata), read the engine to confirm it consumes that
  config before accepting the doc's claim that it gates behavior.
- **Why:** Specs describe capabilities the engine lacks — a "file-type gating"
  frontmatter turned out to be advisory prose with no dispatch logic; everything
  was packed into one LLM context. "The config controls X" is Unverified.
- **Where:** Step 3 Lens C (Underlying Assumptions).
