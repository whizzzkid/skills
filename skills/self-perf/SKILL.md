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
  version: "2026.11.04-225738"
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-pro
    meta: llama-4-maverick
    kimi: k2
    qwen: qwen3-235b
    cursor: composer-2
---

# Self-Performance Review

Pull data from all connected work systems in parallel, distill accomplishments, impact signals, and leadership evidence,
and draft a narrative ready for QPR submission: `QPR/<period>/references/*.md` + `QPR/<period>/synthesis.md`.

## Stage 0: Parse Period and Set Date Range

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

- **$EMPLOYER FY quarters** (Feb–Jan fiscal year, adjust per `$EMPLOYER_FY_START` if set): Q1 Feb 1 – Apr 30; Q2 May 1 –
  Jul 31; Q3 Aug 1 – Oct 31; Q4 Nov 1 – Jan 31.
- **Buffer:** add 2 days before and after the period for context.

```bash
# Example for Q1 FY2026
START_DATE="2026-01-30"
END_DATE="2026-05-02"
DISPLAY_PERIOD="Q1 FY2026"
PERIOD_SLUG="Q1"  # for folder naming
```

Set output paths:

```bash
QPR_DIR="$PWD/QPR/${PERIOD_SLUG}"
REFS_DIR="$QPR_DIR/references"
SYNTHESIS_FILE="$QPR_DIR/synthesis.md"
mkdir -p "$REFS_DIR"
```

If `$SYNTHESIS_FILE` exists, prompt "A QPR corpus already exists for `${PERIOD_SLUG}` (synthesis.md found)." with
choices **(a)** Open existing synthesis — no regeneration; **(b)** Re-gather from scratch — overwrites all reference
files and synthesis; **(c)** Supplement — run only missing or stale reference files, then re-synthesize. Auto mode →
default **(c)** (supplement is safe and additive).

## Stage 1: Parallel Data Gathering

Launch **7 agents in parallel**; each writes its output to a file in `$REFS_DIR/`; include the period context in every
prompt.

**Subagent contract (mandatory):** prepend the base contract from
[`wk-sitrep`](../sitrep/references/subagent-contract.md) verbatim to every agent prompt, then append these
self-perf-specific additions:

```
SUBAGENT CONTRACT ADDITIONS (self-perf):
- Write your findings ONLY to the specified output file (path provided in prompt)
- Be comprehensive — this is for a performance review where the user's job depends on it
- Use strong-verb impact language: "shipped", "led", "designed", "resolved"
- Include specific evidence: PR numbers, dates, ticket keys, attendee counts, metrics
```

The base contract's source-identifier and verified/claim tagging rules apply here too.

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

## Stage 2: Synthesize into Narrative

After all 7 agents complete:

1. **Inventory before drafting.** One reader per reference group lists every win with a coverage tag (`in-draft` /
   `partial` / `missing`) against the current draft; merge and dedupe into `$REFS_DIR/inventory.md`. The synthesis
   accounts for every row. (Single-pass drafting from summaries drops small wins, recognition quotes, and cross-team
   influence.)
2. Write `$SYNTHESIS_FILE` from the inventory using the synthesis template (evidence-integrity checks, revision
   boundaries, full markdown structure, impact language guide, level-expectation calibration):
   [`references/synthesis-template.md`](references/synthesis-template.md). Address the manager's latest stated
   guidance (Agent 6) explicitly.
3. **Critic pass.** A completeness critic confirms every inventory row is placed or deliberately cut and flags
   duplicates; a voice critic applies the HARD RULE below. Verify each status claim against its system (an open PR is
   not shipped).

**HARD RULE — self-review prose is action-first and self-directed.** Write every claim as what the user did, with
active declarative verbs ("I set", "I led", "I shipped"). Render prior-review feedback themes as self-directed habits,
never as direction from others; ban "I was asked/told to", "I tried", "helped with". State a miss as a learning with
its correction already in motion. (Attributed or passive voice implies someone else directed the work.)

**HARD RULE — teammates' data never enters the corpus.** A team-wide analytics export (per-person metrics, names,
emails) stays outside `QPR/` or is gitignored before Stage 3's `git add`; check `git status --short QPR/` first. Quote
only the user's own figures, as rank and ratio vs team average ("most on the team, ~2.4× average"), never raw counts.
Flag any org-wide superlative without a source as unverified. (Peers' figures are sensitive; raw counts read as
activity-justifying.)

## Stage 3: Write Output Files

1. After all agents write their output files, commit the reference files:

   ```bash
   git add QPR/
   git commit -m "feat(QPR): add ${PERIOD_SLUG} performance reference corpus"
   ```

2. Write the synthesized narrative to `$SYNTHESIS_FILE`, then commit:

   ```bash
   git add "$SYNTHESIS_FILE"
   git commit -m "feat(QPR): add ${PERIOD_SLUG} self-performance synthesis"
   git push
   ```

3. Open the synthesis, then announce:

   ```bash
   open "$SYNTHESIS_FILE"
   ```

   Announcement: corpus ready for `${PERIOD_SLUG}`; `QPR/${PERIOD_SLUG}/references/` — {N} source files with raw
   evidence; `QPR/${PERIOD_SLUG}/synthesis.md` — narrative draft ready for QPR submission; the top 3 accomplishments
   surfaced; the 'Quarter Narrative' section has suggested self-review language to paste directly. Remind the user that unblocks
   and influence from private conversations are invisible to the agents and must be added by hand.

## Stage 4: Distill Learnings into Daily Sitreps

After synthesis, route meaningful patterns from this period into the daily sitrep: a recurring impact signal worth
tracking daily → sitrep end brag/snapshot section; a type of work worth preparing for in the morning → wk-sitrep start
context section; a metric that should be monitored → DX section of sitrep end.

**QPR brag log:** append notable accomplishments to the QPR running log:

```bash
QPR_LOG="$PWD/QPR/brag-log.md"
# Append this period's highlights with date range
```

The log accumulates across quarters so the next QPR has a richer corpus.

## Post-Completion

Invoke `wk-learn self-perf`.
