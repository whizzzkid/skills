---
skill: wk-workstyle-go
date: 2026-06-03
type: gap
severity: medium
---

Always run `gofmt -l .` before committing — map literal alignment fails CI.

**What happened:** A map literal with unaligned values passed local tests but failed the CI lint step (`gofmt -l` check). The misalignment was introduced when writing a large `map[string]bool` by hand; gofmt reformats map values to align on the longest key.

**Root cause:** The wk-workstyle-go pass covers naming, error handling, and structure but does not include an explicit gofmt check step. The skill relies on the user's editor or pre-commit hook to catch formatting, which does not apply inside an agent session.

**Suggested fix:** Add an explicit `gofmt -l .` call to the pre-commit gate inside wk-workstyle-go. If any files are listed in the output, run `gofmt -w` on them before invoking wk-commit. Treat non-empty `gofmt -l` output as a blocking finding, not a suggestion.
