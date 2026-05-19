---
skill: wk-adversarial-review
date: 2026-05-19
type: gap
severity: high
---

Rebase conflict resolution can silently keep callers while dropping definitions.

**What happened:** A PR branch was rebased onto main. The branch's refactor
commit had inlined formatting logic, removing helper methods. Main's earlier
commit added those same helpers (`severity_emoji`, `severity_sort_key`,
`format_check_label_from`, `SEVERITY_ORDER`). The rebase conflict resolution
kept the HEAD callers (the main-side callers) but the branch's own commit
removed the definitions. Result: file compiled (Ruby is dynamic), tests
failed with `NoMethodError`.

**Root cause:** Conflict resolution checked the call-sites but not the
definition set. The adversarial pre-flight sweep (2.7 signature widening,
2.15 workstyle) did not include a grep-for-callers-vs-definitions pass
for dynamic languages.

**Suggested fix:** Add sweep 2.16-equiv for dynamic language (Ruby, Python,
JS) method call/definition cross-check: for every method call in the diff's
kept lines, grep the file for a `def <method_name>` definition. Flag any
call whose definition does not appear in the file. Pairs with the existing
signature-widening sweep (2.7) to cover the inverse case.
