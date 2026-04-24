---
name: wk:concise
description: >-
  Reduce response verbosity and token usage. Drops articles, filler, hedging,
  and pleasantries from agent replies while preserving technical accuracy.
  Use when starting a session where you want shorter, denser output, or when
  asked to "be brief", "less words", "reduce tokens", or "compress context".
  Also provides /concise:compress to rewrite verbose docs/memory files using
  the same rules — no binary dependencies required.
argument-hint: '[brief|dense|off|compress <target>]'
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - AskUserQuestion
  # Learning capture (post-completion hook)
  - "Bash(mkdir -p:*)"
model: sonnet
effort: low
model-invocable: true
user-invocable: true
license: MIT
metadata:
  author: whizzzkid
  version: '2026.04.24-220901'
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
| `/concise` | Enable brief mode |
| `/concise brief` | Enable brief mode (explicit) |
| `/concise dense` | Enable dense mode |
| `/concise off` | Disable — return to normal prose |
| `/concise:compress <path or paste>` | Rewrite a file or block using active mode rules |

Natural language triggers: "be brief", "less words", "reduce tokens",
"shorter responses", "compress context", "stop being verbose".

On activation, confirm in one line:
> `Concise mode: brief. Active for this session.`

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
6. **When the user asks to clarify** — drop mode temporarily, explain fully, resume after

Resume concise mode after the safe-context sentence is complete.

---

## Persistence

Mode is active for the current session only. Re-invoke at session start to
restore. No flag files, no hooks required.

For hook-based persistence (optional): see `docs/spec.md` — shell hook section.

---

## `/concise:compress` — Context Compression

Rewrites a verbose text block or file using the active mode's rules. No binary,
no Python — the LLM applies the rules and returns a diff for review.

### Usage

```
/concise:compress                    # paste text after invocation
/concise:compress path/to/file.md    # reads file, rewrites in-place after approval
```

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

Bad targets (skip or warn):
- Files with >50% code content (`.py`, `.ts`, `.rb`, etc.)
- Files under `.ssh/`, `.aws/`, `.env`, `credentials*`, `secrets*` — refuse with error

---

## Deactivation

- `/concise off` — explicit
- "stop being brief" / "normal mode" / "full responses please" — natural language
- End of session (mode does not persist by default)

Confirm deactivation:
> `Normal mode restored.`

---

## Quick Reference

| Trigger | Mode | Action |
|---------|------|--------|
| `/concise` | brief | Drop filler/hedging, keep grammar |
| `/concise dense` | dense | + fragments, arrows, drop articles |
| `/concise off` | off | Full verbose responses |
| `/concise:compress <target>` | active mode | Rewrite file/text, show diff, confirm |
| Security / destructive action | any | Auto-switch to full prose for that line |
| "clarify" / repeat question | any | Full prose, resume after |

---

## Post-Completion: Learning Capture

**After this skill finishes its primary work**, capture what happened
before returning control.

### Check environment

```bash
test -n "$WK_SKILLS_HOME" && echo "OK: $WK_SKILLS_HOME" || echo "MISSING"
```

If `$WK_SKILLS_HOME` is not set, ask the user:

> "`$WK_SKILLS_HOME` is not set. Please add
> `export WK_SKILLS_HOME=/path/to/skills` to your shell profile and
> restart your terminal."

**Stop here if the variable is missing.** Do not guess or use a fallback.

### Reflect

Review what happened during this skill's execution:

1. **What went wrong?** — Errors, wrong assumptions, user corrections, API failures
2. **What was missing?** — Steps the skill should have included, edge cases not covered
3. **What worked well?** — Approaches worth reinforcing
4. **What surprised you?** — Non-obvious discoveries for future runs

If ALL lenses are empty, **skip writing**.

### Write the learning

```bash
mkdir -p "$WK_SKILLS_HOME/learnings/skills/concise"
```

Write to `$WK_SKILLS_HOME/learnings/skills/concise/<YYYY-MM-DD>_<slug>.md`:

```markdown
---
skill: wk:concise
date: <YYYY-MM-DD>
type: <correction | gap | pattern | surprise>
severity: <low | medium | high>
---

<One-line summary>

**What happened:** <description>
**Root cause:** <why>
**Suggested fix:** <what to change>
```

> "📝 Learning captured: `concise/<date>_<slug>.md` — distill with `wk:sharpen` when ready."
