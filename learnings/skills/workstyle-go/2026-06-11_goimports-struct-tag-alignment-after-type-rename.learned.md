---
skill: wk-workstyle-go
date: 2026-06-11
type: correction
severity: medium
---

Widening a struct field's type name requires re-running goimports on the whole file, not just saving the changed line.

**What happened:** A Go struct field type was changed from `string` to a longer named type (e.g. a typed enum). The surrounding sibling fields' struct tags were aligned to the old, shorter type name. After the rename commit, the file still passed `gofmt` locally (editors typically run `gofmt` on save, which formats only individual lines). CI ran `goimports -l`, which realigns ALL struct-tag columns simultaneously — it failed because the remaining fields' tags were still at the old column offset.

**Root cause:** `gofmt` and `goimports` have different scopes for struct-tag alignment. `gofmt` will format a single statement in isolation; `goimports` recalculates the widest type name across the whole struct and realigns every field's tag column. An editor that runs `gofmt` (but not `goimports`) after a type rename produces a file that is locally clean but globally misaligned.

**Suggested fix:** After any commit that renames or widens a struct field's type, run `goimports -l <file>` explicitly before staging. Do not rely on editor format-on-save for this. If the project uses `goimports` in CI (the standard for Go projects with internal imports), the correct local command is:

```bash
goimports -local github.com/$GITHUB_ORG/<repo> -w <file>
```

Running `gofmt -w` alone is not sufficient after a struct field type change.
