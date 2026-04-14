# Claude Code Instructions

See [AGENTS.md](AGENTS.md) for project conventions and workflow rules.

## Post-Change Hook

After adding or updating any skill, always run:

```bash
npx skills add . -g -y -a=claude
```

This reinstalls all skills globally for the agent. Never skip this step.
