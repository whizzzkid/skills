---
skill: wk-bats
date: 2026-08-28
type: surprise
severity: high
verified-against-source: yes
---

Non-final double-bracket assertions can fail without failing a Bats test.

**What happened:** Mutation testing broke an early `[[ ... ]]` assertion, but the test still passed because later
assertions succeeded.

**Root cause:** The driven Bats harness did not propagate the non-final compound command's status as the test verdict.

**Suggested fix:** Make each `[[ ... ]]` assertion explicitly propagate failure with `|| return 1`, especially when
more commands follow in the same test.
