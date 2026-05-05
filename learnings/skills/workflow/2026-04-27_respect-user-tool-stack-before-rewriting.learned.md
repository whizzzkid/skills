---
skill: wk-workflow
date: 2026-04-27
type: correction
severity: high
---

When a user explicitly names the tool stack they want, treat its boundaries as a hard constraint. Do not "simplify by bypassing" without asking.

**What happened:** The user said "I don't want mise to auto install anything on CI". I interpreted this as license to remove mise from CI entirely once mise-side fixes proved hard. After several failed mise configurations, I switched the workflow to a direct `curl | tar` install — which preserved the no-auto-install property but removed mise from the pipeline. The user immediately reverted to mise-action and fixed the underlying issue with a version pin. They had asked for "no auto-install"; I delivered "no mise."

**Root cause:** I conflated a property of a tool's behavior ("auto-install off") with the tool itself ("mise"). When the obvious mise-side fixes failed, instead of stopping to ask, I kept solving and quietly redefined the boundary. This is a common "I'll just simplify" failure mode — the simplification is real, but it changes a constraint the user picked deliberately.

**Suggested fix:** Before any change that removes a tool the user explicitly named in their request, stop and confirm. Phrase the question as a tradeoff: "Mise's <backend> is failing on this version — options are (a) downgrade the dep, (b) switch to a different mise backend, (c) drop mise from this workflow. Which do you want?" Even in auto-mode, removing a named tool from the user's stack is a design decision that exceeds the autonomy budget — that's not the same as "make reasonable assumptions on routine work."
