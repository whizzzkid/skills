---
class: one-off
date: 2026-05-28
source:
  - ~/.claude/memory/feedback_awk_fi_anchor_regex.md
  - ~/.claude/memory/feedback_bash_n_false_positive.md
  - ~/.claude/memory/feedback_bats_grep_qv_false_positive.md
  - ~/.claude/memory/feedback_bats_line_comparison_grep_filter.md
severity: low
---

Bash/bats test cheatsheet — false-positive traps when asserting on shell scripts. Each is too narrow for SKILL.md; the meta-rule ("mutation-verify every new test") in `wk-testing-skeleton` already catches the failure mode generically.

- **`awk` range until `fi` / `done` / `esac`** — anchor the end pattern to a standalone line; bare `fi` matches "fix" inside string literals and terminates the range early:

  ```bash
  awk '/RETRY_NOUN=/,/^[[:space:]]*fi[[:space:]]*$/'
  ```

- **`bash -n` false positives on heredoc-in-`$(...)`-in-function** — `-n` is a static-analysis approximation and rejects some valid constructs. Verify shell syntax by sourcing in a subshell instead:

  ```bash
  bash -c 'source ./file.sh && echo OK'
  ```

- **`grep -qv 'pattern'` is a false-positive trap for negative assertions** — succeeds whenever *any* line in the input does not match the pattern. Use `! grep -q 'pattern'` for "pattern absent from input":

  ```bash
  # WRONG — passes trivially if any other line exists
  echo "$output" | grep -v 'EXCEPTION' | grep -qv 'exit 1'
  # CORRECT — fails if exit 1 appears anywhere
  ! echo "$output" | grep -q 'exit 1'
  ```

- **`grep -n 'VAR' | cut -d: -f1` for line-ordering assertions** — the first hit is often an `echo`/comment mentioning the variable, not the conditional itself. Add a secondary filter that anchors to the conditional syntax (`-z`, `unset`, `\[\[`, etc.) so `cut` returns the guard line.

- **Why not promoted:** All four are narrow bash/bats recipes that require verbatim commands; aggregating them into a single one-off reference avoids bloating `wk-testing-skeleton`'s SKILL.md with language-specific anti-patterns.
