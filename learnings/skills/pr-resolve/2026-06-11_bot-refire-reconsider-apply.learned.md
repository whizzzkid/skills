---
skill: wk-pr-resolve
date: 2026-06-11
type: pattern
severity: medium
---

When a bot re-fires a previously-dismissed finding, reconsider applying the fix rather than dismissing again.

**What happened:** A {bot} raised the same two `code-duplication` findings across multiple push rounds. Each was dismissed in a prior cycle with rationale ("explicit methods are clearer"). On the third re-fire, the decision was reversed: both were applied. The refactors were clean, low-risk, and the bot's concern was structurally valid.

**Root cause:** The dismiss-with-rationale response silences a single round but doesn't prevent re-fires; bots re-evaluate from the current source after every push. Repeated re-fires are a signal the concern hasn't been addressed at the structural level, not that the bot is stuck.

**Suggested fix:** In the judgment-required consultation, when presenting a finding that was previously dismissed, surface the re-fire count and explicitly prompt the user to reconsider applying vs. dismissing. Phrase it as "this has been re-fired N times — lean toward applying unless the tradeoff is actively harmful."
