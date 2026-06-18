---
class: principle
---

**Rule:** Before flagging a missing env-var passthrough as a blocker, check for a spec that deletes the var and asserts the script's own default. Such a spec signals intentional omission → downgrade to `question`.

**Why:** Forwarding a var can pass a wrong plugin-injected value that overrides the script's correct default. The omission is invisible to code-only analysis; the fallback-exercising spec is the only signal it is deliberate.

**Where:** Sweep 2.20 (fix column).
