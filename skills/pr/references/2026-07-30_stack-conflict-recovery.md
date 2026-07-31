---
class: principle
---

# Recover a rewritten stack as one unit

- **Rule:** Import and snapshot the whole stack, cascade-rebase from its base,
  resolve one layer at a time, validate the complete rewritten chain, push every
  layer, then verify remote heads and PR state.
- **Why:** Independent branch rebases can sever ancestry or publish only part of
  the rewritten dependency chain. Stack push itself is non-atomic, so success
  must be proven per remote head.
- **Verification:** Extension help confirms remote stack checkout, cascading
  rebase with continue/abort recovery, and per-branch force-with-lease push.
- **Where:** [`wk-pr`](../README.md) stack lifecycle and
  [`gh-stack-stacking.md`](gh-stack-stacking.md) recovery sequence.
