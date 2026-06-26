---
class: principle
---

**Rule:** The pre-draft headroom measure must be the IDENTICAL staged-blob
command used at commit (`git add` first, then
`git show ":path" | LC_ALL=C awk` with `length($0)+1`, body after closing
`---`). Never a fresh hand-rolled awk/counter, and never the working tree.

**Why:** A home-grown replica that diverges from the hook (miscounts the first
body line or the closing `---`) reports false headroom — comfortable when the
staged blob is actually over-ceiling — so no reclaim gets budgeted and the
commit hook rejects the blob, triggering the multi-cycle measure-and-trim loop
Step 7.5 forbids. The divergent estimate is the upstream cause, not a separate
failure.

**Where:** Step 7.5, byte-budget reclaim rules — escalated the
`measure()`-not-`wc -c` bullet from baseline to **Important** on re-violation.
