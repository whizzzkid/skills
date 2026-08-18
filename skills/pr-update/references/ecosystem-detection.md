---
class: reference
---

# Ecosystem detection — lockfiles, test commands, install order

Catalog for Stage 5's dependency install pre-check and Stage 4's lockfile-conflict
resolution. Extend per project; first hit wins.

## Lockfile names

`Gemfile.lock`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `Cargo.lock`,
`poetry.lock`, `uv.lock`, `go.sum`.

```bash
for lockfile in Gemfile.lock package-lock.json yarn.lock pnpm-lock.yaml \
                Cargo.lock poetry.lock uv.lock go.sum; do
  [ -f "$lockfile" ] || continue
  if ! git diff --quiet "$START_SHA"..HEAD -- "$lockfile"; then
    echo "Lockfile changed: $lockfile — install before validating."
    # Run the project's install command (bundle install, npm ci, cargo fetch, etc.)
    break
  fi
done
```

## Test-command signals

- `package.json` `scripts.test` → `npm test`
- `pyproject.toml` `[tool.pytest]` / `pytest.ini` → `pytest`
- `Cargo.toml` → `cargo test`
- `Gemfile` + `spec/` → `bundle exec rspec`
- `go.mod` → `go test ./...`
- `.buildkite/` or CI config naming a test step → run that step locally via the
  project's task runner if available

## Example invocation

```bash
# Example for a Node project
npm test 2>&1 | tail -20
npm run typecheck 2>&1 | tail -10  # if defined
```
