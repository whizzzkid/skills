---
skill: wk-sharpen
date: 2026-07-25
type: gap
severity: medium
verified-against-source: yes
---

The Step 7.5 byte budget is computed from the planned fold only, so Step 5's mandatory contradiction-resolution edits arrive after the ratio is already locked and silently break it.

**What happened:** A near-ceiling skill (headroom under 2× the planned edit) triggered
the budget rule. The arithmetic was stated up front and met: addition measured, four
reclaim targets measured, combined net exceeding the addition by more than the required
1.2×, first-pass net negative. The edits landed exactly as budgeted.

Step 5's audit then surfaced two real contradictions that the new folds themselves had
introduced — a pre-existing rule now directly opposed by a rule just added. Resolving
them is mandatory ("Resolve contradictions"), cost a few hundred bytes, and pushed total
additions past the budgeted figure. Final net stayed negative and the body stayed under
the ceiling, but the reclaim-to-addition ratio fell below 1.2×. Satisfying the ratio
again would have required relocating a verification checklist behind a pointer, which
contradicts the principle that verification gates must be structurally hard to skip.

**Root cause:** The budget rule treats the fold as the only thing that adds bytes, and
sequences measurement before drafting. But audit-cleanup bytes are *discovered* at
Step 5 — after the budget is fixed — and the two rules that generate them (resolve
contradictions; bundle cleanup into the same change) carry no byte allowance. The
ordering guarantees the overrun rather than merely permitting it: a fold that exposes a
contradiction is exactly the fold whose cleanup cannot be budgeted in advance, because
the contradiction is not visible until the fold is written.

**Suggested fix:** Reserve headroom for audit cleanup in the up-front budget rather than
treating the fold's measured size as the whole addition — e.g. budget the addition plus a
cleanup allowance, and size reclaim against that total. State the hard outcomes (net
non-positive, under ceiling) as the binding gate and the 1.2× ratio as the planning
target it is, so a post-draft cleanup overrun is reported as arithmetic rather than
triggering another reclaim hunt. Add the explicit stop: never reclaim by relocating a
verification gate or checklist behind a pointer — that trades a correctness property for
a byte count, and the ceiling exists to protect load-bearing rules, not to outrank them.
