---
class: principle
---

# Generate live-page spans instead of hand-typing them

**Rule** — When writing `live.md`, emit every item span from an inline generator over the compiled item list:
sequential `data-t`, the canonical toggle handler and copy-block markup copied verbatim, and `#` escaped as `\#` in
item text. Run the generator inline (for example a `jq` filter reading the item list on stdin) and write its output
with the normal Stage 4 / `end` Stage 5 write path.

**Why** — A full page carries dozens of spans, each with a long inline handler. Hand-typing the handler and the ID
sequence is slow and drifts: a single mistyped handler or duplicated `data-t` silently breaks that checkbox's
persistence. A generator produced a 65-item page whose render check passed first time, and a later patch could reuse
the handler from an existing checkbox.

**Rejected suggestion** — Keep the generator as a script file in the session scratchpad. Rejected: the installed
write-scope HARD RULE forbids writing any file outside `$SITREP_REPO/$EMPLOYER/`, and installed HARD RULEs win over a
learning's remedy. The generator stays inline, so no temp file is written.

**Already covered** — The report's second suggestion (replay a `tool_unavailable` domain in the main session before
declaring a connector gap) is already installed: `SKILL.md` Stage 2 block handling ("`tool_unavailable` → replay in
main; still toolless = missing connector") and `subagent-contract.md` unresponsive-agent ceiling ("A domain left
toolless after the main-context replay is a connector gap"). The report shows no violation of it, so no escalation.

**Where** — `SKILL.md` → `start` Stage 4 → *Generate spans; never hand-type them* (applies to `end` Stage 5 too).
