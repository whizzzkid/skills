---
skill: wk-pr-resolve
date: 2026-07-21
type: correction
severity: medium
---

A review reply was posted with the commit-message footer variant instead of the canonical outbound footer, needing a PATCH to correct.

**What happened:** A threaded reply to a bot finding was rendered and POSTed with the `wk-commit` trailer footer (`🦾 Generated with [wk-skills]...`), which `wk-gh` bans on GitHub bodies. The mistake was only caught after the POST, when the wk-gh footer rules were re-read; the comment then had to be PATCHed to the canonical `<sup>Generated using [wk-skills].../DM me your feedback.</sup>` footer.

**Root cause:** The two footers both open "Generated ... wk-skills", so they are easy to conflate when composing a body from memory. The wk-gh pre-emit footer gate (grep for the canonical marker, reject the commit-trailer variant, verify the pinned link) was run only on the PR-description body, not on the individual reply body before its POST.

**Suggested fix:** Make the wk-gh footer pre-emit gate mandatory on EVERY outbound body — inline replies included — immediately before each POST, never only on the PR description or only after posting. Compose the footer by pasting the literal wk-gh block, not from memory.
