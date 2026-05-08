---
name: wk-concise
description: >-
  Reduce response verbosity and token usage. Drops articles, filler, hedging,
  and pleasantries from agent replies while preserving technical accuracy.
  Use when starting a session where you want shorter, denser output, or when
  asked to "be brief", "less words", "reduce tokens", or "compress context".
  Also provides /concise:compress to rewrite verbose docs/memory files using
  the same rules — no binary dependencies required.
argument-hint: '[brief|dense|off|compress <target>|setup]'
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - AskUserQuestion
  - Skill
model: sonnet
effort: low
model-invocable: true
user-invocable: true
license: MIT
metadata:
  author: whizzzkid
  version: '2026.05.08-182836'
  internal: false
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# Concise

Cut response verbosity. Same information. Fewer words.

Three modes: **brief** (default), **dense**, **off**.

---

## Activation

| Invocation | Effect |
|-----------|--------|
| `/concise` | Enable brief mode for this session + write `~/.claude/.concise-mode` |
| `/concise brief` | Enable brief mode (explicit) |
| `/concise dense` | Enable dense mode |
| `/concise off` | Disable — remove `~/.claude/.concise-mode` and touch `~/.claude/.concise-off` |
| `/concise:compress <path or paste>` | Rewrite a file or block using active mode rules |
| `/concise:setup` | Re-run first-run setup flow (detect + offer to install hook and CLAUDE.md snippet) |

Natural language triggers: "be brief", "less words", "reduce tokens",
"shorter responses", "compress context", "stop being verbose".

On activation, the skill writes the mode to `~/.claude/.concise-mode` and
confirms in one line:
> `Concise mode: brief. Active for this session (and future, via mode file).`

For how to make the skill active by default across all sessions and
agents, see **Default Activation** below.

---

## Mode Rules

### brief (default)

**Remove:**
- Pleasantries: "Sure!", "Happy to help!", "Certainly!", "Of course!", "Great question!"
- Hedging: "it might be worth", "you could consider", "perhaps", "I think", "it seems"
- Filler: "just", "really", "basically", "actually", "essentially", "simply", "generally"
- Redundant phrasing: "in order to" → "to"; "make sure to" → [drop]; "the reason is because" → "because"
- Fluff connectors: "However,", "Furthermore,", "Additionally," (at line start — cut or use "Also")

**Keep:** Full sentences, articles (a/an/the), normal grammar. Professional but tight.

**Hard caps (brief):**

- **≤3 sentences** per answer unless the answer is code, a diff, or a
  safety warning. Multi-step procedures still need ≤3 sentences of
  prose around the code; the code itself is exempt.
