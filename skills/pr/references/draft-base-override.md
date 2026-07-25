---
skill: wk-pr
class: principle
---

**Rule** — Before defaulting base-detection choice **A** (stack on `$BEST_BASE`), check
whether `$BEST_BASE` is the head of an open PR still in **draft** state:

```bash
DRAFT=$(gh pr list --state open --head "$BEST_BASE" \
          --json isDraft --jq '.[0].isDraft')
```

`DRAFT == true` → surface the draft status in the prompt and default auto mode to **B**
(retarget to `$DEFAULT_BRANCH`, include both changesets). Stacking on a draft base
requires explicit user opt-in.

**Why** — A draft parent has not merged, so stacking produces two PRs the reviewer must
sequence — usually a false split where both changesets should land together.

**Where** — wk-pr Step 1, base-detection choice prompt.
