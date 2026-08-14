---
skill: wk-pr-resolve
date: 2026-08-14
type: gap
severity: high
verified-against-source: no
---

Targeted spec runs after a shared-guard refactor let a semantic-inversion regression reach CI.

**What happened:** After extracting shared auth-gate logic into a helper method, only 3–4 spec files directly touching that helper were re-run before pushing. The helper's `return unless` semantics were inverted vs. caller expectations, breaking 20+ request specs that only run under the full `spec/requests/` directory. CI failed loudly; user asked "why didn't you notice that pre-push tho?"

**Root cause:** (unverified — inferred from symptom) skill's verification step does not distinguish "changed one method body" from "changed a shared helper's contract". The former can be verified narrowly; the latter demands the full spec directory that exercises every call site.

**Suggested fix:** Add an explicit rule in the verify step: any commit that adds/renames/re-signatures a helper method called from ≥2 sites → run the full spec directory containing those call sites (e.g. `spec/requests/`, `spec/controllers/`), not the narrow file list. Narrow verification is only allowed when the change is localized to one file's own logic.
