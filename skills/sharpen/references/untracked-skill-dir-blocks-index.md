---
class: principle
---

**Rule** — When `check-readme-index` blocks a scoped sharpen commit because of an untracked `skills/<name>/` directory this run did not create, do not `git add` or index it. Move it aside (`mv skills/<name> /tmp/agent/...`), land the scoped commit, push, then restore it untouched.

**Why** — The hook scans the whole `skills/` filesystem tree, not the staged set, so any untracked skill dir left by another session fails it. Authoring index rows for another session's incomplete skill is scope creep and likely wrong; committing it bundles unrelated work.

**Where** — Step 8 commit gate. The hook compares index files against on-disk dirs, independent of what this commit stages.
