# wk-self-perf

> Generate a self-performance review narrative by pulling data from all work systems.

**Version:** `2026.07.28-171103`

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
    E1 & E2 & E3 & E4 & E5 & E6 & E7 --> F[Stage 2: Synthesize narrative]
    F --> G[Write QPR/period/synthesis.md]
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
- **`{ROLE}` placeholder** in the synthesis template must be resolved from Workday/Lattice
  before writing; if unresolvable, left as placeholder with a flag.
- Supplement mode (default in auto) is additive — only missing or stale reference files are
  re-gathered, not the entire corpus.
- The **QPR/brag-log.md** accumulates highlights across quarters so each new QPR starts with
  a richer corpus from prior periods.
