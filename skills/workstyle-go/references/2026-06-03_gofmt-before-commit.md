---
class: principle
---

- **Rule:** Run `gofmt -l .` before `wk-commit` on any `.go` change; non-empty output is a blocking finding — `gofmt -w` the listed files and re-check clean.
- **Why:** `gofmt` aligns map-literal values on the longest key; a hand-written map passes local tests but fails CI's `gofmt -l` check. Editor/pre-commit-hook formatting does not apply inside an agent session.
- **Where:** New "Pre-Commit Gate" section in wk-workstyle-go.
