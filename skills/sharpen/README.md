# wk-sharpen

> Distill field reports and prune skill bloat without overfitting on specific examples.

**Version:** `2026.07.27-175902`

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
    R --> S["Install + suite + commit + push terminal gate"]
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
  would *relax* a guard is rejected in favor of the underlying correctness bug. The run's own
  verification tooling is no more authoritative: a red result indicts the tooling before the
  artifact — a newly added case failing while every pre-existing case passes indicts the
  harness, and a failed positive control indicts the control. The artifact is driven directly
  with the same input, a canary is rebuilt as a literal the pattern actually matches, and a red
  result never licenses swapping the prescribed primitive.
- **A disproof voids the draft** — verification is not a pass/delete filter on the reported
  mechanism. Once reproduction disproves *or sharpens* it, the fold is re-derived from the
  source's semantics rather than reworded, since a corrected mechanism usually changes what the
  rule should say and upgrades a heuristic remediation to a deterministic one. The formulation a
  later run can drive the source to demonstrate wins.
- **A recorded rejection is a case to execute, not prose to re-read** — when an audit surfaces a
  `Rejected` / `Deliberately not promoted` note covering the design about to be adopted, the
  shape it names is driven against the artifact before *and* after the change and the verdicts
  must match. A suite that stays green without ever covering that shape is evidence of missing
  coverage, not of safety, so the case lands as a pinned test in the same pass. An over-broad
  note is rewritten to what actually holds once a compensating rule makes the design safe.
- **Verifying a guard on the agent's own tool calls** — the faithful test input is itself a
  blocked call, so each payload is staged with the file-write tool and fed to the hook by
  redirect. The guard's opt-out is never used to run its own test.
- **Mechanical overfit scan** is mandatory before presenting any diff — 9 categories
  (reviewer logins, org prefixes, employer/internal project names, ticket IDs, repo names,
  line numbers, tool versions, person names, hardcoded branch names) are grepped against the
  proposed text.
- **Run the hooks, never reimplement their matcher** — a hook's pattern file carries `#`
  comments and PCRE inline flags that a hand-rolled `grep -iEf` turns into either false noise
  or a false-clean, so the scan executes `.githooks/*.sh` against the staged index. Only
  staged **path strings** are hand-rolled, because every content hook greps the diff and
  commit message but never filenames.
- **Terminal gate** (Step 8) requires all five checks: install prints `Done!`, the owning
  skill's test suite runs when the fold touched a shipped executable artifact, commits land,
  single push, and no modified tracked path — untracked *unprocessed* learnings/retros are
  expected state, not debris. Silence after edits is a violation.
- **Anti-thrash is not gate discharge.** On a resumed signer-blocked fold the rule against
  re-running install/scan forbids *looping*, not *verifying*: an inherited fold's gates count as
  unrun until the tree records otherwise, so the shipped-code suite and the owning hooks still
  run. The index stays partitioned exactly as the prior run left it — staging a second fold
  merely to hook-check it destroys that run's path-scoped commit separation.
- **Batch mode** mirrors the global learnings inbox (`$HOME/.claude/skills/learnings/`) into the
  repo tree before distilling, then drains the inbox by deleting originals after copy.
- **A re-scan arrival is not automatically this run's work.** An item whose mtime postdates
  the run's start is unowned, not assigned — peer sharpen agents share the tree and there is no
  lock, lease, or ownership marker to arbitrate a collision. Neither mtime nor commit recency
  can see a peer's *claim*: processed state is recorded by renaming the file, and `mv` preserves
  mtime while advancing only ctime, so the two signals agree because both are blind in the same
  direction — never as corroboration. The listing is therefore re-read immediately before each
  item is folded, and an item that has vanished since the opening listing proves a concurrent
  writer whatever the timestamps say. Such items are reported as
  unclaimed backlog for the dispatcher, and the terminal state reads "processed N, M unclaimed,
  K distilled-not-landed" rather than "drained". That third bucket holds a fold applied to the
  worktree but blocked from committing: the source learning stays unrenamed and is named in the
  report, so it is neither counted as processed nor re-queued as backlog for a later run to fold
  a second time. A dispatcher's own claim that no peer is mid-fold is treated
  as a hypothesis that loses to contradicting evidence from the tree.
