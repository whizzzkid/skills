---
class: principle
Supersedes: the "never rename or edit a retrospect file" + `.distilled-retrospects`
  mtime-marker model in Source 4 (retros were a per-day append-only log).
---

# Retrospects are write-once per-session → distill then rename `.learned.md`

- **Rule** — Source 4 processes a retrospect file exactly like a Source 2
  learning: distill its lessons, then `mv` the file to `.learned.md`. No
  marker, no mtime compare.
- **Why** — the old model appended every session to one daily file and
  tracked it via a `.distilled-retrospects` mtime marker. Once distilled, a
  later session's appended content was never re-read (the marker said "done"),
  orphaning the lesson. `wk-retro` now writes one write-once file per session,
  so each is naturally a distill-once unit and the `.learned.md` rename can
  never hide later content.
- **Where** — `Source 4: Session retrospects`, the `Tracking processed sources`
  section, batch-mode presentation, and `Requirements` in SKILL.md. Paired
  with `wk-retro` (per-session files) and the new
  `.githooks/check-retro-filenames.sh` filename guard.
