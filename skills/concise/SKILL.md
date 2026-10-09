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
group: workflows
metadata:
  author: whizzzkid
  version: "2026.10.09-165052"
  internal: false
  model:
    openai: gpt-5.6-terra
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

## HARD RULES — answer shape (every mode)

- **HARD RULE — one recommendation, not a menu.** Asked how to fix or which to pick → lead with the one
  thing to do. More steps appear only as an ordered fallback ("if that still fails, …"); never parallel
  options, "layers", or "Option 1/2/3". Name a rejected alternative only with why not.
- **HARD RULE — close with the gap.** After writing non-trivial code or a fix, the final line names what
  you skipped or did not verify and any risk the user must know (unhandled inputs, edge cases,
  assumptions). Not a recap; omit only when nothing was skipped.

## Activation

| Invocation | Effect |
|-----------|--------|
| `/concise` | Enable brief mode for this session + write `$HOME/.claude/.concise-mode` |
| `/concise brief` | Enable brief mode (explicit) |
| `/concise dense` | Enable dense mode |
| `/concise off` | Disable — remove `$HOME/.claude/.concise-mode` and touch `$HOME/.claude/.concise-off` |
| `/concise:compress <path or paste>` | Rewrite a file or block using active mode rules |
| `/concise:setup` | Re-run first-run setup flow (detect + offer to install hook and CLAUDE.md snippet) |

Natural-language triggers: "be brief", "less words", "reduce tokens",
"shorter responses", "compress context", "stop being verbose".

On activation, write mode to `$HOME/.claude/.concise-mode` → confirm in one line:
> `Concise mode: brief. Active for this session (and future, via mode file).`

Make active by default across sessions/agents → see **Default Activation**.

---

## Mode Rules

### Reasoning brevity (both modes)

Concise governs **internal reasoning**, not just the visible reply — the
per-turn hook reminder carries a THINK-BRIEFLY / THINK-MINIMALLY clause.

- Keep deliberation short → reason just enough to reach a correct answer, then act.
- Don't re-derive facts established this session, restate the prompt, or narrate a plan before the obvious step.
- Act once path is clear; reserve long reasoning for genuinely ambiguous/high-risk work (same exemptions as output caps).
- Hook only *steers* reasoning length. Hard lever = harness reasoning/thinking budget — lower it (or pick a lower-effort model) when internal-monologue token cost stays high despite the nudge.

### brief (default)

**Remove:**
- Pleasantries: "Sure!", "Happy to help!", "Certainly!", "Of course!", "Great question!"
- Hedging: "it might be worth", "you could consider", "perhaps", "I think", "it seems"
- Filler: "just", "really", "basically", "actually", "essentially", "simply", "generally"
- Redundant phrasing: "in order to" → "to"; "make sure to" → [drop]; "the reason is because" → "because"
- Fluff connectors: "However,", "Furthermore,", "Additionally," (at line start — cut or use "Also")

**Keep:** Full sentences, articles (a/an/the), normal grammar. Professional but tight.

**Hard caps (brief):**

- **≤3 sentences** per answer unless answer is code, a diff, or a safety warning. Multi-step procedures still need ≤3 sentences of prose around the code; code itself exempt.
- **No tables for ≤3 items** — write a sentence ("X (foo), Y (bar), Z (baz)"). Tables are for ≥4 row × ≥2 column comparisons.
- **No section headers for single-section answers.** Headers are for navigation; drop them if nothing to navigate to.
- **No trailing summary, no recap, no "let me know if".** End on the result.

Caps surfaced per-turn by `concise-reminder.sh` hook so they stay top of mind despite chatty defaults.

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

## First-Run Setup & Default Activation

Self-installs on first invocation: detects missing hook/snippet, offers to install both. Three stackable mechanisms for global activation (CLAUDE.md snippet, UserPromptSubmit hook, mode file). Full setup flow, detection commands, and mechanism details in [references/setup-flow.md](references/setup-flow.md). Re-trigger via `/concise:setup`.

## Opt-Out

Any of these disables concise mode without removing the skill:

| Action | Scope |
|--------|-------|
| `/concise off` | Current session |
| `touch $HOME/.claude/.concise-off` | All future sessions until removed |
| `export CONCISE_OFF=1` | Current shell's sessions |
| Remove the snippet from `CLAUDE.md` | Permanent |

Opt-out precedence (hook evaluates top-to-bottom): `$CONCISE_OFF=1` →
`$HOME/.claude/.concise-off` exists → `$HOME/.claude/.concise-mode` = "off".

Confirm deactivation: `Normal mode restored. Opt back in with /concise (or remove $HOME/.claude/.concise-off).`

## Session Persistence Summary

| Setup | Default at session start | Survives restart? |
|-------|-------------------------|-------------------|
| Skill installed, nothing else | `off` (must invoke) | No |
| CLAUDE.md snippet added | `brief` | Yes |
| CLAUDE.md + hook + `.concise-mode=dense` | `dense` | Yes |
| `.concise-off` flag touched | `off` | Yes (until removed) |

---

## `/concise:compress` — Context Compression

LLM-based rewrite of verbose text/files using active mode rules. Full process (read → apply → diff → confirm), good/bad target lists, and preservation rules in [references/compress-process.md](references/compress-process.md).

Defaults to `brief` if no mode active. Refuses code files (>50%), secrets/credentials, and files under `.ssh/`/`.aws/`/`.gnupg/`/`.kube/`/`.docker/`.

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

Invoke `wk-learn concise`.
