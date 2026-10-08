# /concise:compress — Context Compression

Rewrites a verbose text block or file using the active mode's rules. No binary, no Python — LLM applies the rules and returns a diff for review.

## Usage

```
/concise:compress                    # paste text after invocation
/concise:compress path/to/file.md    # reads file, rewrites in-place after approval
```

## Default Mode for Compress

If no mode is active when `/concise:compress` is invoked, default to `brief` and state it: `No mode active — using brief for compression.`

## Process

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

## Good Targets

- `$HOME/.claude/CLAUDE.md` — global agent instructions
- Memory files in `$HOME/.claude/memory/*.md`
- Skill `SKILL.md` files (non-procedural sections only)
- Meeting notes, spec docs with heavy prose

## Bad Targets — Refuse with Error

- Files with >50% code content (`.py`, `.ts`, `.rb`, `.go`, `.rs`, etc.)
- Files matching: `*.pem`, `*.key`, `*.p12`, `*.pfx`, `*.env`, `.env*`
- Files whose name matches: `credentials*`, `secrets*`, `*password*`, `*apikey*`, `*token*`
- Files under any of these path components: `.ssh/`, `.aws/`, `.gnupg/`, `.kube/`, `.config/gcloud/`, `.docker/`
- Symlinks (resolve and check before reading; refuse if target is outside the working directory or home directory prose files)
