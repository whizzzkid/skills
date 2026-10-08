# PR Body Template Resolution

Before composing the PR body, check the target repo for a GitHub PR template.
Search these paths in order, use the first match:

```bash
TEMPLATE_FILE=""
for tpl in \
  .github/pull_request_template.md \
  .github/PULL_REQUEST_TEMPLATE.md \
  pull_request_template.md \
  PULL_REQUEST_TEMPLATE.md; do
  [ -f "$tpl" ] && TEMPLATE_FILE="$tpl" && break
done

# If no single file matched, check the multi-template directory
if [ -z "$TEMPLATE_FILE" ]; then
  for d in .github/PULL_REQUEST_TEMPLATE .github/pull_request_template; do
    [ -d "$d" ] && ls "$d"/*.md && break
  done
fi
```

| Scenario | Action |
|----------|--------|
| Single template file found | Read it and use as the PR body structure |
| Template directory found | List the `.md` files, ask the user which to use, then read it |
| No template found | Fall back to the hardcoded templates below |

## When using a repo template

- **Populate every section** with real content derived from the diff and commit
  history. No placeholder text or unfilled sections.
- **Preserve the template's structure** — keep its headings, order, and any
  boilerplate (checkboxes, legal text, etc.) intact.
- **Stacked PRs** → append a `## Stack` section after the summary (or first
  heading) if the template does not already include one.
- Template sections irrelevant to the current changes → fill with "N/A" or a
  brief note explaining why they don't apply.
- **Guarantee a verification section.** After populating, confirm a Testing /
  Test plan / verification section exists. If none, append `## Testing` listing
  concrete checks run (commands + outcomes: linters/formatters clean, hooks run
  locally, CI/pipeline template render, manual steps). Treat a missing
  verification section as drift to fix before `gh pr create` — a
  description-check bot otherwise flags "Testing section missing" and forces a
  second cycle.
- **Prod-facing diff & incident-triggered bugfix bodies** have extra required
  sections — see [`pr-body-extras.md`](pr-body-extras.md); apply at composition time.
