---
skill: wk-renovate
date: 2026-10-23
type: gap
severity: high
verified-against-source: yes
---

A major bump can force a transitive downgrade that silently reverts a newer gem's safer defaults.

**What happened:** A gem's new major pinned a parser gem to the previous major, so the lockfile downgraded it. The suite stayed green while request parsing quietly became more lenient (duplicate keys and comments accepted).

**Root cause:** Step 4's major-bump audit looks for API breakage, not changes to default behavior, and it doesn't treat downgrades as majors.

**Suggested fix:** Treat any major-version *downgrade* in the lockfile as an audited major. Diff the changelog's default-behavior changes and restore safety-relevant defaults explicitly at call sites, with specs that fail first.
