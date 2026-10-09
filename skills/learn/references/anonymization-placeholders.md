# Anonymization placeholders

Use when a token is unavoidable for legibility in a learning file:

- Bot / reviewer → `{bot}` / `{reviewer}`; human user → `{user}` / `{author}`; internal repo / project → `{repo}` /
  `{project}`; service → `{service}`.
- PR / issue number → `#NNN` (or `repo#NNN`); GitHub path → `pulls/{n}`, `issues/{n}`, `runs/{n}`. Capture the lesson,
  never the work-item ID.
- Employer/org token → `$EMPLOYER` / `$GITHUB_ORG`. Parameterize the **segment of a path**, keeping the rest:
  `$HOME/gitc/<employer>/` → `$HOME/gitc/$EMPLOYER` (agent resolves it at run time — do not drop the path).
- User-land path → repo-relative, or a generic placeholder (`/tmp/agent/…`).
