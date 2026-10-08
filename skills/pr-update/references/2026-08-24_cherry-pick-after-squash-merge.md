---
class: principle
---

# Cherry-pick after squash-merge

**Rule** — When a stacked PR's parent was squash-merged, cherry-pick the child's
commits onto the post-squash base instead of rebasing. Rebase replays each commit
against the squash delta, producing conflicts on every line the squash touched;
cherry-pick skips the delta because the base already includes the squashed content.

**Why** — Rebase-through-squash generates N conflicts (one per commit) on lines that
are semantically already resolved; cherry-pick avoids all of them.

**Where** — `SKILL.md` → Stage 3b → *Squash-merged parent → cherry-pick over rebase*.
