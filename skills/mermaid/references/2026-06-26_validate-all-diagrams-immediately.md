---
class: principle
---

**Rule:** Render every changed Mermaid diagram in a browser the moment it is
edited — never defer to "later". When an edit touches multiple diagrams, render
**all** of them in the same pass before any commit. URL generation is not
validation; the browser open is.

**Why:** Re-violation of the existing Step 5 browser-render HARD RULE. The
agent had already written the validate-in-browser rule, then skipped it as
"validation overhead" — generated a preview URL but did not open it, and
validated only the first of two edited diagrams. The second carried a
syntax error (a semicolon in a label) invisible to `git diff` and grep,
caught only after the user redirected twice. Escalated the rule with the
explicit deferral + multi-diagram failure modes so the recurring miss is
named, not just the general principle.

**Where:** wk-mermaid Step 5 (added "render immediately, all diagrams one pass,
never defer" bullet under the existing render HARD RULE) and Common Mistakes
(new "deferring browser validation" entry). Version bumped.
