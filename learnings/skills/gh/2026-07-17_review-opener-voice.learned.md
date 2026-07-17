---
skill: wk-gh
date: 2026-07-17
type: correction
severity: medium
---

Open a review body with the verdict state, never a praise adjective — "Solid, well-scoped change" reads as robotic AI filler.

**What happened:** A review body opened with "Solid, well-grounded design spec — …". The user cut the opener and asked that reviews instead lead with the state: `LGTM`, `LGTM, just a minor nit`, `LGTM, minor follow-up …`, or the equivalent concern verdict.

**Root cause:** Generic praise openers ("Solid …", "well-scoped", "great work") carry no information, are the tell-tale cadence of AI-generated review prose, and delay the one thing a reader wants first — the verdict. The state (approve / approve-with-concerns / blocked) is the lede.

**Suggested fix:** First clause of any review body is the verdict state, not an adjective. Approve-clean → `LGTM 🚀`. Approve with small items → `LGTM, one minor nit` / `LGTM, minor follow-up`. Approve with concerns → lead with "Approving with concerns —" then the single biggest risk. Ban praise-adjective openers ("Solid", "well-scoped", "well-grounded", "nice", "great") as the first words. Genuine praise, when warranted, goes in a later dedicated line, not the opener.