- **No tables for ≤3 items** — write a sentence ("X (foo), Y (bar),
  Z (baz)"). Tables are for ≥4 row × ≥2 column comparisons.
- **No section headers for single-section answers.** Headers are for
  navigation; if there's nothing to navigate to, drop them.
- **No trailing summary, no recap, no "let me know if".** End on the
  result.

These caps are surfaced per-turn by the `concise-reminder.sh` hook so
they stay top of mind even when the agent's defaults pull toward
chattiness.

**Format:** Prefer bullets over paragraphs for multi-part answers.

Example (before/after):

> ❌ "Sure! I'd be happy to help with that. The issue you're experiencing is likely caused by a missing null check. You might want to consider adding a guard before accessing the email property."
>
> ✅ "Missing null check — add guard before `.email`."

---

### dense

Everything in **brief**, plus:

**Remove:**
- Articles in procedural/list contexts: "a", "an", "the" (when removal preserves meaning)
- Subjects that are obvious from context ("you should" → drop; "it is" → drop)

**Add:**
- Fragments are valid: "Run tests first." not "You should run the tests first."
- Causality arrows: `X → Y` instead of "X causes Y" or "X leads to Y"
- Short synonyms: use / big / fix / slow / show / need / check / make (not utilize / extensive / implement / performance bottleneck / display / require / verify / create)

Example:

> ❌ "New object reference is created on each render. The inline object prop triggers a new reference. Wrap in `useMemo`."
>
> ✅ "Inline obj prop → new ref each render. Wrap in `useMemo`."

---

## Hard Boundaries — Never Compress

Regardless of mode, always write these at full verbosity:

1. **Code blocks** — never alter fenced ` ``` ` or inline `` ` `` content
2. **Security warnings** — e.g., "This will permanently delete…", "This cannot be undone…"
3. **Irreversible action confirmations** — destructive git ops, production deploys, file deletions
4. **Technical terms** — library names, API names, flags, env vars, version numbers, file paths, URLs
5. **Error messages** — reproduce exact error text; never paraphrase
6. **When the user asks to clarify** — drop mode temporarily, explain fully.
   Resume concise mode only when the user's next message is clearly a new
   task, not a follow-up clarification. Never auto-resume mid-clarification
   thread.

---

## First-Run Setup (self-installing)

Hooks live in `~/.claude/settings.json` — the harness config, not a skill
file. `npx skills add` writes skill files but cannot touch `settings.json`.
To close the gap, this skill **self-installs on first invocation**.

### Detect

On every `/concise`, `/concise brief`, `/concise dense`, or natural-language
activation, before confirming the mode, run:

```bash
SETTINGS="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json"
grep -Fq "concise-reminder.sh" "$SETTINGS" 2>/dev/null && HOOK_INSTALLED=1 || HOOK_INSTALLED=0
grep -Fq "Concise by default" "$HOME/.claude/CLAUDE.md" 2>/dev/null && SNIPPET_INSTALLED=1 || SNIPPET_INSTALLED=0
```

### Offer

If `HOOK_INSTALLED=0` **or** `SNIPPET_INSTALLED=0`, emit a one-time offer
(mark `~/.claude/.concise-setup-offered` after so it doesn't re-ask):

> `wk-concise — first-run setup`
>
> To make brief mode the default for every session, I can wire up:
> - [{snippet_state}] `~/.claude/CLAUDE.md` — opt-in-by-default across all agents
> - [{hook_state}] `~/.claude/settings.json` — per-turn reinforcement hook (Claude Code)
>
> Apply both? `(y)es / (n)o / (s)nippet only / (h)ook only`

`{snippet_state}` / `{hook_state}` = `✓ already installed` or ` ` (pending).

### Apply

On the user's answer, invoke `wk-update-config` (for the `settings.json` edit)
and append `templates/claude-md-snippet.md` to `~/.claude/CLAUDE.md`.
`wk-update-config` handles merge, validates JSON, reports result.
Write `~/.claude/.concise-setup-offered` after applying (one-time guard).
User can re-trigger via `/concise:setup`.

---

## Default Activation

Enable concise globally so every session starts in `brief` mode. Three
stackable mechanisms — the first-run setup flow offers to install them
automatically; use `/concise:setup` to re-run if needed.

### Mechanism 1: CLAUDE.md / AGENTS.md snippet (works everywhere)

Paste `templates/claude-md-snippet.md` into one of:

- `~/.claude/CLAUDE.md` — global, all Claude Code sessions
- `~/.agents/AGENTS.md` — cross-agent global
- `<repo>/CLAUDE.md` or `<repo>/AGENTS.md` — per-project
- `~/.gemini/GEMINI.md`, `.cursor/rules/concise.md`, etc. — agent-specific

No hook, no code — just prose the model reads at session start.

### Mechanism 2: UserPromptSubmit hook (Claude Code, per-turn reinforcement)

Add to `~/.claude/settings.json`:

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

Reads mode from `~/.claude/.concise-mode` (default: `brief`), emits a 1-line
reminder into agent context. Silent-fail on I/O error — never blocks a session.

### Mechanism 3: Mode file (single source of truth)

```bash
echo "dense" > ~/.claude/.concise-mode   # Start in dense mode globally
echo "brief" > ~/.claude/.concise-mode   # Revert to brief (default)
```

## Opt-Out

Any of these disables concise mode without removing the skill:

| Action | Scope |
|--------|-------|
| `/concise off` | Current session |
| `touch ~/.claude/.concise-off` | All future sessions until removed |
| `export CONCISE_OFF=1` | Current shell's sessions |
| Remove the snippet from `CLAUDE.md` | Permanent |

Opt-out precedence (hook evaluates top-to-bottom): `$CONCISE_OFF=1` →
`~/.claude/.concise-off` exists → `~/.claude/.concise-mode` = "off".

Confirm deactivation: `Normal mode restored. Opt back in with /concise (or remove ~/.claude/.concise-off).`

## Session Persistence Summary

| Setup | Default at session start | Survives restart? |
|-------|-------------------------|-------------------|
| Skill installed, nothing else | `off` (must invoke) | No |
| CLAUDE.md snippet added | `brief` | Yes |
| CLAUDE.md + hook + `.concise-mode=dense` | `dense` | Yes |
| `.concise-off` flag touched | `off` | Yes (until removed) |

---

## `/concise:compress` — Context Compression

Rewrites a verbose text block or file using the active mode's rules. No binary,
no Python — the LLM applies the rules and returns a diff for review.

### Usage

```
/concise:compress                    # paste text after invocation
/concise:compress path/to/file.md    # reads file, rewrites in-place after approval
```

### Default mode for compress

If no mode is active when `/concise:compress` is invoked, default to `brief`
and state it: `No mode active — using brief for compression.`

### Process

1. Read the target (pasted block or file path).
2. Apply the active mode's rules. Preserve **exactly**:
   - All fenced code blocks (content unchanged byte-for-byte)
   - All inline code
   - All URLs, file paths, commands, env vars, version numbers
   - Markdown heading structure and hierarchy
   - Table structure (rows/columns intact; cell prose may compress)
   - Bullet hierarchy
3. Show a side-by-side summary:
   ```
   Original: ~{N} tokens (estimated)
   Compressed: ~{M} tokens (estimated)
   Reduction: ~{X}%

   [compressed text]
   ```
4. Ask: **Apply?** `(y)es / (n)o / (e)dit first`
5. On `y` — write the file (if path given) or print final text.
6. On `n` — discard.
7. On `e` — open in-line edit loop.

### What to compress

Good targets for `/concise:compress`:
- `~/.claude/CLAUDE.md` — global agent instructions
- Memory files in `~/.claude/memory/*.md`
- Skill `SKILL.md` files (non-procedural sections only)
- Meeting notes, spec docs with heavy prose

Bad targets — **refuse with error, do not compress**:
- Files with >50% code content (`.py`, `.ts`, `.rb`, `.go`, `.rs`, etc.)
- Files matching: `*.pem`, `*.key`, `*.p12`, `*.pfx`, `*.env`, `.env*`
- Files whose name matches: `credentials*`, `secrets*`, `*password*`, `*apikey*`, `*token*`
- Files under any of these path components: `.ssh/`, `.aws/`, `.gnupg/`,
  `.kube/`, `.config/gcloud/`, `.docker/`
- Symlinks (resolve and check before reading; refuse if target is outside
  the working directory or home directory prose files)

---

## Quick Reference

| Trigger | Mode | Action |
|---------|------|--------|
| `/concise` | brief | Drop filler/hedging, keep grammar |
| `/concise dense` | dense | + fragments, arrows, drop articles |
| `/concise off` | off | Full verbose responses |
| `/concise:compress <target>` | active mode | Rewrite file/text, show diff, confirm |
| Security / destructive action | any | Auto-switch to full prose for that line |
| "clarify" / repeat question | any | Full prose; resume on next unrelated task |

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn concise`).
