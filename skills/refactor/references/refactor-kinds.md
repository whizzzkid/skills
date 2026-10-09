# Refactor kinds and expected diff shapes

| Kind | Detect via | Expected diff shape |
|------|------------|---------------------|
| **extract-helper** | New file/function appears; existing call site shrinks | Caller: roughly net-zero LOC (inline code → one call). Helper file: net-positive matching what was removed. |
| **move-file** | `git diff -M` reports rename/move; content nearly unchanged | Net-zero overall; rename detection should flag it. |
| **rename** (symbol or path) | One identifier replaced by another across many files | Strictly substitution; no logic changes. |
| **split-file** | One file replaced by N smaller files | Source net-removed; new files net-added; sum ≈ 0. |
| **pure-rebase** | Same commits, different parent | Diff against new parent equals diff against old parent (modulo conflict resolutions). |
| **inline-helper** | Helper file removed; call sites grow | Inverse of extract-helper. |
| **collapse / merge files** | Two+ files become one | Sources net-removed; target net-added; sum ≈ 0. |
