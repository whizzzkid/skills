# Suggestion Format and Classification

## Classify suggestions

Tag each suggestion `obvious-fix` or `judgment-required`:

| Tag | Condition |
|---|---|
| `obvious-fix` | Skip rationale empty, concedes the comment is right, or fail-open defect in artifact-producing code. |
| `judgment-required` | A real tradeoff, false-positive possibility, scope question, multiple valid approaches, or security/performance judgment exists. |

Default to `judgment-required` when uncertain.

## Suggestion body format

Every suggestion gives `Why this fix` / `Why skip` reasoning; `{bot_badge}` =
`🤖 (bot)` for bots, else omitted. Be honest in the skip rationale; none exists
→ say so.

## Merge, split, convergence

- Merge duplicate comments on the same `path:line` with the same concern.
- Split one comment with multiple distinct sub-items into one suggestion each.
- Multi-reviewer convergence on the same concern class = incomplete prior fix:
  merge the class, fix it via the Step 6 issue-class scan, reply from each
  flagging thread.

## All-Minor bulk-dismiss gate

Every active finding Minor with plausible skip rationale → render per-finding
summary (commands.md §4) before offering bulk dismiss/triage. Never present a
bare count with no substance. **Cheap-fix override:** Minor naming a concrete
small fix → `obvious-fix`, not deferred.

## Detect design flaws

Triggers: "might not trigger", "depends on X", "what if {edge}", "why do we need
this" → present design change first, clarifying reply second; `(a)` applies
design option.

## Gate fix footprint

Beyond localized patch (new mechanism, cross-cutting) → dismiss + follow-up PR.
Inline only for confirmed PR-scope blocker. Cross-cutting = shared interface or
≥2 call sites, named in rationale.

## Org-specific policy questions

Reviewer question touches org policy → search KB first, cite authoritative doc;
general knowledge only if KB empty, flagged. Skip for code-level/design/
test-coverage questions.

## Docs-ahead-of-code (stacked PR)

Docs describe behavior the diff lacks → check stack section for owning sibling
PR. Owned → future tense. Unowned → code gap.
