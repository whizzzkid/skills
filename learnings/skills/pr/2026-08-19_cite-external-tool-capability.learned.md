---
skill: wk-pr
date: 2026-08-19
type: gap
severity: low
verified-against-source: yes
---

When a PR relies on an external tool/plugin supporting a feature, cite the verifiable source proving it in the PR body and self-review up front.

**What happened:** A PR configured an external plugin's built-in multi-credential
"collection" feature to spread GitHub API rate limits across two apps. The PR body
and self-review described the mechanism but did not link the plugin source that
implements it. A reviewer then challenged whether the capability had been
hallucinated, forcing an after-the-fact source citation.

**Root cause:** wk-pr Hard Rule 4 requires deriving behavioral claims from the
implementation, but scopes "implementation" to the repo's own source. A claim that
an *external* dependency supports a feature has its proof outside the repo, so the
rule does not currently compel citing it — leaving external-capability claims
unsupported until challenged.

**Suggested fix:** Extend wk-pr Hard Rule 4 (and wk-self-review) so that any claim
an external tool/plugin/dependency supports a feature must link the specific source
file/line (or official docs) proving it, at composition time — not only after a
reviewer doubts it. Proactive citation pre-empts the "did you hallucinate this?"
round-trip.
