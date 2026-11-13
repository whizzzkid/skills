---
skill: wk-workstyle-rails
date: 2026-11-12
type: gap
severity: medium
verified-against-source: yes
---

A route change makes the generated route-helper RBIs stale; regenerate the full DSL set, not a named subset.

**What happened:** The agent added a route and regenerated RBIs only for the models and jobs it had touched. CI's `tapioca dsl --verify` then failed on the path/url helper RBIs. A targeted regeneration that named a constant which does not exist deleted that RBI file instead of refreshing it.

**Root cause:** Tapioca's URL-helper compiler output depends on the routing table, so any route change alters it. A `tapioca dsl <Const>` call for an unknown constant removes the matching generated file. Both behaviours were observed in the CI log and the local tapioca output.

**Suggested fix:** After any `config/routes.rb` edit, run a plain `bin/tapioca dsl`. Commit only the RBI files it changes, and confirm `git status` shows no deletions.
