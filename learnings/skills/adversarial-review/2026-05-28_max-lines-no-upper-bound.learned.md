---
skill: wk-adversarial-review
date: 2026-05-28
type: gap
severity: high
---

No upper-bound check on numeric threshold overrides surfaced as a security finding.

**What happened:** A per-repo config field (`max-lines`) accepted any positive integer with no ceiling. A security scanner flagged that setting the value to 999,999 would bypass the LOC-based approval gate entirely. The adversarial review's mechanical sweeps did not detect this class of missing upper-bound validation.

**Root cause:** The mechanical sweeps check for missing null guards, hardcoded bases, and unpinned versions but have no pattern for "numeric config value lacks a reasonable ceiling." Threshold fields that gate security controls are a specific sub-class of numeric validation that the existing sweeps miss.

**Suggested fix:** Add a sweep in Step 2 for new numeric config fields that act as security gates (approval thresholds, rate limits, retry caps). For each, verify: (a) a positive-integer lower-bound check exists, and (b) a hard ceiling constant is defined and enforced. Pattern: grep the diff for `MaxLines`, `Threshold`, `Limit`, `Cap`, `Max` identifiers introduced in config structs, then grep their consuming path for a corresponding upper-bound comparison.
