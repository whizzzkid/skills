# wk-self-perf

> Generate a self-performance review narrative by pulling data from all work systems.

**Version:** `2026.11.04-225618`

## Invocation

| Mode | Trigger |
|------|---------|
| User-invocable | `/wk-self-perf <period>` — e.g. `quarter`, `Q1`, `week`, `annual` |
| Model-invocable | not auto-invoked |

## How It Works

```mermaid
flowchart TD
    A[Parse period argument] --> B[Resolve date range + output paths]
    B --> C{Existing corpus?}
    C -->|yes| D[Prompt: open / re-gather / supplement]
    C -->|no| E[Stage 1: 7 parallel agents]
    D --> E
    E --> E1[GitHub PRs + reviews]
    E --> E2[Calendar + meetings]
    E --> E3[Slack contributions]
    E --> E4[Gmail sent]
    E --> E5[Jira + Confluence]
    E --> E6[Granola + Docs + Drive]
    E --> E7[DX metrics + sitrep files]
    E1 & E2 & E3 & E4 & E5 & E6 & E7 --> F0[Stage 2: Coverage-tagged win inventory]
    F0 --> F[Synthesize narrative]
    F --> F1[Completeness + voice critics]
    F1 --> G[Write QPR/period/synthesis.md]
    G --> H[Commit + push reference corpus]
    H --> I[Distill patterns into daily sitrep]
```

## Noteworthy

- Uses **7 parallel subagents** to fetch evidence simultaneously — each writes to
  `QPR/<period>/references/<source>.md` before synthesis begins.
- Period arguments map to **$EMPLOYER FY quarters** (Feb–Jan default): Q1 = Feb–Apr, Q2 = May–Jul, etc.
  Custom ranges accepted as `YYYY-MM-DD:YYYY-MM-DD`.
- Synthesis uses a strict **impact-language guide** — "worked on" → "designed and shipped";
  surface-level language is automatically upgraded to strong-verb form.
- Self-review prose is **action-first and self-directed** — feedback themes read as the user's own habits, never
  "I was asked/told to"; misses read as learning with the correction already in motion.
- Chronology and statistics claims pass evidence-integrity checks before synthesis: dated milestones support ordering,
  and non-significant results remain inconclusive rather than becoming no-effect claims.
- Synthesis drafts from a **coverage-tagged win inventory** (`references/inventory.md`), addresses the manager's latest
  1:1 guidance, and passes completeness and voice critics; the final announcement reminds the user to add
  private-conversation unblocks by hand.
- User-approved sections become protected revision boundaries until the user explicitly reopens them.
- **`{ROLE}` placeholder** in the synthesis template must be resolved from Workday/Lattice
  before writing; if unresolvable, left as placeholder with a flag.
- Supplement mode (default in auto) is additive — only missing or stale reference files are
  re-gathered, not the entire corpus.
- The **QPR/brag-log.md** accumulates highlights across quarters so each new QPR starts with
  a richer corpus from prior periods.
