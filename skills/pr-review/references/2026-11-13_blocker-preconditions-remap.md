---
class: principle
---

# Re-map verifier blockers on their preconditions

- **Rule:** Ask each verifier to state every `blocker`'s preconditions (shipped defaults, non-default config, unpinned
  external behavior). Needs non-default config → `suggestion`; needs unpinned external behavior → `question`;
  preconditions unstated → treat as shipped defaults (stays `concern`, fails closed).
- **Why:** Verifier prompts carried the severity definitions, yet the agent rated every reachable data-loss path as a
  blocker regardless of the setup it required. Two findings that only fired under an unusual ignore pattern or a custom
  external-tool output path would have held approval on items that are not critical as shipped. The existing re-map
  (not correctness/security/data-loss → `suggestion`) could not catch them: both were data-loss paths. Findings still
  post; only the severity label moves. The `wk-adversarial-review` verdict gate is untouched.
- **Where:** [`wk-pr-review`](../README.md) → Phase 3, "Verifier severity is a draft".
