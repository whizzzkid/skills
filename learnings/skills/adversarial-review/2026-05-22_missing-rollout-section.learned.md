---
skill: wk-adversarial-review
date: 2026-05-22
type: gap
severity: medium
---

Catch production-facing changes whose PR body lacks a rollout/operations section.

**Class:** Missing-rollout-section.

**Mechanism:** A PR replaces or modifies a production observability backend, API consumer, deployment pipeline, or other prod-facing surface, but the PR body lists only what changed in code — no rollback plan, no note about downstream dashboards/monitors/consumers that must migrate, no signal for how to confirm the change is healthy after merge. Reviewer bots (description-check) flag this; without the section, an outage during rollout can go unnoticed.

**Detection sketch:** In Step 2.10 (PR metadata sync), add a rollout-section check triggered by production-facing path patterns in the diff:

```bash
PROD_PATTERN='datadog|metrics|telemetry|deploy|migration|schema|api[_/]v[0-9]+|observability|prometheus|grafana|pager|on[-_]?call'
if git diff "$BASE...HEAD" --name-only | grep -iE "$PROD_PATTERN" > /dev/null; then
  BODY=$(gh pr view --json body --jq .body)
  echo "$BODY" | grep -iE 'rollout|rollback|operations|migration|monitoring|on[-_]?call|deploy plan' \
    || echo "BLOCKER: prod-facing diff missing rollout/ops section in PR body"
fi
```

Suggestion-level for internal-only telemetry, blocker for changes that affect customer-visible behavior or dashboards owned by other teams.

**Confidence:** high — mechanical path-pattern grep plus body check.
