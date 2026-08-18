---
class: principle
---

# Footer pre-emit gate runs on every GitHub mutation, per surface

**Rule** — Every GitHub outbound body (PR description edit, issue comment,
threaded reply, dismissal body, follow-up message) carries the canonical `wk-gh`
footer, and the wk-gh Step 4 footer pre-emit gate runs on the FINAL body string
immediately before EACH mutation — independently per surface. Never treat a prior
footer on a different surface as satisfying the current mutation; composing the
payload and performing the GraphQL/REST mutation without a footer-rendering gate
immediately before the outbound request ships a footer-less body.

**Why** — Re-violation. The commit-message trailer and the canonical outbound
footer both open "Generated … wk-skills", so a by-memory body conflates them even
when the gate already exists for the PR-description surface. The gate must be
mandatory per-mutation and the footer pasted from the literal `wk-gh` Step 4
block, never reconstructed.

**Where** — `wk-pr-resolve` Hard Rule 0 (escalated from baseline prose to name
the mechanical per-mutation gate) and `references/post-push-finalization.md`
(pre-mutation footer gate step). The gate itself lives in `wk-gh` Step 4.