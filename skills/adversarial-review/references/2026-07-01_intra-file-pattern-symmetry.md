---
class: principle
---

**Rule** — When a guard/type pattern appears ≥2× in one file, verify every instance applies it consistently. Two recurring shapes: (a) a `grep`/pipeline appearing ≥2× in one shell script under `set -e`+`pipefail` where one instance is guarded with `|| true` and a sibling is not (empty grep exits 1 → pipefail aborts the script); (b) sibling methods in one RBI/type class bind a block/proc to a receiver (`T.proc.bind(Klass).void`) while a sibling uses an unbound `T.proc.void`. Apply the established guard/binding to every sibling, or justify the difference.

**Why** — A bot caught two Minor findings the sweep missed: an unguarded sibling `grep | sed` under pipefail (an identical guarded grep sat a few lines above), and an RBI sig losing block-receiver precision inconsistently with siblings. Both are intra-file asymmetry of an established pattern — each line looks locally fine, so the general subagent misses them; only a symmetry check catches them.

**Where** — `wk-adversarial-review` sweep 2.65 (extended catalog).
