---
skill: wk-commit
date: 2026-07-27
type: gap
severity: medium
verified-against-source: n/a
---

A PR-body sync carried over the commit-message trailer instead of the canonical outbound footer.

**What happened:** The post-push PR sync rewrote a stale PR body against current HEAD. The rewrite
inherited the previous revision's closing block, which was the commit-message trailer variant, not
the canonical outbound footer required for every GitHub-visible body. The sync step was treated as
complete once the content was accurate; the footer was never re-checked.

**Root cause:** The two strings both open with "Generated ... wk-skills", so a carried-over body
looks correct at a glance. The sync step's definition of done covers content drift but does not
name the footer gate, so the gate is only run when a body is composed from scratch.

**Suggested fix:** Make the outbound-footer pre-emit gate an explicit, non-optional part of the
post-push PR sync step — a body sync is not complete until the gate has been re-run on the *new*
body string, not the old one. Call out that a body inherited from an earlier revision is the
common carrier of the wrong footer, since a from-scratch compose naturally triggers the gate and an
edit does not.
