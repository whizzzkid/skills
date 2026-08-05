---
class: principle
---

# Select the merge method from the active ruleset

**Rule** — Read active `allowed_merge_methods` before the merge command. Choose the first allowed method in
preference order: squash, rebase, then merge. Never probe a known-forbidden method.

**Why** — Repository-level settings can advertise methods that an active ruleset forbids.

**Where** — Step 6 merge-method selection.
