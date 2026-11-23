---
class: principle
skill: wk-buildkite
date: 2026-11-20
---

# Full SHA for the commit filter; cap persistent "none" polls

- **Rule:** Pass the full 40-character SHA to `bk build list --commit`. The watch loop counts consecutive polls with
  no matching build and exits non-zero (code 3) after 20, so a filter that matches nothing fails loudly.
- **Why:** A background watch passed a 7-character SHA. Every poll reported no build, although the build for that
  commit ran and passed, and the loop read "none" as "still queued" until the background time limit killed it. That
  the filter needs an exact full SHA is inferred from the symptom, not verified against the CLI source; the poll cap
  is the guard either way. Stub-driven check: a build list that always returns `[]` now exits 3 at poll 20.
- **Where:** `SKILL.md` → background watch loop bullet and template.
