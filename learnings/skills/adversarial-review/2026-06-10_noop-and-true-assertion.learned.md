---
skill: wk-adversarial-review
date: 2026-06-10
type: gap
severity: high
---

No-op bats test assertion: `|| <check> && true` always succeeds

**What happened:** A behavioral bats test for a fail-soft error path contained the assertion `echo "$output" | grep -q 'PATTERN=$' || echo "$output" | grep -q 'PATTERN=' && true`. Due to bash operator precedence (`||` and `&&` are left-associative with equal precedence), the trailing `&& true` forces the entire compound command to exit 0 regardless of whether any grep matched. The test could never fail.

**Root cause:** The `&& true` was meant to suppress a non-zero exit from the first `||` branch, but it also suppresses failure from the entire compound. The correct pattern is `grep -q 'PATTERN' || (echo "diagnostic" && false)` — the inner `false` propagates as the compound's exit status.

**Suggested fix:** Add to the mechanical sweep in Step 2 (sweep 2.15 workstyle pass or a dedicated sweep): grep new and modified `*.bats` / `*_spec.*` / `*_test.*` files for `&& true` on lines that also contain `||`. Each hit is a candidate no-op assertion — verify the author's intent and rewrite as an explicit fail-path `|| (echo "..." && false)`.

Detection command:
```bash
git diff "$BASE...HEAD" -- '*.bats' '*_test.*' '*_spec.*' \
  | grep -nE '^\+.*\|\|.*&& true'
```

Confidence: high (mechanical detection possible).
