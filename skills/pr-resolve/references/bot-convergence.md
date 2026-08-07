---
class: principle
---

# Bot and convergence handling

- Track bot thrash by `(path_prefix, concern_class)` and total active findings per round.
- Stop before another fix when one pair re-fires 3 times, totals do not fall for 2 rounds, or a new finding reverses an
  accepted fix; Auto-Mode-confident dismissal proceeds without a plan.
- Re-fire on prose → inspect the content in code, CI, and prompts before rewording; absent content → delete or
  restructure.
- Use a bot's documented reply command; otherwise tag it with the decision.
- Before a judgment-required item, match it against dismissed records for the same field/concern; surface the prior
  reason, default to `(d)`, and ask once.
