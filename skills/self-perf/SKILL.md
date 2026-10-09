---
name: wk-self-perf
description: >-
  Generate a self-performance review narrative by pulling data from all work
  systems (GitHub, Slack, Gmail, Calendar, Jira/Confluence, Granola, Docs, DX).
  Supports any time window: day, week, month, quarter, half-year, or annual.
  Writes a QPR reference corpus + synthesized narrative draft to QPR/<period>/.
  Run as: /wk-self-perf quarter  or  /wk-self-perf week  or  /wk-self-perf Q1
argument-hint: '[day | week | month | quarter | Q1-Q4 | H1-H2 | annual | YYYY-MM-DD:YYYY-MM-DD]'
allowed-tools:
  - Skill
  - Agent
  - AskUserQuestion
  - Bash
  - Write
  - Edit
  - Read
model: sonnet
effort: high
model-invocable: false
user-invocable: true
license: MIT
group: rituals
metadata:
  author: whizzzkid
  version: "2026.10.09-171327"
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-pro
    meta: llama-4-maverick
    kimi: k2
    qwen: qwen3-235b
    cursor: composer-2
---

# Self-Performance Review

Pull data from all connected work systems in parallel → distill accomplishments,
impact signals, leadership evidence → narrative ready for QPR submission.

```
Parse period ──► Parallel data fetch (7 agents) ──► Synthesize ──► Draft narrative
     │                                                    │
     └── day|week|month|quarter|half|annual               └── QPR/<period>/references/*.md
                                                              QPR/<period>/synthesis.md
```

---

## Stage 0: Parse Period and Set Date Range

### Parse the period argument

Map the period argument to a start/end date range:

| Argument | Start | End |
|----------|-------|-----|
| `day` | Today 00:00 | Today 23:59 |
| `week` | Monday of current week | Today |
| `month` | 1st of current month | Today |
| `quarter` or `Q1`/`Q2`/`Q3`/`Q4` | First day of FY quarter | Last day of FY quarter |
| `half` or `H1`/`H2` | First day of half-year | Last day of half-year |
| `annual` | Feb 1 of current FY | Jan 31 of next FY |
| `YYYY-MM-DD:YYYY-MM-DD` | Custom start | Custom end |

**$EMPLOYER FY quarters** (Feb–Jan fiscal year, adjust per `$EMPLOYER_FY_START` if set):
- Q1: Feb 1 – Apr 30
- Q2: May 1 – Jul 31
- Q3: Aug 1 – Oct 31
- Q4: Nov 1 – Jan 31

**Buffer:** Add 2 days before and after the period for context.

```bash
# Example for Q1 FY2026
START_DATE="2026-01-30"
END_DATE="2026-05-02"
DISPLAY_PERIOD="Q1 FY2026"
PERIOD_SLUG="Q1"  # for folder naming
```

### Determine output paths

```bash
QPR_DIR="$PWD/QPR/${PERIOD_SLUG}"
REFS_DIR="$QPR_DIR/references"
SYNTHESIS_FILE="$QPR_DIR/synthesis.md"
mkdir -p "$REFS_DIR"
```

### Check for existing corpus

If `$SYNTHESIS_FILE` exists, prompt:

> "A QPR corpus already exists for `${PERIOD_SLUG}` (synthesis.md found).
>
> **(a)** Open existing synthesis — no regeneration
> **(b)** Re-gather from scratch — overwrites all reference files and synthesis
> **(c)** Supplement — run only missing or stale reference files, then re-synthesize
>
> Reply with your choice."

Auto mode → default **(c)** (supplement is safe and additive).

---

## Stage 1: Parallel Data Gathering

- Launch **7 agents in parallel**.
- Each writes its output to a file in `$REFS_DIR/`.
- Include the period context in every prompt.

### Subagent contract (mandatory)

> See [`wk-sitrep`](../sitrep/SKILL.md#stage-2-parallel-data-gathering)
> for the base contract. Prepend verbatim to every agent prompt, then append these
> self-perf-specific additions:

```
SUBAGENT CONTRACT ADDITIONS (self-perf):
- Write your findings ONLY to the specified output file (path provided in prompt)
- Be comprehensive — this is for a performance review where the user's job depends on it
- Use strong-verb impact language: "shipped", "led", "designed", "resolved"
- Include specific evidence: PR numbers, dates, ticket keys, attendee counts, metrics
```

The base contract's source-identifier and verified/claim tagging rules apply here too.

---

### Agent Summary

| # | Agent | Output file | Sources |
|---|-------|-------------|---------|
| 1 | GitHub Activity | `github.md` | `gh search prs/issues` — PRs authored/reviewed, issues |
| 2 | Calendar & Meetings | `calendar.md` | Google Calendar MCP — interviews, 1:1s, cross-team |
| 3 | Slack Contributions | `slack.md` | Slack MCP — decisions, announcements, collaboration |
| 4 | Gmail | `gmail.md` | Gmail MCP — proposals, feedback, escalations |
| 5 | Jira & Confluence | `jira-confluence.md` | Jira/Confluence MCP — issues, epics, specs authored |
| 6 | Docs & Meetings | `docs-meetings.md` | Granola, Google Docs, Glean — decisions, docs authored |
| 7 | DX Metrics & Sitrep | `dx-sitrep.md` | DX MCP + sitrep files — metrics, timeline, wins |

Full agent prompts with queries, structure requirements, and MCP tool references:
[`references/agent-prompts.md`](references/agent-prompts.md).

---

## Stage 2: Synthesize into Narrative

After all 7 agents complete → read every reference file → synthesize into `$SYNTHESIS_FILE`.

Write `$SYNTHESIS_FILE` using the synthesis template — includes evidence-integrity
checks, revision boundaries, the full markdown structure, impact language guide,
and level-expectation calibration:
[`references/synthesis-template.md`](references/synthesis-template.md).

---

## Stage 3: Write Output Files

### 3a. Commit reference files

After all agents write their output files:

```bash
git add QPR/
git commit -m "feat(QPR): add ${PERIOD_SLUG} performance reference corpus"
```

### 3b. Write synthesis

Write the synthesized narrative to `$SYNTHESIS_FILE`, then commit:

```bash
git add "$SYNTHESIS_FILE"
git commit -m "feat(QPR): add ${PERIOD_SLUG} self-performance synthesis"
git push
```

### 3c. Open synthesis

```bash
open "$SYNTHESIS_FILE"
```

Announce:

> "Your `${PERIOD_SLUG}` self-performance corpus is ready:
> - `QPR/${PERIOD_SLUG}/references/` — {N} source files with raw evidence
> - `QPR/${PERIOD_SLUG}/synthesis.md` — narrative draft ready for QPR submission
>
> Top accomplishments surfaced:
> 1. {accomplishment 1}
> 2. {accomplishment 2}
> 3. {accomplishment 3}
>
> The 'Quarter Narrative' section has suggested self-review language you can
> paste directly."

---

## Stage 4: Distill Learnings into Daily Sitreps

After synthesis, evaluate whether meaningful patterns from this period belong in the daily sitrep:

| Pattern | Add to |
|---------|--------|
| A recurring impact signal worth tracking daily | sitrep end brag/snapshot section |
| A type of work worth preparing for in the morning | wk-sitrep start context section |
| A metric that should be monitored | DX section of sitrep end |

**QPR brag log:** Append notable accomplishments to the QPR running log:

```bash
QPR_LOG="$PWD/QPR/brag-log.md"
# Append this period's highlights with date range
```

This log accumulates across quarters so the next QPR has a richer corpus.

---

## Post-Completion

Invoke `wk-learn self-perf`.
