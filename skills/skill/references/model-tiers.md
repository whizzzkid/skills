# Model tiers (Step 4)

Pick the tier by task complexity, then fill `model:` and the per-vendor `metadata.model` IDs from its row.

| Tier | When | Claude Code | OpenAI | Gemini |
|------|------|-------------|--------|--------|
| `haiku` | Single lookups, CalVer, trivial transforms | `haiku` | `gpt-5.6-luna` | `gemini-2.5-flash-8b` |
| `sonnet` | Most skills — structured, multi-step work | `sonnet` | `gpt-5.6-terra` | `gemini-2.5-flash` |
| `opus` | Deep reasoning, adversarial review, batch distillation | `opus` | `gpt-5.6-sol` | `gemini-2.5-pro` |
