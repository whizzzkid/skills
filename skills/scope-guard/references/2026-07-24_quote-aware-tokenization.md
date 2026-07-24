---
class: principle
skill: wk-scope-guard
date: 2026-07-24
severity: medium
---

- **Rule:** A lexical path-scope guard must tokenize its input quote-aware. A plain
  whitespace split lets arbitrary quoted prose synthesize a path argument: a `/` used
  as a word separator inside an `echo` banner becomes a bare `/` token and blocks an
  otherwise fully in-scope recursive search in the same compound command. Tokenize so
  a quoted string stays one token; on unbalanced quotes fall back to the whitespace
  split rather than skipping the check.
- **Why:** The guard collects path-shaped tokens from the whole command line, so any
  quoted text anywhere in a compound command is charged against the search. Quote-aware
  tokenization is a pure correctness fix, not a loosening — a genuinely quoted root
  (`find "/etc"`) still unwraps to one absolute token and still blocks, and a
  separator-glued in-repo root still normalizes correctly. The fallback keeps the
  failure mode closed: a malformed command is still inspected, never waved through.
- **Where:** Hook token loop (quote-aware tokenizer ahead of the trailing-separator
  strip; the surrounding-quote strip stays, load-bearing only on the fallback path)
  plus three bats cases — bare `/` in a quoted banner allows, bare `/` in the search
  command's own quoted pattern allows, unbalanced quotes still block. Skill text:
  "How it decides" now names the tokenizer and the fail-closed fallback.
- **Deliberately not promoted (1):** the source lesson proposed skipping tokens that
  originate inside a quoted string. That relaxes a covered true positive — a quoted
  out-of-repo root is exactly the shape the guard must keep catching. Quote-aware
  tokenization gets the same false-positive relief without the loss.
- **Deliberately not promoted (2):** the source lesson proposed attributing tokens to
  the specific command under test by splitting on shell separators first. Unnecessary
  once tokenization is quote-aware, and a net weakening: an unquoted out-of-repo
  absolute path in a non-search segment (`cd <outside> && grep -r x .`) currently
  blocks, and per-segment attribution would let it through.
- **Corrected in the same pass:** a previously documented false-block shape — recursive
  flag plus unexpanded glob — was disproved against the hook source. No code path
  inspects a glob token, and the shape verifiably does not block. The prescribed
  workaround ("drop `-r`") appeared to confirm the cause only because dropping the
  recursive flag makes the command a non-search, which the guard never inspects. A
  workaround that works is not evidence for the mechanism it was reasoned from.
