---
class: principle
---

**Rule** — When a check reads **staged** content but the real index already holds another
run's path-scoped fold, copy the index, point `GIT_INDEX_FILE` at the copy, and stage there.
Run the hooks and the size `measure()` through the copy, then `unset GIT_INDEX_FILE` and
delete it.

**Why** — `git add` and every `--cached` / `git show ":<path>"` read resolve the index
through `GIT_INDEX_FILE`, defaulting to `.git/index` only when unset. Nothing about making
content visible to a staged-content reader requires mutating the repository's own index;
the common idiom conflates that with "assemble the next commit". The copy gives real
matcher semantics on real staged blobs while the partition survives untouched.

**Rejected alternatives** — stage into the real index and `git reset` afterward (`git reset`
cannot restore *which* paths were staged, so the partition is lost irrecoverably);
hand-reimplement the check against the working tree (diverges from the real matcher);
swap `measure()`'s blob source to `cat` (forfeits the "run it verbatim" guarantee that the
surrounding byte-budget rules depend on); skip the check.

**Failure mode if the cleanup is skipped** — a leaked `GIT_INDEX_FILE` export silently
redirects every later git call in the session to the throwaway index.

**Verified** — driven this run: the probe index listed the pre-existing staged paths plus
the new ones while `git diff --cached` on the real index still listed only the originals,
and `measure()` ran entirely unmodified through the copy.

**Where** — wk-sharpen Step 5 (run the owning hooks) and Step 7.5 (measure the staged
body); cross-referenced from the Step 8 signing-failure rule.
