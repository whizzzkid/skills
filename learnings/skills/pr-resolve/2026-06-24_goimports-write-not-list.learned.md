---
skill: wk-pr-resolve
date: 2026-06-24
type: gap
severity: medium
---

After checking Go import formatting with `goimports -l`, always run `goimports -w` to apply fixes before staging.

**What happened:** Ran `goimports -l <pkg>/<file>` to verify import formatting after writing a new Go test file — the check returned no output (clean). CI's format gate runs the equivalent of `-w` and flags trailing comment alignment issues that `-l` also catches but that the agent did not apply. The goimports violation was committed and CI failed.

**Root cause:** `-l` lists files with violations; it does not fix them. The agent used `-l` as a confirmation gate ("no output = clean") but the file had been reformatted by `goimports -w` in a prior step, and the new file written in this session was never run through `-w`. The two steps look similar but have different semantics.

**Suggested fix:** After writing or editing any Go file, always run `goimports -local <module> -w <file>` (not just `-l`) before staging. The `-l` check is redundant when `-w` has already been applied — drop the `-l` check and use `-w` exclusively as the pre-stage step for Go files.
