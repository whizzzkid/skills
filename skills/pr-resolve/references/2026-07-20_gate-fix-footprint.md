---
class: principle
---

**Rule** — In Step 4, classify each accepted finding by fix footprint, not just
severity. A fix beyond a localized patch — a new mechanism/feature, a design
change, or cross-cutting work — defaults to dismiss-with-rationale + a tracked
follow-up PR rather than inline build-out, especially on stacked or
explicitly-narrow PRs. Build inline only for a confirmed blocker of THIS PR's stated
scope. Treat a self-re-review-surfaced adjacent finding as a defer signal.

**Why** — Triage gated on correctness/severity with no scope checkpoint let an
"accepted" disposition silently authorize arbitrarily large inline work — a
dismissible TOCTOU (already backstopped by a reconcile job) was expanded into a full
concurrency mechanism, and self-re-review kept surfacing adjacent findings that
begat more fixes, doubling a "simple" PR.

**Where** — `skills/pr-resolve/SKILL.md` Step 4 (Generate Suggestions), after the
"Detect design flaws" block.
