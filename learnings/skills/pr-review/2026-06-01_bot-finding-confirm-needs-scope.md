---
skill: wk-pr-review
date: 2026-06-01
type: pattern
severity: medium
---

Confirming a bot finding in the playground often reveals a *narrower* scope than the bot stated — distinguish "confirmed but different" from "confirmed as-stated".

**What happened:** A bot flagged a vacuous-pass risk in a while-loop assertion ("if tar tzf produces no output, zero iterations execute and the test passes"). The playground reproduced the empty-archive case (confirmed) but also showed the regex assertion *does* correctly fail a test when a bad filename exists in a non-empty archive — so the concern was valid only for the zero-iteration edge, not for the general case the bot implied.

**Root cause:** Bot findings are written for maximum surface area; the playground frequently isolates the exact failing scenario to a subset of the claim. Treating confirmed findings as fully confirmed risks over-amplifying and confusing the author about the fix scope.

**Suggested fix:** After marking a bot finding Confirmed, add a "scope note" to the reply body: what was confirmed, and what *wasn't* — so the author knows exactly what to address. Template: "Confirmed for the case where X; does *not* apply when Y (verified in playground)."
