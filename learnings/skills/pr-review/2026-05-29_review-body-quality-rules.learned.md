---
skill: wk-pr-review
date: 2026-05-29
type: correction
severity: high
---

Review body must avoid five antipatterns: false blast-radius pre-judgment, meta-commentary about which skills were invoked, stating-the-obvious findings, re-narrating what other bots already said, and collective bot-validation summaries as body prose.

**What happened:** The review body contained: (1) "as a doc-only change the blast radius is low" — a pre-judgment that contradicts the purpose of arch-review, which exists to determine blast radius; (2) "I ran an architecture pass (wk-arch-review) in addition to..." — meta-commentary the author doesn't need; (3) "No code-breaking blockers" — obvious because there are no code changes; (4) a paragraph re-validating the bot's §3-split finding that the bot itself had already called out; (5) "Validated 2 findings from {bot} — both reproduced" — stating facts about other bots' work.

**Root cause:** The review body template prompts for a "verdict on the change as a whole" but doesn't prohibit pre-judging scope before arch-review runs, meta-commentary about the review process, or bot-narration that adds no value for the PR author.

**How to apply:** Review body rules — never state "blast radius is low/high" before arch-review has run; never mention which skills or tools were invoked; never state "no X blockers" when the absence is structurally obvious (no code = no code bugs); never re-state what a bot already said; never narrate bot-validation outcomes in the body. If bot findings were confirmed, the review body addresses their substance (what they mean for the PR), not the fact of confirmation.
