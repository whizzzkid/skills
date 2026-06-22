---
skill: wk-pr-review
date: 2026-06-19
type: pattern
severity: medium
---

When a finding hinges on "the LLM preserves field X verbatim," validate the claim against the prompt/skill text and the test mocks — never accept the author's assertion.

**What happened:** A PR added a downstream-observability field computed by diffing an LLM validator's input findings against its returned set, keyed on an identity tuple that included the free-text `issue` prose. A bot flagged the prose-key risk; the PR description and a code comment asserted "issue text is stable within a run." Rather than trust that, I grepped the validator prompt builder and skill: severity was explicitly pinned ("Do NOT change severity levels") but issue prose was never instructed to be echoed verbatim — and a sibling helper existed precisely because the validator drops fields the output template omits. The stability assumption was an unenforced LLM-behavior bet, confirming the bot's concern and upgrading it from nit to a real data-corruption path (same finding double-counted into both kept and dropped sets).

**Root cause:** Identity/dedup keys built from LLM-emitted free text are fragile unless the prompt forces verbatim echo. Author assertions about "stable" LLM output are assumptions, not guarantees; the relevant evidence is whether the prompt pins the field and whether the test mocks can even exercise the rephrase path (these mocks returned input verbatim, so the risky path was untested).

**Suggested fix:** In adversarial/pr-review, when a finding depends on an LLM round-trip preserving a field, (1) grep the prompt + skill for an explicit verbatim-preservation instruction for that exact field — absence is confirming evidence; (2) note when sibling code already compensates for the validator dropping un-echoed fields; (3) check whether test mocks preserve the field verbatim (if so, the risky path is uncovered — recommend a rephrasing-mock regression test). Prefer fixing at the source (pin the field in the prompt) over a downstream key workaround.