- **Ownership resolves before thoroughness, and severity never grants it.** A `severity: high`
  MUST-FOLD sets how thoroughly an item this run *owns* gets folded — never whether it owns it,
  so severity cannot convert an unowned or concurrently-claimed arrival into an assigned one.
  A high-severity unclaimed item escalates to the dispatcher as priority backlog. An
  independently blocked commit gate defers by *target-path* state rather than by gate state: a
  path already carrying an uncommitted fold is extended under its single version bump, while a
  clean unclaimed path is deferred as blocked backlog — folding only where it adds no
  entanglement the path did not already carry.
- **A re-violation is scored against the *installed* skill, not the worktree.** A rule
  strengthened only in an uncommitted fold never steered the run that "violated" it, so the
  escalation ladder is spent only when installed and worktree text agree; a divergence is
  classified `already-covered (unshipped)` instead. That rule is scoped to escalation
  *evidence* only — the opposite question, "did this fold land?", is a landing check and reads
  the **worktree**, where an uncommitted fold lives by definition. Under divergence the two
  reads answer different questions, and substituting one for the other reports a landed fold
  as missing.
- **External memories become learnings first** — each `$HOME/.claude/memory/` feedback file is
  materialized as a version-controlled learning via [`wk-learn`](../learn/README.md) and distilled through the
  Source 2 path; the memory file itself is never renamed (only the materialized learning is).
- **Improve mode** requires explicit phased user approval even in auto mode — suite-scale
  refactoring is high blast-radius and can never be applied silently.
- **De-bloat pass** is mandatory on every run (not only when a learning prompts it) and
  enforces a hard 24 KiB ceiling per `SKILL.md` — over-ceiling skills are refactored, split into
  references/sub-skills, or scoped down, coverage-preserving. A pre-commit hook backstops the
  same ceiling. The byte budget for a near-ceiling fold is stated as explicit arithmetic —
  measured addition, each reclaim's measured net — before any edit is applied; estimating
  either side makes the mandated single pass a coin flip. Reclaim is searched in a fixed
  order — an inline rule whose own linked reference already states it in full is deleted
  outright first (full value, zero coverage risk), relocation is considered last, and a
  recorded stay-inline decision is honored rather than reopened under ceiling pressure.
  Duplicates are scored by reading order: only the *later* occurrence is deletable, because
  removing a rule's earliest statement moves it later and recreates the reachability defect
  the reading-order fixes exist to prevent. When that pool is exhausted and the net is still
  positive, the *addition* is the next target rather than the last resort — a draft's first
  size is an estimate, not a requirement, and it is the only lever that cannot endanger
  existing load-bearing content.
- **A unanimous verdict at any memory-scan stage indicts the tooling, not the files** — and the
  two stages fail in opposite directions, so neither guard generalizes to the other. All-reject
  at the parse gate under-reports as a false *empty*, which is the more dangerous half: it
  produces no visible work, so nothing prompts an investigation. All-un-distilled at the marker
  diff over-reports. A hand-rolled filter's zero closes out a source only after a positive
  control moves its count.
- **Non-unanimity never exonerates the gate.** A shape-partial matcher splits *by
  construction* — it classifies the shape it knows and drops the shape it does not — so the
  unanimity guard's sensitivity falls as the blind spot widens, and a mixed verdict is that
  blind spot's signature rather than evidence against one. The parse gate therefore matches
  `type:` at column 0 **and** nested under `metadata:` (both shapes occur in the store, and a
  matcher keyed on either alone silently drops real memories), and a positive control is built
  **per shape** — a lone control synthesized by the matcher's own author shares its shape
  assumption, so control and matcher agree while both are wrong.
- **A control only carries evidence if its target can structurally produce a hit under the
  scan's own invocation form** — the constraint now governs all four sources, not just the
  memory scan. Topical proximity is not structure: a traversal primitive that silently skips a
  class of node (`find -type f` never descends a symlinked directory) returns zero for any
  content when rooted where those nodes live, so the control is dead while reading exactly like
  a confirmed drain. Every drain is re-proved with an in-place canary re-run through the
  identical form, plus a primitive that does not share the scan's blind spot.
- **A two-stage-disagreement control must *reach* the deciding comparison, not merely permit
  it.** Correct data shape and correct intent both leave the decision reachable-but-unreached: a
  merge consults ordering only where the two streams differ, so the differing element must
  itself be the order-flipping one and must sit on the side feeding the arm under test.
  Otherwise the arms agree — at the known truth or away from it — which reads as proof the
  guard is decorative rather than as a dead control.
- The gitignored `.distilled-memories` marker prevents re-distilling the same global memory
  across runs (`--force` bypasses it); learnings **and retrospects** track their own processed
  state via the `.learned.md` rename — no marker. Retros are write-once per-session files, so
  the rename can never orphan later content (a new session writes a new file).
