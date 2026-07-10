---
skill: wk-gh
date: 2026-07-10
type: correction
severity: medium
---

Shipped the commit-message trailer variant as the footer on GitHub comment bodies instead of the canonical outbound footer.

**What happened:** Self-review comments posted to a PR ended with the `wk-commit` trailer `🦾 Generated with [wk-skills](...) and multiple models.` — the commit-message string — rather than the canonical outbound-body footer `<sup>Generated using [wk-skills](...) and multiple agents/models. DM me your feedback.</sup>`. Both open with "Generated ... wk-skills", so the two were conflated and the wrong one reached every comment body on the surface.

**Root cause:** The footer was reconstructed from memory / carried over from the commit-message context instead of being pasted verbatim from wk-gh Step 4 at render time. The Step 4 pre-emit check (grep each outbound body for the exact canonical footer AND reject if the `🦾 Generated with` commit-trailer variant is present) was not run before posting.

**Suggested fix:** Enforce the Step 4 pre-emit grep mechanically before any GitHub/outbound write — reject the body if the commit-trailer variant (`🦾 Generated with`) appears, or if the canonical `<sup>Generated using ... DM me your feedback.</sup>` is absent. Because a footer defect on one comment is almost always on every body posted the same way, sweep all surfaces (PR body, review bodies, every comment/reply) in one pass. Never type either footer from memory; read the literal block from the skill and inject it.
