---
skill: wk-adversarial-review
date: 2026-05-21
type: gap
severity: high
---

Spec claimed a value was present in every metric, but call sites in two scripts omitted it — bot caught it post-push, adversarial review missed it pre-push.

**What happened:** A spec doc stated that a specific field was a tag "common to every metric." The mechanical sweeps (2.8 cross-doc enumeration) checked test counts and new symbols, but did not verify that behavioral claims about universality ("common to every", "always included", "tagged on every call") were true at every actual instantiation site. Two binary scripts omitted the field when constructing the client. The bot caught the divergence post-push; adversarial review did not catch it pre-push.

**Root cause:** Sweep 2.8 greps for enumerations (counts, bullet lists) in docs but does not extract universality claims from spec prose and verify them against call sites. The pattern "common to every X" / "tagged on all Y" / "present in every Z" is a hidden enumeration — it implies "check every call site of X" — but is not surfaced by a count/bullet grep.

**Detection sketch:** After sweep 2.8, add a prose-claim scan:
```bash
grep -nE "common to (every|all)|tagged on (every|all)|present in (every|all)|applies to (every|all)" docs/specs/ docs/plans/ README.md 2>/dev/null
```
For each hit, extract the subject noun (e.g. "metric", "call", "request"), grep the diff for every instantiation/call site of the related class/function, and verify the claimed field is passed at every site. Flag any site that omits it as a `blocker` (spec-vs-implementation divergence).

**Confidence:** high — mechanical detection via grep + call-site cross-check.
