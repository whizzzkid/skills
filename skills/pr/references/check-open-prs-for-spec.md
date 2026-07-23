---
class: principle
---

# Check open PRs for a related spec before adding a new one

**Rule** — When this branch adds a doc under `docs/specs/` (or equivalent),
search open PRs for a spec in the same domain before treating the new doc as
standalone — a parallel spec in another in-flight PR forces a later
merge/consolidation request.

```bash
gh pr list --state open --json number,files \
  --jq '.[] | {number, specs: [.files[].path | select(test("docs/specs"))]}' \
  | grep -v '"specs":\[\]'
```

- Open PR carries a spec for the same feature/domain → prefer stacking onto it
  (extend the existing spec) over adding a parallel doc. Surface the overlap to
  the user with both PR links.
- Reuses the open-PR list already fetched for base detection — no extra round
  trip.

**Why** — a parallel spec discovered only at review time forces a costly
consolidation or a superseding PR.

**Where** — Step 1, after base detection, when the branch adds a spec doc.
