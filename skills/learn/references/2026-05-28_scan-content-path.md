---
class: principle
date: 2026-05-28
source:
  - learnings/skills/retro/2026-05-28_scan-needs-transcript-fallback.md
severity: medium
---

- **Rule** — in scan mode, extract message text from `.message.content` (string or typed-block array), never `.content`; add a zero-result guard that falls back to git-log reconstruction.
- **Why** — the top-level transcript object carries `.type` + `.message`; reading `.content` returns empty, so the scan silently reports zero interruptions even in a session with many corrections (observed: six corrections, zero found).
- **Where** — wk-learn Scan Mode Step S2: corrected jq extraction path + "zero user messages → warn and fall back" guard.
- **Note** — the originating learning (filed under retro) mis-diagnosed the cause as a changed type taxonomy; the schema does have `user`/`assistant` types, the bug was purely the content path. Verify schema against a real file before coding a transcript fix.
