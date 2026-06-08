---
class: principle
---

- **Rule:** After any SilverBullet CSS/HTML change, verify in a browser
  (screenshot + DOM inspect + interactivity test), not by file diff alone.
- **Why:** Service worker, IndexedDB cache, CodeMirror preview, and HTML widget
  scoping sit between the file and the render; a correct-looking file can still
  render single-column, collapse lines, or ship disabled handlers.
- **Where:** Step 6 "Verify Changes Visually" HARD RULE.
