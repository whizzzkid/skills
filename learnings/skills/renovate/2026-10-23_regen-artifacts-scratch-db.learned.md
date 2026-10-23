---
skill: wk-renovate
date: 2026-10-23
type: pattern
severity: medium
verified-against-source: yes
---

Regenerate schema-derived artifacts (DSL RBIs, model annotations) against a freshly migrated scratch DB, and only regenerate the bumped gems' RBIs.

**What happened:** The shared devcontainer DB volume held columns from other branches' migrations, so the local DSL verify drifted from CI. Separately, a full `tapioca gem` rewrote the entire, already stale gem-RBI tree.

**Root cause:** A dev DB volume is shared across worktrees, and committed gem RBIs aren't kept strictly in sync.

**Suggested fix:** Point the app at a throwaway DB name through its config env override, migrate it, regenerate, then compare against CI's expected file list. Run `tapioca gem <bumped runtime gems>` rather than a full regen. Note that `rails db:drop` in development also drops the test DB.
