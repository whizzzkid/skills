---
skill: wk-workflow
date: 2026-07-30
type: gap
severity: medium
verified-against-source: yes
---

Run dependent verification commands fail-fast.

**What happened:** An intentionally failing browser test was followed by the full suite because
separate newline-delimited commands continued after the non-zero exit, producing cascading failures
and orphaned test-browser processes.

**Root cause:** The grouped verification command lacked `set -euo pipefail`, and the later suite was
therefore launched despite the expected-red proof failing.

**Suggested fix:** Run dependent gates in separate tool calls or begin grouped verification commands
with `set -euo pipefail`; never place later green-gate verification after an expected-red proof
without an explicit fail-fast boundary.
