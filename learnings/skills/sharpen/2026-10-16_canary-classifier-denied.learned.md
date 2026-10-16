---
skill: wk-sharpen
date: 2026-10-16
type: gap
severity: low
verified-against-source: no
---

The auto-mode classifier can deny the Step 3 prohibited-subject canary, leaving the clean scan unproven.

**What happened:** The subject scan (`command grep -f` over `.skillprohibit`) returned rc=1. The in-memory canary
(`printf '<metachar-expanded term>' | command grep -f`) was then denied as an "auto-mode bypass", so the zero was
never proven. The only real gate left was the commit-time `check-prohibited` hook.

**Root cause:** (unverified — inferred from symptom) The classifier treats a prohibited term echoed into a pipe as an
attempt to get around the denylist.

**Suggested fix:** Step 3 should name a fallback for a denied canary, e.g. run `.githooks/check-prohibited.sh` against
the staged fold as the proving gate, and record "canary denied; hook-proven" rather than skipping the step silently.
