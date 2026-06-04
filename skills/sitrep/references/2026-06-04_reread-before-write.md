---
class: principle
---

- **Rule:** Re-read `$LIVE_FILE` immediately before any write/edit (start Stage 4, end Stage 5); preserve every `[x]`; prefer `Edit` over `Write`.
- **Why:** Minutes elapse while parallel agents run; a full `Write` overwrite silently clobbers checkboxes the user ticked in the browser during that window.
- **Where:** start Stage 4 + end Stage 5 re-read preamble.
