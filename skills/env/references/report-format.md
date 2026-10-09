# wk-env Report Format

Print exactly this shape — secret-shaped values as fingerprints only:

```
wk-env report
─────────────────────────────────────────────────────────
SKILL: {name} (or "session default" if no skill given)
─────────────────────────────────────────────────────────
✅  WK_SKILLS_HOME = /path/to/skills
✅  GITHUB_ORG     = org-name
✅  REGISTRY_TOKEN = <len 40 sha 1a2b3c4d>   (secret-shaped: never printed)
⚠️  MY_VAR         → resolved after sourcing $HOME/.profile
                      (restart Claude Code from a shell that sources $HOME/.profile)
❌  OTHER_VAR      → still missing after sourcing $HOME/.profile
                      (add to $HOME/.profile: export OTHER_VAR=<value>)
─────────────────────────────────────────────────────────
```
