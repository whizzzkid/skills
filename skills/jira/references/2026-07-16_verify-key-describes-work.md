---
class: principle
---

**Rule:** A detected Jira key is a candidate, not a confirmed match. Before
transitioning it or writing it into a PR title/body, fetch the issue and confirm
`fields.summary`, component/area, and `status` plausibly describe the current
diff. On mismatch (different service/feature, or a Done/Closed/Resolved ticket
for unrelated work) do not tag the stale key — surface it and locate/create the
correct ticket under the right parent, then re-point references.

**Why:** Key detection lifts the first `[A-Z]+-\d+` from the branch/commit and
trusts it verbatim. An inherited or copy-pasted key can reference unrelated work,
so the PR gets tagged with a stale/wrong ticket until caught.

**Where:** wk-jira Stage 1 — new "Verify the key describes this work" HARD RULE
after key detection, before any transition or PR tag.
