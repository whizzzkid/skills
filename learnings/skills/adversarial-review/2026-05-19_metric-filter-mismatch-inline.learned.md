---
skill: wk-adversarial-review
date: 2026-05-19
type: gap
severity: high
---

Metric filter for inline_count diverged from ReviewPoster's actual filter — overcounted inline comments.

**What happened:** RunMetrics.emit computed inline_count using a two-condition filter (file != PR_DESCRIPTION && in_diff != false) but ReviewPoster uses a three-condition filter (also severity != info). Info findings are placed in a collapsed summary section, not posted as inline review comments. The metric would systematically overcount actual inline comments posted.

**Root cause:** When extracting RunMetrics from an inline script function, the filter was copied from the original code without cross-checking it against ReviewPoster's actual posting behavior. The "what counts as inline" definition was implicitly split across two modules without the second module being consulted.

**Suggested fix:** Add to sweep 2.8 (cross-doc enumeration sync): when a metric purports to count artifacts produced by another module (posts, comments, inline items), grep that module for the filter it applies to produce those artifacts. Flag any divergence between the metric's filter and the producer's filter as a data model mismatch. Detection sketch: grep for `actionable_findings` / `reject.*severity` near the inline-posting codepath and compare against any `inline_count` or equivalent metric filter.
