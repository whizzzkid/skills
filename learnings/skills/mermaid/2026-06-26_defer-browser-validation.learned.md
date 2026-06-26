---
skill: wk-mermaid
date: 2026-06-26
type: correction
severity: medium
---

Validate both diagrams in browser immediately after any edit, not deferred

**What happened:** After editing a Mermaid diagram (CI release diagram with semicolon → comma fix), I generated a mermaid.live URL but did not open it in a browser to validate before committing. The user had to redirect me twice ("it still does not render correctly you did not render it in the browser as asked") before I actually opened the browser and tested the diagram.

**Root cause:** I had written a mermaid learning about validating in the browser, but when applying the fix I skipped that step as a "validation overhead". I deferred browser testing, thinking URL generation was sufficient. The second diagram had a remaining syntax error (semicolon in label) that was invisible in git diff and only caught by actual browser rendering.

**Suggested fix:** Enforce immediate browser validation as a non-optional step AFTER every Mermaid edit. When editing multiple diagrams (1+2), validate BOTH in the browser in the same session before any commit. Never defer "I'll test later"—the validation is part of the edit workflow, not a followup.
