---
skill: wk-workstyle-go
date: 2026-06-12
type: gap
severity: medium
---

Re-run gofmt after REMOVING struct tags, not just after adding/widening them.

**What happened:** A commit dropped `json:"..."` tags from three struct fields that carried trailing inline comments. The comments stayed aligned to the now-gone tag column. gofmt collapses such comments to single-space; the file passed the gofmt check run BEFORE the tag-removal edit, so the misalignment shipped and CI's gofmt gate failed.

**Root cause:** The pre-commit gofmt gate was satisfied at an earlier point in the session, then a later edit changed field/tag layout without a re-run. The existing skill rule covers goimports after type WIDENING but not tag REMOVAL, which also shifts the comment-alignment column.

**Suggested fix:** Generalize the Go pre-commit gate: run `gofmt -l` immediately before EVERY commit that touched a `.go` file, regardless of what the edit was — adding, widening, OR removing a struct tag all change gofmt's alignment columns. The gate is per-commit, not per-session; a clean check earlier does not carry forward past the next edit.
