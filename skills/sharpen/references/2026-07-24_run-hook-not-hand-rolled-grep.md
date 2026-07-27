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
- **Why:** The pattern file is gitignored and machine-local (only a `.example` ships),
  so its comment style and matcher-specific constructs vary per checkout — whether any
  given mis-handling applies is unknowable from the skill, which is itself the reason to
  run the hook rather than audit the file.
  - **Engine shadowing is the mechanism that always applies.** The agent's `grep` may be
    a shell function or alias routing to a different implementation, so identical flags
    do not mean identical semantics: a hand-rolled `grep -iEf` can return **rc=1 with no
    stderr** on a term the owning hook flags. Invoke `command grep` to bypass the
    shadow, and still prove the scan with a canary.
  - **Correction (verified against source):** the earlier claim that comment lines
    "match every markdown heading" is *conditional, not general*, and is false for this
    repo's live denylist — its comments are full sentences that, as EREs, match only
    their own literal text; a heading fed through them does not fire while a real listed
    term does. The noise mode needs bare `#` comment lines to occur. The companion claim
    that a comment line always self-matches is likewise conditional — it holds for a
    plain-prose comment but fails once the line contains regex metacharacters (`(`…`)`
    parse as a group, not literals).
  - Running each hook directly costs seconds, uses the hook's real semantics, and
    surfaces the true result before a failed-commit cycle.
- **Where:** Step 5, Mechanical overfit scan — replaced the two hand-rolled
  `grep -iEf` one-liners with a loop over `.githooks/*.sh`; escalated the bullet to
  `**CRITICAL**` (5th recurrence of hand-rolled-denylist-grep failures, prior refs:
  probe-regex-self-match, probe-token-must-match-patterns, sanity-check-from-list,
  scan-both-denylists). Retained the path-string scan and added the
  **non-comment, non-blank** qualifier to the residual probe rule.
