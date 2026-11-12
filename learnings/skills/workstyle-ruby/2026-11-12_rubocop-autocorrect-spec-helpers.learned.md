---
skill: wk-workstyle-ruby
date: 2026-11-12
type: surprise
severity: low
verified-against-source: yes
---

Unsafe RuboCop autocorrect (`-A`) on RSpec `def` helpers can produce a syntax error or a banned construct.

**What happened:** An org cop forbids `def` inside example-group blocks, and its `-A` autocorrect rewrote the helpers to `define_method`. A second org cop bans metaprogramming, so the new code was flagged again. An endless one-line `def` was also mangled into a syntax error that broke the whole file.

**Root cause:** The two cops' autocorrects conflict, and the rewrite of the endless-def form is not syntax-safe. Observed directly in the lint output.

**Suggested fix:** In specs, write helpers as `let(:name) { ->(args) { ... } }` (called with `.call`) or put them in a support module. Never run `-A` on spec helpers without re-running the linter and the specs afterwards.
