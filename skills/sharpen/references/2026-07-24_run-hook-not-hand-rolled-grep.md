---
class: principle
skill: wk-sharpen
date: 2026-07-24
severity: medium
---

- **Rule:** Run the owning hook script against the staged index instead of
  reimplementing its matcher. A hook's pattern file is config for *that* script, not
  a portable pattern list — it may carry `#` comment lines, PCRE inline flags
  (`(?i)`), and other matcher-specific constructs that only the owning script
  handles correctly. Hand-roll only what no hook covers (staged path strings — every
  content hook greps the diff and commit message, never filenames).
- **Why:** Feeding such a file to a different matcher fails in both directions.
  Comment lines fed to `grep -iEf` match every markdown heading, so the scan reports
  hits on `# Title` / `## Section` and buries any real hit in noise. And a probe
  token taken from the file's first line lands on the comment header — a comment line
  is itself a valid regex that matches its own text, so the probe "fires" while
  proving nothing, yielding a false-clean on a safety scan. Running each hook
  directly costs seconds, uses the hook's real semantics, and surfaces the true
  result before a failed-commit cycle.
- **Where:** Step 5, Mechanical overfit scan — replaced the two hand-rolled
  `grep -iEf` one-liners with a loop over `.githooks/*.sh`; escalated the bullet to
  `**CRITICAL**` (5th recurrence of hand-rolled-denylist-grep failures, prior refs:
  probe-regex-self-match, probe-token-must-match-patterns, sanity-check-from-list,
  scan-both-denylists). Retained the path-string scan and added the
  **non-comment, non-blank** qualifier to the residual probe rule.
