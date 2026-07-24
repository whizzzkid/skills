# wk-sharpen

> Distill field reports and prune skill bloat without overfitting on specific examples.

**Version:** `2026.07.24-191252`

## Invocation

| Mode | Trigger |
|------|---------|
| User-invocable | `/wk-sharpen <skill> [incident]`, `/wk-sharpen` (batch), `/wk-sharpen improve [scope]` |
| Model-invocable | automatic: after [`wk-retro`](../retro/README.md) surfaces skill gaps |

## How It Works

```mermaid
flowchart TD
    A{Invocation mode} -->|single| B[Read incident report]
    A -->|batch| G[Scan 4 sources]
    A -->|improve| K[Inventory all skills in scope]
    B --> B2[Verify reported cause against the owning source]
    B2 --> C[Read full SKILL.md]
    C --> D[Distill lesson — extract principle, strip specifics]
    D --> E[Draft skill update]
    E --> F[Audit: overlaps, contradictions, bloat, stale refs]
    F --> F2[Mechanical overfit scan — 9 categories + run .githooks/*.sh on the index]
    F2 --> P[Present diff + cleanup to user]
    P --> Q[Apply edits + bump CalVer version]
    Q --> Q2[Sync skill README + diagram + repo index/docs]
    Q2 --> R[De-bloat pass + size-ceiling check]
    R --> S[Install + commit + push terminal gate]
    G --> G1[Global learnings inbox $HOME/.claude/skills/learnings/]
    G --> G2[Repo learnings/skills/]
    G --> G3[$HOME/.claude/memory/ feedback type only]
    G --> G4[learnings/retrospect/ What-could-be-better bullets]
    G3 --> GM[Materialize as learning via wk-learn]
    G4 --> GM
    GM --> G2
    G1 & G2 --> D
    K --> L[Parallel audit agents]
    L --> M[Consolidate + phased proposal per user approval]
    M --> Q
```

## Noteworthy

- **HARD RULE: [`wk-learn`](../learn/README.md) vs [`wk-sharpen`](../sharpen/README.md)** — [`wk-learn`](../learn/README.md) captures to `learnings/` only;
  [`wk-sharpen`](../sharpen/README.md) edits `SKILL.md`. Ambiguous phrasing ("learn from this") defaults to
  [`wk-learn`](../learn/README.md); only explicit "sharpen" or `/wk-sharpen` triggers SKILL.md edits.
- **The report is a hypothesis** — a learning's "Root cause" and "Suggested fix" are claims,
  not authority. When the subject is a deterministic artifact (hook, script, CI check), its
  source is read (and the failure reproduced where cheap) before drafting, and any fold that
  would *relax* a guard is rejected in favor of the underlying correctness bug.
- **Mechanical overfit scan** is mandatory before presenting any diff — 9 categories
  (reviewer logins, org prefixes, employer/internal project names, ticket IDs, repo names,
  line numbers, tool versions, person names, hardcoded branch names) are grepped against the
  proposed text.
- **Run the hooks, never reimplement their matcher** — a hook's pattern file carries `#`
  comments and PCRE inline flags that a hand-rolled `grep -iEf` turns into either false noise
  or a false-clean, so the scan executes `.githooks/*.sh` against the staged index. Only
  staged **path strings** are hand-rolled, because every content hook greps the diff and
  commit message but never filenames.
- **Terminal gate** (Step 8) requires all four checks: install prints `Done!`, commits land,
  single push, and no modified tracked path — untracked *unprocessed* learnings/retros are
  expected state, not debris. Silence after edits is a violation.
- **Batch mode** mirrors the global learnings inbox (`$HOME/.claude/skills/learnings/`) into the
  repo tree before distilling, then drains the inbox by deleting originals after copy.
- **External memories become learnings first** — each `$HOME/.claude/memory/` feedback file is
  materialized as a version-controlled learning via [`wk-learn`](../learn/README.md) and distilled through the
  Source 2 path; the memory file itself is never renamed (only the materialized learning is).
- **Improve mode** requires explicit phased user approval even in auto mode — suite-scale
  refactoring is high blast-radius and can never be applied silently.
- **De-bloat pass** is mandatory on every run (not only when a learning prompts it) and
  enforces a hard 24 KiB ceiling per `SKILL.md` — over-ceiling skills are refactored, split into
  references/sub-skills, or scoped down, coverage-preserving. A pre-commit hook backstops the
  same ceiling.
- The gitignored `.distilled-memories` marker prevents re-distilling the same global memory
  across runs (`--force` bypasses it); learnings **and retrospects** track their own processed
  state via the `.learned.md` rename — no marker. Retros are write-once per-session files, so
  the rename can never orphan later content (a new session writes a new file).
