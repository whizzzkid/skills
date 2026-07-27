---
skill: wk-git
date: 2026-07-25
type: pattern
severity: medium
verified-against-source: yes
---

`GIT_INDEX_FILE` pointed at a copy of `.git/index` runs any staged-content check with real semantics while leaving the real index untouched.

**What happened:** A pre-commit gate needed every `.githooks/check-*.sh` run against
a set of edits, but those hooks read `git diff --cached` / `git show ":<path>"`, so
they only see **staged** content. The real index already held a different, unrelated
path-scoped change being prepared for its own commit. `git add`-ing the new edits to
measure and scan them would have merged two logically separate commits into one index
and destroyed that separation — while *not* staging meant every hook reported a
vacuous pass on an empty diff.

Copying the index and redirecting git at the copy resolved both:

```bash
cp .git/index /tmp/agent/probe-index
GIT_INDEX_FILE=/tmp/agent/probe-index git add <paths>
GIT_INDEX_FILE=/tmp/agent/probe-index <hook>   # real matcher, real staged blobs
```

Verified: the probe index listed the pre-existing staged paths plus the new ones,
while `git diff --cached` against the real index still listed only the originals.

**Root cause:** `git add` and every `--cached` read resolve the index through
`GIT_INDEX_FILE`, defaulting to `.git/index` only when the variable is unset. Nothing
about staging requires mutating the repository's own index, but the common idiom
(`git add` then run the check) conflates "make content visible to a staged-content
reader" with "assemble the next commit" — two separable operations.

**Suggested fix:** When a check reads staged content but staging would disturb an
in-progress index, copy the index, export `GIT_INDEX_FILE` at the copy, and stage
there. Prefer this over three worse options: staging into the real index and resetting
afterward (loses the original staged/unstaged partition, since `git reset` cannot
restore which paths were staged), hand-reimplementing the check against the working
tree (diverges from the real matcher), or skipping the check. Delete the copy when
done and `unset GIT_INDEX_FILE` before any later git call, or subsequent commands
silently keep using the throwaway index.
