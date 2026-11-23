---
class: principle
skill: wk-workflow
date: 2026-11-21
---

# One pin file per tool, read by every installer, asserted after install

- **Rule:** Keep each tool version in one source-of-truth pin file. Every install path (images, hosts, CI) reads it
  through one shared install script, which asserts the installed version matches the pin.
- **Why:** A single pin read by one shared script, with an installed-equals-pin assert, removed version drift
  between images and hosts, and left no second copy to maintain.
- **Where:** `SKILL.md` → Phase 2 Code standards (Version pins). Source: 2026-11-21 session-1 retrospect (What worked).
