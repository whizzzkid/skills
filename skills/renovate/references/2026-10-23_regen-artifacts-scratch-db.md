---
class: principle
source: learnings/skills/renovate/2026-10-23_regen-artifacts-scratch-db.learned.md
date: 2026-10-23
skill: wk-renovate
---

**Rule** — Regenerate schema-derived artifacts against a throwaway, freshly migrated DB selected through the app's
config env override, then compare the changed-file list against CI's expectation. Scope per-dependency stub
regeneration to the bumped packages; never drop the development DB for fresh state.

**Why** — A dev DB volume is shared across worktrees, so it holds columns from other branches' migrations and local
regeneration drifts from CI's clean run. Committed per-dependency stubs are rarely kept strictly in sync, so a full
regen rewrites the whole stale tree into the diff. A dev-environment drop task can also drop the test DB.

**Related** — wk-commit's staging-discipline reference covers restoring an artifact to base when the branch changed
none of its source; this rule covers the case where a bump genuinely requires regeneration.

**Where** — `SKILL.md` → Step 4 (derived-artifact regeneration bullet); README Key Rules.
