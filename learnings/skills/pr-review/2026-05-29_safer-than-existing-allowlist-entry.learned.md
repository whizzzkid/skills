---
skill: wk-pr-review
date: 2026-05-29
type: pattern
severity: medium
---

New allowlist entry may be strictly safer than an existing one — establish comparative security argument in the review body.

**What happened:** PR added a new command to a pre-firewall execution allowlist. Reflexive security framing flags additions as risk increases. But the added command (`cargo fetch`) only downloads locked crates — unlike the already-allowed command (`cargo build`) which compiles and runs `build.rs` scripts, a far more privileged operation.

**Root cause:** Default security framing treats "added to allowlist = wider attack surface." That's wrong when the added entry is strictly less capable than a sibling already in the list.

**Suggested fix:** When reviewing allowlist changes, compare the new entry's capabilities against existing entries, not just against an empty list. If the new entry is strictly less capable than an already-present entry, say so explicitly in the review body — it pre-empts reviewer alarm and anchors the security verdict to evidence.
