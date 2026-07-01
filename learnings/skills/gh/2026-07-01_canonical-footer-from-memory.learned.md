---
skill: wk-gh
date: 2026-07-01
type: correction
severity: medium
---

Posted a GitHub comment with the commit-message footer reconstructed from memory
instead of the canonical wk-gh Step 4 outbound footer.

**What happened:** A dismissal comment shipped with the `🦾 Generated with
[wk-skills](...) and multiple models.` footer — the git-commit/PR-trailer footer
from the environment's commit rules — rather than wk-gh Step 4's canonical
outbound footer (`<sup>Generated using [wk-skills](...) and multiple
agents/models. DM me your feedback.</sup>`). The user caught it after the post.

**Root cause:** The footer was written from memory at payload-build time. The
agent conflated two distinct footers — the commit-message trailer and the wk-gh
outbound-body footer — because both start with "Generated ... wk-skills". Step 4
explicitly forbids reconstructing the footer from memory, but the rule was not
re-read before composing the comment body.

**Suggested fix:** Before composing ANY outbound GitHub body, read the wk-gh
Step 4 footer block and paste it verbatim — never type a "Generated with..."
line from memory. Add an explicit disambiguation note: the commit-message footer
and the wk-gh outbound footer are different strings; the commit footer never
belongs on a GitHub comment/review/PR body. Add a mechanical pre-emit check —
grep each outbound body for the exact canonical footer AND reject if the
commit-footer variant (`🦾 Generated with`) is present — so a memory-typed footer
cannot ship.

**Additional evidence — fix-one-surface reflex:** The same wrong footer was live
on TWO surfaces (a conversation comment and the PR description). When a footer
defect is found on one surface, it is almost certainly on every body posted the
same way — sweep ALL outbound surfaces (PR body, review bodies, every comment/
reply) in one pass and correct them together, rather than fixing only the surface
the user pointed at and waiting to be told about the next one.
