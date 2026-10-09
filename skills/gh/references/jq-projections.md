# Variable-dependent jq projections

- `gh --jq` accepts one expression and no standalone `jq` flags (`--arg`, `--argjson`).
- Constant projection → keep `gh --jq`:

  ```bash
  gh pr view --json headRefOid --jq '.headRefOid'
  ```

- Projection needs shell values → pipe raw `--json` to standalone `jq`:

  ```bash
  gh pr view --json headRefOid \
    | jq --arg expected "$expected_sha" 'select(.headRefOid == $expected)'
  ```

- Quote complete `gh api` endpoints containing shell metacharacters (`?`, `&`, `*`) → prevent zsh globbing.
