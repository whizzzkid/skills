---
class: principle
---

# awk side files load by path, never as operands

**Rule** — An `awk` program that reads a side file (spec, mapping, allowlist) loads it by path via `-v` and `getline`
in `BEGIN`; the side file never also appears as a file operand. Check `[[ -r "$spec" ]]` before the run, and diff the
output against its input before an in-place overwrite.

**Why** — Every file operand is main input, so the side file's lines run through the main rules too. A pass-through
`print` copies them into the output: valid program, empty stderr, rc=0, and the intended transform still happens, so
the leaked lines read as page content. The two-operand `NR==FNR { …; next }` idiom avoids the leak but has its own
silent failure: an empty side file makes the main file satisfy `NR==FNR`, so every main line is consumed as spec and
the output is empty, still rc=0. `getline` returns -1 on a missing path, and a `> 0` loop treats that as end of file,
so a mistyped path silently becomes an empty spec.

**Verified against source** — Ran BSD `awk` directly on a 3-line page and a 1-line `key|replacement` spec:

- Spec passed via `-v` *and* as an operand: the output led with the raw spec line, then the correctly transformed
  page.
- Spec passed via `-v` only: the transformed page alone.
- `NR==FNR` with an empty side file: zero output lines, rc=0.
- `getline` on a missing path: returned -1, awk rc=0.

**Sharpened from the report** — The report said "pass the spec only via `-v`/getline". The reproduction adds the
`NR==FNR` empty-file trap (so the two-operand idiom is not the safe alternative) and the missing-path `getline` -1.

**Ownership** — Filed under `skill: wk-sitrep` because it surfaced in a sitrep in-place page transform, but the
mechanic is general `awk` behavior. Routed to `wk-workstyle-shell`, which owns the `awk` silent-failure catalog.
wk-sitrep's Stage 4 rule against `sed`/`awk` *replacement* (it strips the `\` from `\#`) is unaffected. The report did
not say any `\#` was lost.

**Already covered (wk-sitrep, no escalation)** — The report's main point: on a gathering subagent's
`tool_unavailable`, replay that domain in the main session before labelling a connector gap. That rule is already
installed in wk-sitrep `SKILL.md`, `start` Stage 2 block handling ("`tool_unavailable` → replay in main; still
toolless = missing connector"). It is backed by `references/subagent-contract.md` ("PROBE TOOLS FIRST"; "A domain
left toolless after the main-context replay is a connector gap") and
`references/2026-08-10_complete-domain-fallback.md`. In the same session the replay ran and cleared one carry-over
item with hard evidence, so the rule fired correctly. That evidence blocks escalation.

**Where** — `references/shell-traps.md` → *awk Side Files as Operands*; `SKILL.md` → Rules → trap-catalog pointer.
