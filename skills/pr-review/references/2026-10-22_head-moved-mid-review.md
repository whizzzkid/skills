---
class: principle
---

**Rule** — When the Phase 5 recheck finds the PR head moved since Phase 1, re-derive the review at the new head
before posting: diff old..new (mapping lineage first across a rebase), drop findings the delta fixed, re-run probes
for logic findings in changed hunks, review or flag the delta's new code, re-anchor every comment from the new-head
blob, and post with the new head as `commit_id`.

**Why** — A long adversarial phase gives the author time to push. The recheck caught the mismatch, but the compressed
rule only said "resolve anchors from the old head; set `commit_id` to the old head" — a prior compression pass had
dropped the original "inspect delta" and "refresh `PR_HEAD`" clauses. Posting the old payload publishes findings the
author already fixed, anchored to lines the author no longer sees.

**Where** — [`wk-pr-review`](../README.md) Phase 5 "Head moved" bullet; procedure in
[`posting-pending-review.md`](posting-pending-review.md) "Recheck reviewed head".
