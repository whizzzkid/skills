---
skill: wk-adversarial-review
date: 2026-06-17
type: pattern
severity: high
---

Return-value gate divergence: caller re-checks original precondition instead of capturing helper's return value.

**What happened:** A helper (`seed_state_from_remote`) was previously void — it ran but the caller re-checked `fetch_st.success?` at the write-back gate. When the helper was later made fallible (git show can fail even when git fetch succeeds), the caller's gate still only checked the fetch result. A successful fetch + failed seed left the gate open, allowing write-back from a stale-baseline recompute.

**Root cause:** The caller gate (`write_back! if fetch_st.success?`) predated the helper and was never updated when the helper gained independent failure modes. The two conditions look equivalent at first glance (fetch failed → seed skipped → both false) but diverge when the intermediate step fails silently.

**Suggested fix:** Add a sweep pattern: when a helper is triggered by condition X and gates a downstream action, grep callers for re-checks of X rather than capturing the helper's return value. Flag any `if X.success? && ...` that also calls a helper triggered by `X.success?` — the helper's return value should be the gate, not the original precondition. Also: `git show` exiting 0 with empty stdout is a valid failure mode for blob reads — add `out.strip.empty?` guard before writing to disk.
