---
skill: wk-adversarial-review
date: 2026-06-10
type: gap
severity: high
---

After fixing source code that has a committed compiled artifact, include a rebuild step before clearing.

**What happened:** Adversarial review found a bug in a Go source file and the fix was committed. The committed WASM binary (built from that source) was not rebuilt. CI caught the stale artifact via a freshness check, causing a one-round CI failure after the "clear" verdict.

**Root cause:** The adversarial review skill clears on source correctness but has no step that checks whether any committed compiled artifact (WASM, embedded binary, generated code) must be regenerated after the fix lands. The fix-and-commit path ends without a "rebuild artifacts" reminder.

**Suggested fix:** After fixing any source file, grep the diff for file types that indicate a committed compiled artifact exists (`.wasm`, build output mentioned in `.gitignore` exceptions, `//go:generate`, `go:embed` targets). For each hit, add an explicit "rebuild and re-commit" step to the fix plan before issuing the clear verdict.
