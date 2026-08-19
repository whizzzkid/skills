---
class: principle
---

**Rule** — When a bot flags syntax/language features as invalid in a
framework-managed file, verify the claim against the framework's compilation
pipeline before accepting. Framework bundlers process syntax that static
analysis cannot account for; the build result is the ground truth.

**Why** — A bot's static analysis evaluates source text in isolation. Framework
toolchains (Astro, Svelte, Vue SFC, etc.) transform script blocks through a
bundler that supports syntax the raw browser runtime does not. Accepting the
bot's verdict without a build check led to an unnecessary rewrite that removed
valid framework-supported syntax.

**Where** — `SKILL.md` → Step 4 → *Reproduce an externally-sourced finding*
(escalated to **Important** — re-violation of the existing hypothesis rule).
