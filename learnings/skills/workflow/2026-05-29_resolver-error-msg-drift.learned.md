---
skill: wk-workflow
date: 2026-05-29
type: gap
severity: medium
---

Audit error message strings when replacing a constant with a resolver function.

**What happened:** A hardcoded constant (e.g. `repoConfigPath = ".{repo}/config.yaml"`) was replaced by a resolver that returns a dynamic path. Several `fmt.Sprintf` calls that previously referenced the constant were updated correctly, but one error message in a sibling function still contained the literal string `.{repo}/config.yaml` rather than using the resolver's return value — causing `.yml` users to see a misleading filename in error output.

**Root cause:** The refactor search focused on usages of the constant identifier, not on usages of its string value. `grep repoConfigPath` found the symbol references; it missed the hardcoded string copy in the `Sprintf` body.

**Suggested fix:** When replacing any named constant with a resolver/function, run a secondary grep for the constant's *literal value* (not just its identifier) across all files in scope. Any hit that isn't a comment or test fixture must use the resolver's return value instead.
