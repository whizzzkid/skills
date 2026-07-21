---
class: principle
---

# The footer pre-emit gate runs on every body, not just the PR description

**Rule** — The wk-gh footer pre-emit gate (grep the final body for the canonical
`<sup>Generated using [wk-skills]…</sup>` marker, reject the `wk-commit` trailer
variant `🦾 Generated with…`, verify the pinned link) fires on EVERY outbound body
immediately before EACH POST — every inline reply, not only the PR description. A
render-time append is not the gate; appending is not verifying.

**Why** — Re-violation. The gate already existed and greps the trailer variant,
but it was run only on the PR-description body; a reply body composed from memory
shipped the commit-message trailer footer and needed a post-hoc PATCH. Both
footers open "Generated … wk-skills", so they conflate when composed from memory
— paste the literal wk-gh block, never reconstruct it. Escalated the gate to
state append ≠ verify and to require a per-POST re-run.

**Where** — `wk-gh` Step 4 (outbound message footer, pre-emit gate). Enforced at
call sites via `wk-pr-resolve` Hard Rule 0 (satisfy wk-gh gates before any write).
