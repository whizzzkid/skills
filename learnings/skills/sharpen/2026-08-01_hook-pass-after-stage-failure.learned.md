---
skill: wk-sharpen
date: 2026-08-01
type: gap
severity: high
verified-against-source: yes
---

Abort a staged-index hook pass when staging fails.

**What happened:** A throwaway-index `git add` failed, but the surrounding
command continued and every hook reported success against an empty index.

**Root cause:** The hook harness neither failed fast on the staging error nor
asserted that the staged path set exactly matched the intended fold.

**Suggested fix:** Run throwaway-index setup fail-fast, verify the exact staged
paths before any hook, and reject an empty or mismatched set even when every hook
returns success.
