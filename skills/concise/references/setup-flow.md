# First-Run Setup Flow

Hooks live in `$HOME/.claude/settings.json` (harness config, not a skill file). `npx skills add` writes skill files but cannot touch `settings.json` → this skill **self-installs on first invocation**.

## Detect

On every `/concise`, `/concise brief`, `/concise dense`, or natural-language activation, before confirming the mode, run:

```bash
SETTINGS="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json"
grep -Fq "concise-reminder.sh" "$SETTINGS" 2>/dev/null && HOOK_INSTALLED=1 || HOOK_INSTALLED=0
grep -Fq "Concise by default" "$HOME/.claude/CLAUDE.md" 2>/dev/null && SNIPPET_INSTALLED=1 || SNIPPET_INSTALLED=0
```

## Offer

If `HOOK_INSTALLED=0` **or** `SNIPPET_INSTALLED=0`, emit a one-time offer (mark `$HOME/.claude/.concise-setup-offered` after so it doesn't re-ask):

> `wk-concise — first-run setup`
>
> To make brief mode the default for every session, I can wire up:
> - [{snippet_state}] `$HOME/.claude/CLAUDE.md` — opt-in-by-default across all agents
> - [{hook_state}] `$HOME/.claude/settings.json` — per-turn reinforcement hook (Claude Code)
>
> Apply both? `(y)es / (n)o / (s)nippet only / (h)ook only`

`{snippet_state}` / `{hook_state}` = `✓ already installed` or ` ` (pending).

## Apply

On the user's answer: invoke `wk-update-config` (for the `settings.json` edit) and append `templates/claude-md-snippet.md` to `$HOME/.claude/CLAUDE.md`. `wk-update-config` handles merge, validates JSON, reports result. Write `$HOME/.claude/.concise-setup-offered` after applying (one-time guard). Re-trigger via `/concise:setup`.

## Default Activation

Enable concise globally so every session starts in `brief` mode. Three stackable mechanisms — first-run setup offers to install them automatically; `/concise:setup` re-runs if needed.

### Mechanism 1: CLAUDE.md / AGENTS.md snippet (works everywhere)

Paste `templates/claude-md-snippet.md` into one of:

- `$HOME/.claude/CLAUDE.md` — global, all Claude Code sessions
- `$HOME/.agents/AGENTS.md` — cross-agent global
- `<repo>/CLAUDE.md` or `<repo>/AGENTS.md` — per-project
- `$HOME/.gemini/GEMINI.md`, `.cursor/rules/concise.md`, etc. — agent-specific

No hook, no code — just prose the model reads at session start.

### Mechanism 2: UserPromptSubmit hook (Claude Code, per-turn reinforcement)

Add to `$HOME/.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.agents/skills/wk-concise/hooks/concise-reminder.sh"
          }
        ]
      }
    ]
  }
}
```

Reads mode from `$HOME/.claude/.concise-mode` (default: `brief`), emits a 1-line reminder into agent context. Silent-fail on I/O error — never blocks a session.

### Mechanism 3: Mode file (single source of truth)

```bash
echo "dense" > $HOME/.claude/.concise-mode   # Start in dense mode globally
echo "brief" > $HOME/.claude/.concise-mode   # Revert to brief (default)
```
