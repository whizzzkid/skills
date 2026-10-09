# Finding and audit-summary templates

## Per-finding block (Stage 4)

```
{path} — {kind: relocated / subsumed / suspicious}
  Removed:  {line excerpt with line number from base}
  Replaces: {pointer to relocation, or "—"}
  Concern:  {what behavior may have been dropped}
  Verify:   {one concrete check the user should run, or auto-run}
```

## Per-finding prompt (one at a time)

> "**Finding {n}/{total}** — {summary}.
>
> **(a)** Confirmed intentional — proceed
> **(b)** Regression — propose a fix
> **(c)** Need more info — investigate further
> **(s)** Skip
>
> Reply `a` / `b` / `c` / `s`."

## Audit summary (Stage 5)

One block per file, plus a summary:

```
Refactor kind: <classification>
Diff shape: matches | deviates (<reason>)
Files audited: <count>
Findings: <count> total ({a} confirmed, {b} fixed, {c} skipped, {open} remaining)
Status: PASS | REGRESSIONS REMAINING

Per-file:
- <path>: <one-line per finding with status>
```
