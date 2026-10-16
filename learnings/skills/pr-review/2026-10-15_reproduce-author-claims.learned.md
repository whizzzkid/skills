---
skill: wk-pr-review
date: 2026-10-15
type: pattern
severity: medium
verified-against-source: yes
---

When asked to validate a PR description's empirical claims, re-derive each figure from primary data and rerun the
author's own experiment rather than trusting the stated counts.

**What happened:** The description cited CI build annotations, job windows, log line counts, and "N of M examples fail
locally". Querying the CI API confirmed timestamps and counts exactly, but rerunning the author's local experiment
(revert the fix in a scratch worktree, run under the guard with CI env vars unset) produced a different failure count
than claimed, because the code path the author named as env-gated was not gated. Separately, a naive log-latency pairing
("timestamp of the next line") gave wrong results because the logged payload spanned multiple lines.

**Root cause:** The skill's empirical-proof rule targets reviewer findings, not the author's stated evidence; claims in
a description are easy to accept once most of them check out.

**Suggested fix:** In Phase 1, when the description cites figures (counts, timestamps, "fails in env X but not Y"),
queue each as a claim to verify against primary data (CI API, logs, a scratch-worktree rerun). When pairing log events,
match the next *result* line by pattern, not the next physical line. Report mismatches as a body sentence or inline
suggestion.
