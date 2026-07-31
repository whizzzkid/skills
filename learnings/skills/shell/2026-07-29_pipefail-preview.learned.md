---
skill: wk-shell
date: 2026-07-29
type: correction
severity: medium
verified-against-source: yes
---

Keep non-assertive preview pipelines out of `pipefail` validation gates.

**What happened:** An unused JSON preview pipeline returned status 141 and stopped a pre-emit gate
before the assertions ran.

**Root cause:** With `set -o pipefail`, a producer that receives SIGPIPE makes the whole pipeline
fail even when the preview output is irrelevant to validation.

**Suggested fix:** Make each gate command assert one property directly; remove preview pipelines or
ensure their consumers read the full stream.
