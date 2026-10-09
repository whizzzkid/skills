# Mise Tool Patterns

## Running commands with mise context

**Single command:**
```bash
mise exec -- <command> [args...]
```

**Examples:**
```bash
mise exec -- node --version
mise exec -- npm install
mise exec -- bundle exec rspec
mise exec -- python -m pytest
mise exec -- go build ./...
mise exec -- bun run dev
```

**Explicit tool version:**
```bash
mise exec node@{version} -- node --version
```

**Multi-tool script:**
```bash
mise exec -- bash -c 'npm ci && npm run build && npm test'
```

## Checking and installing tools

| Task | Command |
|------|---------|
| See what's installed vs. required | `mise ls` |
| Install project tools | `mise install` |
| Pin a tool version (project) | `mise use node@{version}` |
| Pin a tool version (global) | `mise use --global node@{version}` |
| List available versions | `mise ls-remote node` |
| Filter to major | `mise ls-remote node \| grep "^22\\."` |

Always pin to exact version -- never `latest` or `lts`.

## Configuration files

### `.mise.toml` (preferred)
```toml
[tools]
node = "{version}"
ruby = "{version}"
python = "{version}"
go = "{version}"
```

### `.tool-versions` (legacy asdf format)
```
node {version}
ruby {version}
python {version}
```

When both exist, `.mise.toml` takes precedence.

## Trust issues

```bash
mise trust            # trust .mise.toml in current directory
mise trust --all      # trust all configs (use with caution)
```

## Git hooks and mise

When a repo uses git hooks (lefthook, husky, pre-commit) that call
mise-managed binaries, hooks fail with exit 127 -- shims directory not on PATH
in non-interactive shells.

**Before `git push`/`git commit` in a mise-managed repo:**
```bash
eval "$(mise activate bash)" && git push
```
