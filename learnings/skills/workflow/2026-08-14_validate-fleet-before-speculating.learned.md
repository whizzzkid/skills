---
skill: wk-workflow
date: 2026-08-14
type: correction
severity: high
verified-against-source: n/a
---

Validate fixes against fleet patterns before proposing speculative solutions

**What happened:** Agent proposed OIDC identity fixes based on assumptions about token structure (requiring `sub`, `aud`, `id_token` claims) without checking how other apps in the fleet handle the same integration. User had to explicitly say "did you validate this against {repo} or are you hallucinating this?" and "grep {repo-A}, {repo-B}, {repo-C}" before the agent consulted sibling services.

**Root cause:** Workflow skill lacks a step requiring fleet/sibling-service validation when fixing integration code that follows a shared convention. Agent defaulted to RFC-correct OIDC behavior instead of checking how the org's shared auth gem and other consumers actually work.

**Suggested fix:** Add a workflow step: when fixing integration code that uses a shared gem or org-wide service, grep 2-3 sibling repos for the same integration pattern before proposing changes. "How does the fleet do it?" should precede "what does the spec say?"
