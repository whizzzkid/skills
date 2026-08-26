---
class: principle
source: learnings/skills/workflow/2026-08-25_review-target-vs-build-identity.md
---

# Classify sources by semantic domain before composing identifiers

When composing a key or identifier from multiple sources (env vars, config,
API fields), classify each by semantic domain (target-under-review vs.
build-self, external vs. internal) before combining.

A fallback chain crossing domains — e.g., `REVIEW_*` → `BUILDKITE_*` — is a
presence/gate check, not an identity binding. Reusing it as identity conflates
distinct entities.

**Signals:** helper names containing "with_fallback" or "or_default"; comments
distinguishing "target" from "self" or "review" from "build." Re-read
existing code's domain signals before reusing a multi-source chain in a new
context.
