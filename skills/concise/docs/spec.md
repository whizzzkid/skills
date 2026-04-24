# concise skill — Research & Design Spec

## Problem

Agent responses in this skill suite are information-rich but verbose.
System prompts, skill instructions, and reply prose carry significant
token overhead from articles, hedging, pleasantries, and redundant connectives.
The user wants less to read and lower cost, not less information.

## Reference: JuliusBrussee/caveman

Explored at `/tmp/caveman` on 2026-04-24. Full repo:
https://github.com/JuliusBrussee/caveman

### What caveman does

- **Core response compression** — behavioral LLM rules (no code):
  drop articles, filler, hedging, pleasantries; fragments ok; short synonyms.
  Reports 65–87% output-token reduction in benchmarks.
- **caveman-compress** — Python 5-stage pipeline that compresses static
  `.md` files (CLAUDE.md, memory) before each session using the same rules
  via Claude API calls. Reports ~46% input-token reduction on memory files.
- **6 intensity levels**: lite, full (default), ultra, wenyan-{lite,full,ultra}
- **Persistence via JS hook**: SessionStart + UserPromptSubmit hooks read/write
  a flag file; caveman-mode-tracker.js emits a 1-line reinforcement reminder
  each turn.
- **Safety boundary**: code blocks, security warnings, irreversible actions
  always written in normal prose.

### What to adopt

| Technique | Mechanism | Worth adopting? |
|-----------|-----------|-----------------|
| Drop-list (articles, filler, hedging) | Prose rules only | ✅ Yes — core mechanism |
| Keep-list (code, URLs, paths, technical terms) | Prose rules only | ✅ Yes — essential safety |
| Pattern: `[thing] [action] [reason].` | Prose rules only | ✅ Yes — best single rule |
| Causality arrows (X → Y) | Prose rules only | ✅ Yes — dense mode |
| Fragment sentences | Prose rules only | ✅ Yes — dense mode |
| Short synonyms table | Static lookup in SKILL.md | ✅ Yes |
| Intensity levels | Prose rule sets | ✅ 2–3 levels (not 6) |
| Auto-clarity boundary | Prose rule | ✅ Yes — always |
| Static-file compression via LLM | LLM call from skill | ✅ Adopt without Python |
| JS hooks for persistence | Node.js hook files | 🟡 Optional (shell hook) |
| Python binary (caveman-compress) | Python 3.10+, anthropic SDK | ❌ Explicitly excluded |
| wenyan / classical Chinese modes | Novelty feature | ❌ Out of scope |
| Validation regex on compressed output | Python re module | ❌ No binary needed |
| CI sync of skill copies | GitHub Actions | ❌ Not applicable here |

### What NOT to adopt

1. **Python binary** — the user explicitly excluded system-wide deps.
   The `concise` skill replaces this with on-demand LLM-driven rewriting
   via `/concise:compress`.
2. **6 intensity levels** — cognitive overhead outweighs benefit. 3 is enough.
3. **wenyan modes** — novelty. Excluded.
4. **Complex JS hook with config chain** — the hook is a nice-to-have, not
   core. The skill works without it; optional shell hook adds persistence.

---

## Design Decisions

### D1: No binary, no Python

Compression is performed by the LLM itself, not an external tool.
The skill provides explicit rules; the model applies them. For static-file
compression (CLAUDE.md, memory files), the user runs `/concise:compress`
and the skill rewrites the text inline, returning a diff for review.

**Trade-off:** compression quality depends on model instruction-following,
not deterministic regex. Acceptable — the model is already the bottleneck
for output token reduction; consistent rules produce consistent results.

### D2: Three modes, not six

| Mode | When to use |
|------|-------------|
| `brief` (default) | Everyday usage. Drop filler/hedging. Keep articles and full sentences. |
| `dense` | High-volume sessions. Drop articles, use fragments, arrows for causality. |
| `off` | Explicitly requested or auto-triggered for safety contexts. |

Three is enough for practical use. Users who want `ultra` can invoke `dense`
and prompt-add "abbreviate common terms".

### D3: Opt-in by default via three stackable mechanisms

The skill supports "always-on by default, opt-out on demand" without any
single required mechanism. Three layers, each usable independently:

1. **CLAUDE.md / AGENTS.md snippet** — `templates/claude-md-snippet.md`.
   Pure prose, works for every agent that reads a memory file (Claude Code,
   Cursor, Gemini CLI, Copilot, Codex). Declares brief mode active and
   documents opt-out paths.

2. **UserPromptSubmit hook** — `hooks/concise-reminder.sh`. Pure POSIX sh.
   Reads `~/.claude/.concise-mode` (default `brief`), emits a 1-line
   reminder into Claude Code's per-turn context. Silent-fail on I/O error.

3. **Mode file** — `~/.claude/.concise-mode` is the single source of truth
   shared by the hook and the `/concise` commands.

**Opt-out precedence** (both hook and CLAUDE.md snippet honor this):

1. `$CONCISE_OFF=1` environment variable
2. `~/.claude/.concise-off` flag file exists
3. `~/.claude/.concise-mode` contents = "off"

Rationale: users pick the level that matches their setup. CLAUDE.md alone
is enough for 90% of agents. Hook adds per-turn reinforcement for agents
where memory files drift out of active context. Flag-file opt-out is a
one-command escape hatch that works regardless of which mechanism is on.

### D4: The compress sub-command

`/concise:compress` rewrites a pasted block of text or a file path using the
active mode's rules. No external process — the LLM applies the rules, shows
the before/after diff, and asks for confirmation before writing.

This replaces caveman-compress's Python pipeline with a simpler, safer,
dependency-free alternative. Quality is comparable; validation is human-in-loop
rather than regex-based.

### D5: Skill self-compliance

The SKILL.md file itself is written in `brief` mode — no articles in
procedural steps, no hedging, short synonyms. The spec (this file) is
intentionally more verbose to capture design rationale.

---

## Token Reduction Mechanics

### Output tokens (response prose)

Removing per-response:

| Category | Examples | Est. tokens/response |
|----------|----------|---------------------|
| Pleasantries | "Sure!", "Happy to help!", "Certainly!" | 3–8 |
| Hedging | "It might be worth…", "You could consider…" | 5–15 |
| Filler | "just", "really", "basically", "essentially" | 2–8 each |
| Articles | "a", "an", "the" (in procedural text) | 1 each, many |
| Redundant phrasing | "in order to" → "to", "make sure to" → [nothing] | 2–5 each |
| Transition connectors | "However,", "Furthermore,", "Additionally," | 2–3 each |

Conservative estimate per turn: 50–200 tokens on a typical 600-token response
= 8–33% reduction. Compound over a 50-turn session: meaningful.

### Input tokens (context / memory files)

Compressing CLAUDE.md, memory files, skill instructions before sessions:
- caveman reports 46% reduction on memory files
- Same technique, applied via `/concise:compress`
- One-time cost (single LLM call per file); benefit accrues every session load

---

## Alternatives Considered

| Alternative | Why rejected |
|-------------|-------------|
| Wrap every response with a post-process filter | Would require a hook + external script |
| Use caveman as-is (fork) | Python dep; 6 modes is overkill; wenyan not needed |
| Just write a shorter CLAUDE.md | Addresses input tokens only, not response verbosity |
| Summarization via separate agent | Latency + cost; not suitable for real-time responses |
| Response streaming truncation | Lossy — cuts tail of long responses |

---

## File Layout

```
skills/concise/
  SKILL.md          # The skill (model-executable rules)
  docs/
    spec.md         # This file
```
