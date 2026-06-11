---
skill: wk-adversarial-review
date: 2026-06-11
type: gap
severity: medium
---

Struct tag column misalignment after field type rename silently passes gofmt but fails goimports CI.

**What happened:** A struct field's type was renamed from a short type (`string`) to a longer named type. The changed field's tag was updated but the sibling fields' tags remained aligned to the old (shorter) column width. `gofmt` passed locally; `goimports` in CI failed because it enforces struct-tag alignment across all fields simultaneously.

**Root cause:** The adversarial-review sweep checks for formatting issues at the code-logic level but does not include a `goimports -l` run after type-rename commits. Editor format-on-save often triggers `gofmt` (which formats the changed line) but not `goimports` (which realigns the whole struct). The gap only surfaces at CI.

**Suggested fix:** Add a sweep step: after any commit whose diff widens a struct field's type name, run `goimports -l <file>` and flag any output as a blocker before push. The detection command is mechanical and instant:
```bash
git diff "$BASE...HEAD" -- '*.go' | grep -nE '^\+[[:space:]]+[A-Z][A-Za-z]+[[:space:]]+[A-Z][A-Za-z]+[[:space:]]' \
  | awk -F: '{print $1}' | sort -u | xargs -I{} goimports -local "$MODULE" -l {}
```
Any file listed in the output must be formatted before the push is cleared.
